class UserDetailsSearchModel {
  final int? id;

  UserDetailsSearchModel({this.id});

  Map<String, dynamic> toMap() {
    return {'id': id};
  }
}
