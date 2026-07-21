import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/loading_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.api, required this.onLogin});
  final ApiClient api;
  final Future<void> Function(String token) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  bool _isLogin = true;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      showAppMessage(context, '请填写完整信息');
      return;
    }
    if (!_isLogin && _nickname.text.trim().isEmpty) {
      showAppMessage(context, '请填写昵称');
      return;
    }
    setState(() => _busy = true);
    try {
      if (_isLogin) {
        final data = await widget.api.post('/user/login', {
          'username': _username.text.trim(),
          'password': _password.text,
        }) as Map<String, dynamic>;
        await widget.onLogin('${data['token']}');
      } else {
        await widget.api.post('/user/register', {
          'username': _username.text.trim(),
          'password': _password.text,
          'nickname': _nickname.text.trim(),
        });
        if (!mounted) return;
        setState(() => _isLogin = true);
        showAppMessage(context, '注册成功，请登录');
      }
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('💚', style: TextStyle(fontSize: 44)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        '健康管家',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'AI 驱动的个人健康管理平台',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .82)),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLarge),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 28,
                                offset: Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _tab('登录', _isLogin,
                                    () => setState(() => _isLogin = true)),
                                _tab('注册', !_isLogin,
                                    () => setState(() => _isLogin = false)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _username,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline),
                                  hintText: '请输入用户名'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _password,
                              obscureText: true,
                              textInputAction: _isLogin
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              onSubmitted: _isLogin ? (_) => _submit() : null,
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: '请输入密码'),
                            ),
                            if (!_isLogin) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _nickname,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.mood_outlined),
                                    hintText: '请输入昵称'),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            FilledButton(
                              onPressed: _busy ? null : _submit,
                              child: Text(
                                  _busy ? '请稍候...' : (_isLogin ? '登录' : '注册')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '健康生活，从记录开始',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .72)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: _busy ? null : onTap,
          child: Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: active ? AppColors.primary : AppColors.border,
                      width: active ? 2 : 1)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400),
            ),
          ),
        ),
      );
}
