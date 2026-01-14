/// Search model for fetching user details.
///
/// Contains the user ID used to fetch the specific user's details.
/// Unlike list search models, this doesn't need pagination.
class UserDetailsSearchModel {
  final int? id;

  UserDetailsSearchModel({this.id});

  Map<String, dynamic> toMap() {
    return {'id': id};
  }
}
