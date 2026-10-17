class TutoringSession {
  final int requestId;
  final int tutorId;
  final DateTime scheduledAt;
  final String meetingLink;

  TutoringSession({
    required this.requestId,
    required this.tutorId,
    required this.scheduledAt,
    required this.meetingLink,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'tutorId': tutorId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'meetingLink': meetingLink,
    };
  }
}
