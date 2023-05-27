class Users {
  int id;
  String name;
  String lastName;
  String email;
  String password;
  String username;
  String role;

  Users({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'password': password,
      'username': username,
      'role': role,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'],
      name: map['name'],
      lastName: map['lastName'],
      email: map['email'],
      password: map['password'],
      username: map['username'],
      role: map['role']
    );
  }

}