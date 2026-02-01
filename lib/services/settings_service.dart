import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _geminiModelKey = 'gemini_model';
  static const String _useGeminiKey = 'use_gemini';

  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, apiKey);
  }

  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }

  Future<void> saveGeminiModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiModelKey, model);
  }

  Future<String> getGeminiModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiModelKey) ?? 'gemini-2.5-pro';
  }

  Future<void> setUseGemini(bool use) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGeminiKey, use);
  }

  Future<bool> getUseGemini() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useGeminiKey) ?? true;
  }
}
