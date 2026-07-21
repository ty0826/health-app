import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_view.dart';
import 'about_page.dart';
import 'edit_profile_page.dart';
import 'export_page.dart';
import 'help_page.dart';
import 'record_page.dart';
import 'reminder_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.api,
    required this.onLogout,
    required this.onSelectTab,
  });
  final ApiClient api;
  final Future<void> Function() onLogout;
  final ValueChanged<int> onSelectTab;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserInfo? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await widget.api.get('/user/info');
      if (mounted) {
        setState(
            () => _user = UserInfo.fromJson(value as Map<String, dynamic>));
      }
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    }
  }

  Future<void> _push(Widget page, {bool refresh = false}) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (refresh) await _load();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定')),
        ],
      ),
    );
    if (confirmed == true) await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.nickname.isNotEmpty == true ? _user!.nickname : '用户';
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: Column(children: [
                InkWell(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusLarge)),
                  onTap: () => _push(
                      EditProfilePage(api: widget.api, user: _user),
                      refresh: true),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withValues(alpha: .24),
                        child: Text(name.substring(0, 1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('ID: ${_user?.id ?? '--'}',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: .75),
                                    fontSize: 12)),
                          ])),
                      const Text('编辑 ›', style: TextStyle(color: Colors.white)),
                    ]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppSpacing.radiusLarge))),
                  child: Row(children: [
                    _profileStat(
                        '${_user?.age == 0 ? '--' : _user?.age ?? '--'}', '年龄'),
                    _divider(),
                    _profileStat(
                        '${_user?.height == 0 ? '--' : _user?.height ?? '--'}',
                        '身高 cm'),
                    _divider(),
                    _profileStat(
                        '${_user?.weight == 0 ? '--' : _user?.weight ?? '--'}',
                        '体重 kg'),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: const Row(children: [
                Expanded(
                    child:
                        _Overview(icon: '📅', value: '128', label: '连续记录天数')),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: _Overview(icon: '🏆', value: '86', label: '健康评分')),
              ]),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _menu('📊', '我的健康报告', () => widget.onSelectTab(1)),
                _menu('📋', '历史记录', () => _push(RecordPage(api: widget.api))),
                _menu('🔔', '提醒设置', () => _push(ReminderPage(api: widget.api))),
                _menu('📎', '数据导出', () => _push(ExportPage(api: widget.api))),
                _menu('❓', '帮助中心', () => _push(HelpPage(api: widget.api))),
                _menu('⭐', '关于我们', () => _push(AboutPage(api: widget.api)),
                    last: true),
              ]),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.danger,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius)),
              ),
              child: const Text('退出登录'),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _profileStat(String value, String label) => Expanded(
          child: Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: .72), fontSize: 11)),
      ]));

  Widget _divider() => Container(
      width: 1, height: 34, color: Colors.white.withValues(alpha: .2));

  Widget _menu(String icon, String label, VoidCallback onTap,
          {bool last = false}) =>
      Column(children: [
        ListTile(
          onTap: onTap,
          leading: Text(icon, style: const TextStyle(fontSize: 21)),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: const Text('›',
              style: TextStyle(color: AppColors.textLight, fontSize: 24)),
        ),
        if (!last) const Divider(indent: 56),
      ]);
}

class _Overview extends StatelessWidget {
  const _Overview(
      {required this.icon, required this.value, required this.label});
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: AppSpacing.xs),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ]),
      ]);
}
