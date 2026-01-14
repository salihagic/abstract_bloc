/// Model representing complete user details.
///
/// Used by [UserDetailsBloc] for the detail page.
/// Contains all user information returned by the API.
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'status': status,
    };
  }
}
