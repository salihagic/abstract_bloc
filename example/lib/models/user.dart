/// Model representing a user in the list.
///
/// This is a simplified model used for the list view.
/// For full user details, see [UserDetails].
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(id: map['id'] as int, name: map['name'] as String);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
