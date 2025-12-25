import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  final GenerativeModel _model;

  GeminiClient({String? apiKey, String? modelName})
      : _model = GenerativeModel(
          model: modelName ?? (const String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-1.5-pro')),
          apiKey: apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
        );

  Future<Map<String, dynamic>> diagnose(Map<String, dynamic> telemetry) async {
    final prompt = _buildPrompt(telemetry);
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    final text = response.text ?? '';
    try {
      return json.decode(text) as Map<String, dynamic>;
    } catch (_) {
      // If not JSON, wrap in structure
      return {
        'diagnosis': text,
        'confidence': 0.0,
        'evidence': telemetry,
      };
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
