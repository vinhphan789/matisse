class ForgotPasswordModel {
  final String message;

  ForgotPasswordModel({required this.message});

  /// Auth0 trả về plain text, không phải JSON
  factory ForgotPasswordModel.fromString(String text) {
    return ForgotPasswordModel(message: text);
  }
}
