import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  late GenerativeModel _model;
  final String? _apiKey;
  final String _primaryModel;
  
  static const List<String> FALLBACK_MODELS = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
  ];

  GeminiClient({String? apiKey, String? modelName})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
        _primaryModel = modelName ?? 'gemini-2.5-pro' {
    _initializeModel();
  }

  void _initializeModel() {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw ArgumentError('GEMINI_API_KEY is required');
    }
    _model = GenerativeModel(
      model: _primaryModel,
      apiKey: _apiKey!,
    );
  }

  /// Validate API key format
  bool validateApiKey(String key) {
    return key.isNotEmpty && key.length > 10;
  }

  /// Set model dynamically
  void setModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey!,
    );
  }

  /// Get list of available models
  List<String> getAvailableModels() {
    return [_primaryModel, ..._fallbackModels()];
  }

  List<String> _fallbackModels() {
    return FALLBACK_MODELS.where((m) => m != _primaryModel).toList();
  }

  Future<Map<String, dynamic>> diagnose(Map<String, dynamic> telemetry) async {
    final prompt = _buildPrompt(telemetry);
    final content = [Content.text(prompt)];
    
    try {
      final response = await _model.generateContent(content).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Diagnosis timeout'),
      );
      
      final text = response.text ?? '';
      try {
        return json.decode(text) as Map<String, dynamic>;
      } catch (_) {
        // If not JSON, wrap in structure
        return {
          'diagnosis': text,
          'confidence': 0.5,
          'probable_causes': ['Requires manual inspection'],
          'recommended_actions': ['Review diagnosis above'],
          'required_follow_up_tests': ['Visual inspection recommended'],
          'evidence': telemetry,
        };
      }
    } catch (e) {
      // Fallback to simpler diagnosis
      return _buildFallbackDiagnosis(telemetry, e.toString());
    }
  }

  /// Build fallback diagnosis when API fails
  Map<String, dynamic> _buildFallbackDiagnosis(
    Map<String, dynamic> telemetry,
    String error,
  ) {
    final issues = <String>[];
    
    // Basic heuristic checks
    final rpm = telemetry['010C'] as num? ?? 0;
    final temp = telemetry['0105'] as num? ?? 0;
    final load = telemetry['0104'] as num? ?? 0;
    
    if (temp > 110) issues.add('Engine overheating');
    if (load > 80) issues.add('High engine load');
    if (rpm > 6500) issues.add('High RPM operation');
    
    return {
      'diagnosis': issues.isEmpty
          ? 'Vehicle operating normally'
          : 'Potential issues detected: ${issues.join(", ")}',
      'confidence': 0.4,
      'probable_causes': issues,
      'recommended_actions': [
        'Check temperature gauge',
        'Monitor engine load',
        'Consult full diagnostics'
      ],
      'required_follow_up_tests': ['Full OBD-II scan'],
      'evidence': telemetry,
      'fallback': true,
      'error': error,
    };
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

