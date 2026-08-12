class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'application_accepted', 'new_applicant', 'job_cancelled', 'job_reminder'
  final String jobId;
  final String timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.jobId,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'jobId': jobId,
        'timestamp': timestamp,
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<dynamic, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      jobId: json['jobId'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}
