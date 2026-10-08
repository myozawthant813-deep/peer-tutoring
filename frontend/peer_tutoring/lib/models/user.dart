class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String university;
  final String major;
  final int year;
  final String bio;
  final String profileImage;
  final String role;
  final int peerScore;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.university,
    required this.major,
    required this.year,
    required this.bio,
    required this.profileImage,
    required this.role,
    required this.peerScore,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        password: json['password'],
        university: json['university'],
        major: json['major'],
        year: json['year'],
        bio: json['bio'],
        profileImage: json['profileImage'] ?? '',
        role: json['role'],
        peerScore: json['peerScore']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'university': university,
      'major': major,
      'year': year,
      'bio': bio,
      'profileImage': profileImage,
      'role': role,
      'peerScore': peerScore,
    };
  }
}
