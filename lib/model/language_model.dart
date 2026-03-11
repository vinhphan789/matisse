/// Model dữ liệu (giống Codable trong Swift)
class LanguageModel {
  final String key;
  final String value;

  LanguageModel({
    required this.key,
    required this.value,
  });

  /// Parse JSON -> Model
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      key: json['key'],
      value: json['value'],
    );
  }
}

/// Model cho response của API login
/// Giống Codable struct bên Swift
class LoginModel {
  final String accessToken;
  final String refreshToken;
  final String idToken;
  final String scope;
  final int expiresIn;
  final String tokenType;

  LoginModel({
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.scope,
    required this.expiresIn,
    required this.tokenType,
  });

  /// Parse từ JSON — giống init(from decoder: Decoder) bên Swift
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken:  json['access_token']  ?? '',
      refreshToken: json['refresh_token'] ?? '',
      idToken:      json['id_token']      ?? '',
      scope:        json['scope']         ?? '',
      expiresIn:    json['expires_in']    ?? 0,
      tokenType:    json['token_type']    ?? '',
    );
  }
}