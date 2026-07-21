import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'pages/login_page.dart';
import 'pages/main_shell.dart';
import 'theme/app_theme.dart';

class HealthManagerApp extends StatefulWidget {
  const HealthManagerApp({super.key});

  @override
  State<HealthManagerApp> createState() => _HealthManagerAppState();
}

class _HealthManagerAppState extends State<HealthManagerApp> {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _ready = false;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    _api.token = await _storage.read(key: 'token');
    if (!mounted) return;
    setState(() {
      _ready = true;
      _signedIn = _api.token?.isNotEmpty == true;
    });
  }

  Future<void> _onLogin(String token) async {
    _api.token = token;
    await _storage.write(key: 'token', value: token);
    if (mounted) setState(() => _signedIn = true);
  }

  Future<void> _onLogout() async {
    _api.token = null;
    await _storage.delete(key: 'token');
    if (mounted) setState(() => _signedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康管家',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: !_ready
          ? const _StartupView()
          : _signedIn
              ? MainShell(api: _api, onLogout: _onLogout)
              : LoginPage(api: _api, onLogin: _onLogin),
    );
  }
}

class _StartupView extends StatelessWidget {
  const _StartupView();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
