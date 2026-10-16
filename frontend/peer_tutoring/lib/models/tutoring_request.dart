class TutoringRequest {
  final int requesterId;
  final int tutorId;
  final String subject;
  final String message;

  TutoringRequest(
      {required this.requesterId,
      required this.tutorId,
      required this.subject,
      required this.message});

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'tutorId': tutorId,
      'subject': subject,
      'message': subject
    };
  }
}
