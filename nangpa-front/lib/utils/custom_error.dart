class CustomException implements Exception {
  final String message;
  final int errorCode;

  CustomException(this.errorCode, [this.message = ""]);

  @override
  String toString() => message;
}
