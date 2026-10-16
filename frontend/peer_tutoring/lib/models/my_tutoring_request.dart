class MyTutoringRequest {
  final int id;
  final int tutorId;
  final String tutorName;
  final String subject;
  final String message;
  final String status;
  final String createdAt;

  MyTutoringRequest({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory MyTutoringRequest.fromJson(Map<String, dynamic> json) {
    return MyTutoringRequest(
      id: json['id'] as int,
      tutorId: json['tutorId'] as int,
      tutorName: json['tutorName'] ?? 'Unknown tutor',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
