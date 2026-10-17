class IncomingTutoringRequest {
  final int id;
  final int requesterId;
  final String requesterName;
  final String subject;
  final String message;
  final String status;
  final String createdAt;

  IncomingTutoringRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory IncomingTutoringRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return IncomingTutoringRequest(
      id: (json['id'] as num).toInt(),
      requesterId: (json['requesterId'] as num).toInt(),
      requesterName: json['requesterName'] ?? 'Unknown student',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
