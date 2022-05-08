class UserDetails {
  final int id;
  final String name;
  final String email;
  final String gender;
  final String status;

  UserDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.status,
  });

  factory UserDetails.fromMap(Map<dynamic, dynamic> map) {
    return UserDetails(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String,
      status: map['status'] as String,
    );
  }
}
