class UserModel {
  late int? user_id;
  late String? username;
  late String? password;
  late String? account_type;

  UserModel({
    required this.user_id,
    required this.username,
    required this.password,
    required this.account_type
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'username': username,
      'password': password,
      'account_type': account_type
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'UserModel{user_id: $user_id, username: $username}';
  }
}