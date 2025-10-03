class User {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  String get fullName => '$firstName $lastName';
}