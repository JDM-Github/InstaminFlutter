import 'dart:convert';
import 'package:flutter/services.dart';

class Config {
  final String title;
  final String termsText;

  Config({required this.title, required this.termsText});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      title: json['termsAndPolicyTitle'] ?? '',
      termsText: json['termsAndPolicyText'] ?? '',
    );
  }

  static Future<Config> load() async {
    String configString = await rootBundle.loadString('config/config.json');
    Map<String, dynamic> configMap = json.decode(configString);
    return Config.fromJson(configMap);
  }
}
