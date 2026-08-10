import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../data/models/job_model.dart';

class JobService extends GetxService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Create a new job — returns the generated jobId
  Future<String> createJob(JobModel job) async {
    final ref = _db.child('jobs').push();
    final jobId = ref.key!;
    final jobWithId = JobModel(
      jobId: jobId,
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
    return jobId;
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

  // Cancel a job
  Future<void> cancelJob(String jobId) async {
    await _db.child('jobs').child(jobId).update({'status': 'cancelled'});
  }
}
