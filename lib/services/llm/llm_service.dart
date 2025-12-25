import 'dart:convert';

import 'package:http/http.dart' as http;

class LlmService {
  /// Parse raw OBD text using a local Ollama instance.
  ///
  /// Defaults assume you're running Ollama server on the host machine.
  /// - For Android emulator use `http://10.0.2.2:11434`
  /// - For a device on the same LAN use `http://<host-ip>:11434`
  ///
  /// `model` defaults to `dolphin-mixtral-3.7b` per request.
  static Future<String> parseObd(String rawData,
      {String baseUrl = 'http://10.0.2.2:11434', String model = 'dolphin-mixtral-3.7b', String? remoteEndpoint, String? apiKey}) async {
    final prompt =
        'Parse the following OBD-II/ELM327 raw response and return a concise JSON with keys: "pid_responses" (map pid->value), "diagnosis" (short human-readable), and "confidence" (0-1). Response:\n\n$rawData';

    // If model indicates Gemini, use remoteEndpoint + apiKey
    if (model.toLowerCase().startsWith('gemini')) {
      if (remoteEndpoint == null || apiKey == null) {
        throw Exception('Remote endpoint and apiKey required for Gemini models');
      }
      final url = Uri.parse(remoteEndpoint);
      final body = jsonEncode({'model': model, 'prompt': prompt});
      final resp = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'}, body: body).timeout(const Duration(seconds: 60));
      if (resp.statusCode == 200) {
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map && decoded['output'] is String) return decoded['output'];
        } catch (_) {}
        return resp.body;
      } else {
        throw Exception('Remote Gemini request failed: ${resp.statusCode} ${resp.body}');
      }
    }

    // Default: local Ollama
    final url = Uri.parse('$baseUrl/api/generate');

    final body = jsonEncode({
      'model': model,
      'prompt': prompt,
      'options': {'stream': false}
    });

    final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 60));

    if (resp.statusCode == 200) {
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map) {
          if (decoded['text'] is String) return decoded['text'];
          if (decoded['output'] is String) return decoded['output'];
          if (decoded['choices'] is List && decoded['choices'].isNotEmpty) {
            final c = decoded['choices'][0];
            if (c is Map) {
              if (c['content'] is List && c['content'].isNotEmpty) {
                final first = c['content'][0];
                if (first is Map && first['text'] is String) return first['text'];
              }
              if (c['text'] is String) return c['text'];
            }
          }
        }
      } catch (_) {}
      return resp.body;
    } else {
      throw Exception('Ollama request failed: ${resp.statusCode} ${resp.body}');
    }
  }
}
