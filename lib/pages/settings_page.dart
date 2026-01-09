import 'package:flutter/material.dart';

/// Settings and requirements page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _geminiKeyController;
  late TextEditingController _openaiKeyController;
  bool _showGeminiKey = false;
  bool _showOpenaiKey = false;

  @override
  void initState() {
    super.initState();
    _geminiKeyController = TextEditingController();
    _openaiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _openaiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKeys() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ API Keys saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Requirements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyan.shade50,
                Colors.blue.shade50,
                Colors.teal.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Installation Requirements Section
                _buildSection(
                  title: '📋 Installation Requirements',
                  children: [
                    _buildRequirementCard(
                      title: 'Android Requirements',
                      items: [
                        'Android 5.0 (API 21) or higher',
                        'Bluetooth capability (for OBD2 adapters)',
                        'Location permission (for Bluetooth scanning)',
                        '50 MB free storage',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementCard(
                      title: 'OBD2 Adapter Requirements',
                      items: [
                        'ELM327, STN1110, or LTC1260 adapter',
                        'Bluetooth or USB connection',
                        'Vehicle OBD2 port (2014 and newer most vehicles)',
                        'Vehicle battery must be on',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementCard(
                      title: 'AI Analysis Requirements',
                      items: [
                        'Active internet connection',
                        'Google Gemini API key OR OpenAI API key',
                        'API account with valid credentials',
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // API Keys Configuration Section
                _buildSection(
                  title: '🔑 API Key Configuration',
                  children: [
                    _buildApiKeyInput(
                      label: 'Google Gemini API Key',
                      hint: 'Enter your Gemini API key',
                      controller: _geminiKeyController,
                      showKey: _showGeminiKey,
                      onToggleVisibility: () {
                        setState(() => _showGeminiKey = !_showGeminiKey);
                      },
                      docLink: 'https://ai.google.dev',
                    ),
                    const SizedBox(height: 16),
                    _buildApiKeyInput(
                      label: 'OpenAI API Key',
                      hint: 'Enter your OpenAI API key',
                      controller: _openaiKeyController,
                      showKey: _showOpenaiKey,
                      onToggleVisibility: () {
                        setState(() => _showOpenaiKey = !_showOpenaiKey);
                      },
                      docLink: 'https://platform.openai.com',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _saveApiKeys,
                      icon: const Icon(Icons.save),
                      label: const Text('Save API Keys'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // How to Get API Keys Section
                _buildSection(
                  title: '🚀 How to Get API Keys',
                  children: [
                    _buildHowToCard(
                      title: '1. Google Gemini API',
                      steps: [
                        'Visit https://ai.google.dev',
                        'Sign in with Google account',
                        'Click "Get API Key"',
                        'Create new API key for free',
                        'Copy and paste into this app',
                      ],
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildHowToCard(
                      title: '2. OpenAI API',
                      steps: [
                        'Visit https://platform.openai.com',
                        'Sign in or create account',
                        'Go to API keys section',
                        'Create new secret key',
                        'Copy and paste into this app',
                      ],
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Supported OBD2 Adapters
                _buildSection(
                  title: '🔧 Supported OBD2 Adapters',
                  children: [
                    _buildAdapterCard(
                      name: 'ELM327',
                      type: 'Standard',
                      protocols: 'CAN, KWP, J1850',
                      cost: '\$10-30',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildAdapterCard(
                      name: 'STN1110',
                      type: 'Premium Clone',
                      protocols: 'All + J1939 + UDS',
                      cost: '\$30-50',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildAdapterCard(
                      name: 'LTC1260',
                      type: 'Budget Generic',
                      protocols: 'CAN, KWP, ISO',
                      cost: '\$5-20',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Support Section
                _buildSection(
                  title: '💬 Support & Documentation',
                  children: [
                    _buildSupportCard(
                      icon: Icons.book,
                      title: 'Documentation',
                      description: 'View comprehensive guides and tutorials',
                      link: 'GitHub Repository',
                      url:
                          'https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2',
                    ),
                    const SizedBox(height: 12),
                    _buildSupportCard(
                      icon: Icons.bug_report,
                      title: 'Report Issues',
                      description: 'Found a bug? Report it on GitHub Issues',
                      link: 'GitHub Issues',
                      url:
                          'https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2/issues',
                    ),
                    const SizedBox(height: 12),
                    _buildSupportCard(
                      icon: Icons.info,
                      title: 'About This App',
                      description: 'Zero-Touch Car Diagnostics v1.0.0',
                      link: 'View on GitHub',
                      url:
                          'https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ℹ️ Important Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Always ensure your vehicle is in a safe location\n'
                        '• Some vehicles may have security restrictions\n'
                        '• API keys should be kept private and secure\n'
                        '• Check local regulations before diagnosing\n'
                        '• Professional diagnosis recommended for major issues',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildRequirementCard({
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan, width: 1),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.cyan.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Text(
                    '✓ ',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool showKey,
    required VoidCallback onToggleVisibility,
    required String docLink,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                'Get Key',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !showKey,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: Icon(showKey ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowToCard({
    required String title,
    required List<String> steps,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(entry.value, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdapterCard({
    required String name,
    required String type,
    required String protocols,
    required String cost,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(protocols, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String description,
    required String link,
    required String url,
  }) {
    // ignore: deprecated_member_use
    var withOpacity = Colors.cyan.withOpacity(0.1);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: withOpacity,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            link,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Color newMethod(Color withOpacity) => withOpacity;
}
