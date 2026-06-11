// lib/main.dart
// CIPHER.AI — Kaviya's Hacker Terminal Assistant
// Entry point: loads config, builds AIService, launches chat.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/ai_service.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode — terminal aesthetic
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive dark system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    systemNavigationBarColor:  AppTheme.bgPrimary,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Load .env (gracefully skip if absent — runtime keys take over)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Request mic permission early
  await Permission.microphone.request();

  runApp(const KaviyaApp());
}

class KaviyaApp extends StatelessWidget {
  const KaviyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:        'CIPHER.AI',
      debugShowCheckedModeBanner: false,
      theme:        AppTheme.theme,
      home:         const _AppLoader(),
    );
  }
}

// ── App Loader ────────────────────────────────────────────────────────────────
// Reads saved prefs (or .env fallback) to build the AIService,
// then hands off to the real UI.
class _AppLoader extends StatefulWidget {
  const _AppLoader();
  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  AIService? _service;
  bool _noKeyConfigured = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();

    // Provider: SharedPrefs → .env → default gemini
    final providerStr = prefs.getString('ai_provider')
        ?? dotenv.env['AI_PROVIDER']
        ?? 'gemini';
    final provider = providerStr == 'openai'
        ? AIProvider.openai
        : AIProvider.gemini;

    // API key: SharedPrefs → .env
    final String apiKey;
    if (provider == AIProvider.openai) {
      apiKey = prefs.getString('openai_key')?.isNotEmpty == true
          ? prefs.getString('openai_key')!
          : (dotenv.env['OPENAI_API_KEY'] ?? '');
    } else {
      apiKey = prefs.getString('gemini_key')?.isNotEmpty == true
          ? prefs.getString('gemini_key')!
          : (dotenv.env['GEMINI_API_KEY'] ?? '');
    }

    if (apiKey.isEmpty ||
        apiKey.contains('your_') ||
        apiKey.length < 10) {
      setState(() => _noKeyConfigured = true);
      return;
    }

    setState(() {
      _service = AIService(provider: provider, apiKey: apiKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── No API key — show config screen first ──────────────────────────────
    if (_noKeyConfigured) {
      return _NoKeyScreen(onConfigured: () async {
        setState(() {
          _service = null;
          _noKeyConfigured = false;
        });
        await _initService();
      });
    }

    // ── Loading ────────────────────────────────────────────────────────────
    if (_service == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CIPHER.AI', style: AppTheme.displayFont),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.textDim,
                  valueColor:
                      const AlwaysStoppedAnimation(AppTheme.neonGreen),
                ),
              ),
              const SizedBox(height: 12),
              Text('BOOTING...', style: AppTheme.terminalTiny),
            ],
          ),
        ),
      );
    }

    // ── Main app with settings button ──────────────────────────────────────
    return _MainShell(service: _service!, onRebuild: _initService);
  }
}

// ── Main Shell: wraps ChatScreen + settings nav ───────────────────────────────
class _MainShell extends StatelessWidget {
  final AIService service;
  final VoidCallback onRebuild;

  const _MainShell({required this.service, required this.onRebuild});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      // Settings gear in the app bar is handled inside ChatScreen's header,
      // but we wrap here to allow nav push to SettingsScreen.
      body: Stack(
        children: [
          ChatScreen(aiService: service),
          // Floating settings button (top-right corner, above ChatScreen's header)
          Positioned(
            right: 0,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: AppTheme.textDim, size: 18),
              tooltip: 'Config',
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
                if (changed == true) onRebuild();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── No-key splash ─────────────────────────────────────────────────────────────
class _NoKeyScreen extends StatelessWidget {
  final VoidCallback onConfigured;
  const _NoKeyScreen({required this.onConfigured});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CIPHER.AI', style: AppTheme.displayFont),
              const SizedBox(height: 6),
              Text('[ KAVIYA\'S TERMINAL ]', style: AppTheme.terminalTiny),
              const Divider(color: AppTheme.borderColor, height: 40),
              Text(
                '// API KEY NOT FOUND\n\n'
                'මචං, API key එකක් නෑ! ⚡\n'
                'Settings එකෙන් key එකක් දාලා start කරමු.',
                style: AppTheme.terminalSmall,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                  if (changed == true) onConfigured();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.neonGreen),
                    color: AppTheme.neonGreenFade,
                  ),
                  alignment: Alignment.center,
                  child: Text('[ ENTER API KEY ]',
                      style: AppTheme.terminalLarge),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '// Gemini free tier: aistudio.google.com\n// OpenAI: platform.openai.com',
                style: AppTheme.terminalTiny,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
