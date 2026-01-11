import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiClient {
  GenerativeModel? _model;

  GeminiClient({String? apiKey, String? modelName}) {
    _initModel(apiKey, modelName);
  }

  Future<void> _initModel(String? apiKey, String? modelName) async {
    String? key = apiKey;
    if (key == null || key.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      key = prefs.getString('gemini_api_key');
    }

    key ??= const String.fromEnvironment('GEMINI_API_KEY');

    if (key.isEmpty) {
      throw Exception('No Gemini API key found. Please configure in Settings.');
    }

    _model = GenerativeModel(
      model:
          modelName ??
          const String.fromEnvironment(
            'GEMINI_MODEL',
            defaultValue: 'gemini-1.5-pro',
          ),
      apiKey: key,
    );
  }

  Future<Map<String, dynamic>> diagnose(Map<String, dynamic> telemetry) async {
    if (_model == null) {
      await _initModel(null, null);
    }

    if (_model == null) {
      throw Exception('Failed to initialize Gemini model');
    }

    final prompt = _buildPrompt(telemetry);
    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(content);
    final text = response.text ?? '';
    try {
      return json.decode(text) as Map<String, dynamic>;
    } catch (_) {
      // If not JSON, wrap in structure
      return {'diagnosis': text, 'confidence': 0.0, 'evidence': telemetry};
    }
  }

  String _buildPrompt(Map<String, dynamic> telemetry) {
    return '''
You are an automotive diagnostics expert. Given live OBD-II telemetry, produce a concise diagnosis.
Return STRICT JSON with keys: diagnosis (string), confidence (0.0-1.0), probable_causes (array of strings), recommended_actions (array of strings), required_follow_up_tests (array of strings). Avoid extra commentary.
Telemetry:
${jsonEncode(telemetry)}
''';
  }
}
