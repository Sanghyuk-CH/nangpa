class LoginModel {
  final String phoneNumber;
  final String password;

  LoginModel({required this.phoneNumber, required this.password});
}

class ChangePasswordModel {
  final String phoneNumber;
  final String originPassword;
  final String newPassword;
  ChangePasswordModel(
      {required this.phoneNumber,
      required this.originPassword,
      required this.newPassword});
}

class SignUpModel {
  final String phoneNumber;
  final String password;
  final String name;
  final bool marketing;

  SignUpModel(
      {required this.phoneNumber,
      required this.password,
      required this.name,
      required this.marketing});
}
