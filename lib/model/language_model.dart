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