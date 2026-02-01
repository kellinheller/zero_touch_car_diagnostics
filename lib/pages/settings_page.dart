import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = SettingsService();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  bool _useGemini = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _settings.getGeminiApiKey();
    final model = await _settings.getGeminiModel();
    final useGemini = await _settings.getUseGemini();

    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _modelController.text = model;
      _useGemini = useGemini;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _settings.saveGeminiApiKey(_apiKeyController.text);
    await _settings.saveGeminiModel(_modelController.text);
    await _settings.setUseGemini(_useGemini);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  Future<void> _openGeminiApiKeyHelp() async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Gemini Configuration Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Gemini AI Configuration',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Use Gemini AI'),
                    subtitle: const Text('Enable AI-powered diagnostics with Google Gemini'),
                    value: _useGemini,
                    onChanged: (value) => setState(() => _useGemini = value),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Gemini API Key',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text('Get API Key'),
                        onPressed: _openGeminiApiKeyHelp,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Gemini API key',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                      helperText: 'Free tier available at Google AI Studio',
                    ),
                    obscureText: true,
                    enabled: _useGemini,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Model',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _modelController.text.isEmpty ? 'gemini-2.5-pro' : _modelController.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.memory),
                      helperText: 'Gemini 2.5 Pro free tier is recommended',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'gemini-2.5-pro',
                        child: Text('Gemini 2.5 Pro (Free Tier, Recommended)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-2.0-flash-exp',
                        child: Text('Gemini 2.0 Flash'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-1.5-pro',
                        child: Text('Gemini 1.5 Pro'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-1.5-flash',
                        child: Text('Gemini 1.5 Flash'),
                      ),
                    ],
                    onChanged: _useGemini
                        ? (value) {
                            if (value != null) {
                              _modelController.text = value;
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'How to get your free API key:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Visit Google AI Studio (ai.google.dev)\n'
                          '2. Sign in with your Google account\n'
                          '3. Click "Get API Key" in the left menu\n'
                          '4. Create a new API key\n'
                          '5. Copy and paste it above',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '✓ Free tier: 1,500 requests per day\n'
                          '✓ Gemini 2.5 Pro free tier recommended',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}
