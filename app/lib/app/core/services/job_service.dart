import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_applicant.dart';
import '../../data/models/user_model.dart';
import 'notification_service.dart';

/// Result of an apply-to-job transaction
enum ApplyResult { success, alreadyApplied, jobFull, roleMismatch, error }

class JobService extends GetxService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Create a new job — returns the generated jobId
  Future<String> createJob(JobModel job) async {
    // Atomically get next job number
    final counterRef = _db.child('counters/jobNumber');
    final txResult = await counterRef.runTransaction((currentData) {
      final current = (currentData as int?) ?? 0;
      return Transaction.success(current + 1);
    });
    final nextJobNumber = (txResult.snapshot.value as int?) ?? 1;

    final ref = _db.child('jobs').push();
    final jobId = ref.key!;
    final jobWithId = JobModel(
      jobId: jobId,
      jobNumber: nextJobNumber,
      adminId: job.adminId,
      venueName: job.venueName,
      venueAddress: job.venueAddress,
      city: job.city,
      date: job.date,
      wage: job.wage,
      description: job.description,
      contactPersonName: job.contactPersonName,
      contactPersonPhone: job.contactPersonPhone,
      titles: job.titles,
      status: 'open',
      createdAt: DateTime.now().toIso8601String(),
    );
    await ref.set(jobWithId.toJson());
    _notifyMatchingWorkers(jobId, jobWithId);
    return jobId;
  }

  void _notifyMatchingWorkers(String jobId, JobModel job) async {
    try {
      final roles = job.titles.map((t) => t.role.toLowerCase()).toSet();
      final usersSnapshot = await _db.child('users').get();
      if (!usersSnapshot.exists || usersSnapshot.value == null) return;

      final users = Map<dynamic, dynamic>.from(usersSnapshot.value as Map);
      final notifService = Get.find<NotificationService>();

      for (final entry in users.entries) {
        final userData = Map<dynamic, dynamic>.from(entry.value as Map);
        final userRole = (userData['role'] ?? '').toString().toLowerCase();
        if (userRole != 'admin' && roles.contains(userRole)) {
          notifService.sendNotification(
            userId: entry.key.toString(),
            title: 'New Job Available! 🆕',
            body: '${job.venueName} is looking for ${userRole}s — ₹${job.wage}/day on ${job.date}.',
            type: 'new_job',
            jobId: jobId,
          );
        }
      }
    } catch (_) {}
  }

  // Real-time stream of all jobs posted by a specific admin
  Stream<List<JobModel>> streamAdminJobs(String adminId) {
    return _db
        .child('jobs')
        .orderByChild('adminId')
        .equalTo(adminId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final jobs = raw.values
          .map((v) => JobModel.fromJson(Map<dynamic, dynamic>.from(v as Map)))
          .toList();
      // Sort newest first
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // Real-time stream of all open jobs for workers
  Stream<List<JobModel>> streamOpenJobs() {
    return _db
        .child('jobs')
        .orderByChild('status')
        .equalTo('open')
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final jobs = raw.values
          .map((v) => JobModel.fromJson(Map<dynamic, dynamic>.from(v as Map)))
          .toList();
      // Sort newest first
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // Real-time stream of all jobs a worker has applied to
  Stream<List<JobModel>> streamWorkerJobs(String workerUid) {
    return _db.child('jobs').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final jobs = raw.values
          .map((v) => JobModel.fromJson(Map<dynamic, dynamic>.from(v as Map)))
          .where((j) => j.hasWorkerApplied(workerUid))
          .toList();
      // Sort newest first
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // Cancel a job
  Future<void> cancelJob(String jobId) async {
    final snapshot = await _db.child('jobs').child(jobId).get();
    if (snapshot.exists && snapshot.value != null) {
      final jobMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final job = JobModel.fromJson(jobMap);

      await _db.child('jobs').child(jobId).update({'status': 'cancelled'});

      // Notify all applicants
      final notifService = Get.find<NotificationService>();
      for (final uid in job.applicants.keys) {
        notifService.sendNotification(
          userId: uid,
          title: 'Job Cancelled 🔴',
          body: 'Job ${job.formattedJobNumber} at ${job.venueName} was cancelled by admin.',
          type: 'job_cancelled',
          jobId: jobId,
        );
      }
    }
  }

  // ── Apply-to-Job Transaction ─────────────────────────────────────────
  //
  // Atomically:
  //   1. Check if worker already applied (duplicate prevention)
  //   2. Find first title matching worker's role with available slots
  //   3. Increment slotsFilled on that title
  //   4. Record applicant UID + metadata on the job node
  //
  // Returns an ApplyResult indicating outcome.
  Future<ApplyResult> applyToJob(String jobId, UserModel worker) async {
    final jobRef = _db.child('jobs').child(jobId);

    try {
      final result = await jobRef.runTransaction((currentData) {
        if (currentData == null) {
          return Transaction.abort();
        }

        final jobMap = Map<String, dynamic>.from(currentData as Map);

        // Check job is still open
        if (jobMap['status'] != 'open') {
          return Transaction.abort();
        }

        // Check if worker already applied
        final applicants =
            Map<String, dynamic>.from(jobMap['applicants'] ?? {});
        if (applicants.containsKey(worker.uid)) {
          return Transaction.abort();
        }

        // Parse titles and find a matching role with available slots
        final rawTitles = jobMap['titles'];
        if (rawTitles == null) return Transaction.abort();

        List<Map<String, dynamic>> titles;
        if (rawTitles is List) {
          titles = rawTitles
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else if (rawTitles is Map) {
          // RTDB may store List as Map with integer keys
          final sorted = rawTitles.entries.toList()
            ..sort((a, b) =>
                int.parse(a.key.toString()).compareTo(int.parse(b.key.toString())));
          titles = sorted
              .map((e) => Map<String, dynamic>.from(e.value as Map))
              .toList();
        } else {
          return Transaction.abort();
        }

        int matchedIndex = -1;
        for (int i = 0; i < titles.length; i++) {
          final titleRole = (titles[i]['role'] ?? '').toString().toLowerCase();
          final slotsFilled = _toInt(titles[i]['slotsFilled']);
          final slotsTotal = _toInt(titles[i]['slotsTotal']);
          if (titleRole == worker.role.toLowerCase() &&
              slotsFilled < slotsTotal) {
            matchedIndex = i;
            break;
          }
        }

        if (matchedIndex == -1) {
          return Transaction.abort();
        }

        // Increment slotsFilled on the matched title
        titles[matchedIndex]['slotsFilled'] =
            _toInt(titles[matchedIndex]['slotsFilled']) + 1;

        // Record the applicant
        applicants[worker.uid] = {
          'titleIndex': matchedIndex,
          'appliedAt': DateTime.now().toIso8601String(),
        };

        jobMap['titles'] = titles;
        jobMap['applicants'] = applicants;

        return Transaction.success(jobMap);
      });

      if (result.committed) {
        _sendApplyNotifications(jobId, worker);
        return ApplyResult.success;
      }

      // Transaction aborted — determine the reason
      // Re-read the job to figure out why
      return await _diagnoseAbort(jobId, worker);
    } catch (e) {
      return ApplyResult.error;
    }
  }

  void _sendApplyNotifications(String jobId, UserModel worker) async {
    try {
      final snapshot = await _db.child('jobs').child(jobId).get();
      if (!snapshot.exists || snapshot.value == null) return;
      final jobMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final job = JobModel.fromJson(jobMap);
      final notifService = Get.find<NotificationService>();

      final appData = job.applicants[worker.uid];
      String roleTitle = worker.role;
      if (appData is Map) {
        final idx = _toInt(appData['titleIndex']);
        if (idx >= 0 && idx < job.titles.length) {
          roleTitle = job.titles[idx].title;
        }
      }

      // Notify Worker
      notifService.sendNotification(
        userId: worker.uid,
        title: 'Application Accepted! 🎉',
        body: 'You secured a slot for $roleTitle in ${job.formattedJobNumber} at ${job.venueName}.',
        type: 'application_accepted',
        jobId: jobId,
      );

      // Notify Admin
      if (job.adminId.isNotEmpty) {
        notifService.sendNotification(
          userId: job.adminId,
          title: 'New Applicant! 📋',
          body: '${worker.name} applied for $roleTitle in ${job.formattedJobNumber}.',
          type: 'new_applicant',
          jobId: jobId,
        );
      }
    } catch (_) {}
  }

  /// After a transaction abort, determine the specific reason by reading
  /// the current job state.
  Future<ApplyResult> _diagnoseAbort(String jobId, UserModel worker) async {
    try {
      final snapshot = await _db.child('jobs').child(jobId).get();
      if (!snapshot.exists || snapshot.value == null) {
        return ApplyResult.error;
      }
      final jobMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final job = JobModel.fromJson(jobMap);

      if (job.hasWorkerApplied(worker.uid)) {
        return ApplyResult.alreadyApplied;
      }
      if (!job.hasAvailableSlotsForRole(worker.role)) {
        // Check if it's a role mismatch vs all slots full
        final hasMatchingRole =
            job.titles.any((t) => t.role.toLowerCase() == worker.role.toLowerCase());
        return hasMatchingRole ? ApplyResult.jobFull : ApplyResult.roleMismatch;
      }
      return ApplyResult.error;
    } catch (_) {
      return ApplyResult.error;
    }
  }

  // ── Check if a worker has already applied to a job ──────────────────
  Future<bool> checkIfApplied(String jobId, String workerUid) async {
    final snapshot =
        await _db.child('jobs').child(jobId).child('applicants').child(workerUid).get();
    return snapshot.exists;
  }

  // ── Fetch all applicants for a job (for admin screen) ───────────────
  //
  // Reads the applicants map from the job, then fetches each worker's
  // profile from the users node and resolves the title name.
  Future<List<JobApplicant>> fetchJobApplicants(JobModel job) async {
    if (job.applicants.isEmpty) return [];

    final List<JobApplicant> result = [];

    for (final entry in job.applicants.entries) {
      final uid = entry.key;
      final data = entry.value is Map
          ? Map<String, dynamic>.from(entry.value as Map)
          : <String, dynamic>{};
      final titleIndex = _toInt(data['titleIndex']);
      final appliedAt = data['appliedAt']?.toString() ?? '';

      // Resolve title name
      String titleName = 'Unknown';
      if (titleIndex >= 0 && titleIndex < job.titles.length) {
        titleName = job.titles[titleIndex].title;
      }

      // Fetch worker profile
      try {
        final userSnapshot = await _db.child('users').child(uid).get();
        if (userSnapshot.exists && userSnapshot.value != null) {
          final userData =
              Map<dynamic, dynamic>.from(userSnapshot.value as Map);
          final user = UserModel.fromJson(userData);
          result.add(JobApplicant(
            uid: uid,
            name: user.name,
            phone: user.phone,
            role: user.role,
            city: user.city,
            titleIndex: titleIndex,
            titleName: titleName,
            appliedAt: appliedAt,
          ));
        }
      } catch (_) {
        // Skip unreadable profiles
      }
    }

    // Sort by appliedAt (earliest first)
    result.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
    return result;
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
