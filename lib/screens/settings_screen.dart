// lib/screens/settings_screen.dart
// Allows the user to switch AI provider and enter their API key at runtime.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _openaiKeyCtrl  = TextEditingController();
  final _geminiKeyCtrl  = TextEditingController();
  AIProvider _provider  = AIProvider.gemini;
  bool _obscureOpenAI   = true;
  bool _obscureGemini   = true;

  static const String _kProvider    = 'ai_provider';
  static const String _kOpenAIKey   = 'openai_key';
  static const String _kGeminiKey   = 'gemini_key';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _provider = (prefs.getString(_kProvider) ?? 'gemini') == 'openai'
          ? AIProvider.openai
          : AIProvider.gemini;
      _openaiKeyCtrl.text = prefs.getString(_kOpenAIKey) ?? '';
      _geminiKeyCtrl.text = prefs.getString(_kGeminiKey) ?? '';
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProvider,
        _provider == AIProvider.openai ? 'openai' : 'gemini');
    await prefs.setString(_kOpenAIKey, _openaiKeyCtrl.text.trim());
    await prefs.setString(_kGeminiKey, _geminiKeyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ SAVED. Restart to apply changes.',
              style: AppTheme.terminalSmall),
          backgroundColor: AppTheme.bgCard,
        ),
      );
      Navigator.pop(context, true); // return true = settings changed
    }
  }

  @override
  void dispose() {
    _openaiKeyCtrl.dispose();
    _geminiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        title: Text('CONFIG', style: AppTheme.displayFont),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppTheme.neonGreen, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1, color: AppTheme.neonGreen.withOpacity(0.2)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _label('// AI PROVIDER'),
          const SizedBox(height: 10),
          _ProviderTile(
            label: 'GOOGLE GEMINI',
            subtitle: 'gemini-1.5-flash',
            selected: _provider == AIProvider.gemini,
            onTap: () => setState(() => _provider = AIProvider.gemini),
          ),
          const SizedBox(height: 8),
          _ProviderTile(
            label: 'OPENAI',
            subtitle: 'gpt-4o-mini',
            selected: _provider == AIProvider.openai,
            onTap: () => setState(() => _provider = AIProvider.openai),
          ),
          const SizedBox(height: 24),
          _label('// API KEYS'),
          const SizedBox(height: 12),
          _keyField(
            label:      'GEMINI API KEY',
            controller: _geminiKeyCtrl,
            obscure:    _obscureGemini,
            onToggle:   () => setState(() => _obscureGemini = !_obscureGemini),
            hint:       'AIza...',
          ),
          const SizedBox(height: 12),
          _keyField(
            label:      'OPENAI API KEY',
            controller: _openaiKeyCtrl,
            obscure:    _obscureOpenAI,
            onToggle:   () => setState(() => _obscureOpenAI = !_obscureOpenAI),
            hint:       'sk-...',
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.neonGreen),
                color:  AppTheme.neonGreenFade,
              ),
              alignment: Alignment.center,
              child: Text('[ SAVE CONFIG ]', style: AppTheme.terminalLarge),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '// Keys are stored locally on device.\n// Get Gemini key: aistudio.google.com\n// Get OpenAI key: platform.openai.com',
            style: AppTheme.terminalTiny,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: AppTheme.terminalSmall.copyWith(
          color: AppTheme.neonGreenDim));

  Widget _keyField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.terminalTiny),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTheme.terminalSmall,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textDim,
                  size: 18),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ProviderTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.neonGreenFade : AppTheme.bgCard,
            border: Border.all(
              color: selected
                  ? AppTheme.neonGreen.withOpacity(0.7)
                  : AppTheme.neonGreen.withOpacity(0.15),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppTheme.neonGreen : AppTheme.textDim,
                size: 16,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTheme.terminalSmall.copyWith(
                          color: selected
                              ? AppTheme.neonGreen
                              : AppTheme.textSecondary)),
                  Text(subtitle, style: AppTheme.terminalTiny),
                ],
              ),
            ],
          ),
        ),
      );
}
