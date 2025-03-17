class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(id: map['id'] as int, name: map['name'] as String);
  }
}
