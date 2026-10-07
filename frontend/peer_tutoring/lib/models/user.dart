class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String university;
  final String major;
  final int year;
  final String bio;
  final String profilePicture;
  final String role;
  final int peerScore;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.password,
      required this.university,
      required this.major,
      required this.year,
      required this.bio,
      required this.profilePicture,
      required this.role,
      required this.peerScore});

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
        profilePicture: json['profilePicture'] ?? '',
        role: json['role'],
        peerScore: json['peerScore']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'university': university,
      'major': major,
      'year': year,
      'bio': bio,
      'profilePicture': profilePicture,
      'role': role,
      'peerScore': peerScore,
    };
  }
}
