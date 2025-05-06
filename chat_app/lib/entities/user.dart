class User {
  final int? id;
  final String email;
  final String password;
  final String name;
  final String lastName;
  final String phoneNumber;
  final String rol;
  final String? profilePicture;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    required this.rol,
    this.profilePicture,
  });

  Map<String, String> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'rol': rol,
      'picture': profilePicture ?? "",
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json.containsKey('id') ? json['id'] as int : -1,
      email: json['email'],
      password: json['password'],
      name: json['name'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      rol: json['rol'],
      profilePicture: json.containsKey('picture') ? json['picture'] as String : "",
    );
  }
}
