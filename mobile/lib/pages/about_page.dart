import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Map<String, dynamic>? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await widget.api.get('/system/app-info');
      if (mounted) setState(() => _info = value as Map<String, dynamic>);
    } on ApiException {
      // The same fallback copy as Taro keeps this informational page usable offline.
    }
  }

  String _value(String key, String fallback) => '${_info?[key] ?? fallback}';

  @override
  Widget build(BuildContext context) {
    final features = [
      ('📊', '数据可视化', '直观的图表展示，帮助您了解健康趋势'),
      ('🤖', 'AI 智能分析', '基于大模型的个性化健康建议'),
      ('📱', '多端适配', '支持小程序、H5、App 多平台使用'),
      ('🔒', '数据安全', '端到端加密传输，保障您的隐私安全'),
    ];
    final tech = [
      ('前端技术', _value('techFrontend', 'Taro + React / Flutter')),
      ('后端技术', _value('techBackend', 'Spring Boot')),
      ('AI 引擎', _value('techAi', 'GPT')),
      ('数据分析', _value('techData', 'ECharts')),
    ];
    return AppPage(
      title: '关于我们',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Column(children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Color(0xffe0e7ff), shape: BoxShape.circle),
            child: const Text('💚', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(_value('appName', '健康管家'),
              style:
                  const TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(_value('appSlogan', 'AI 驱动的个人健康管理平台'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 5),
          Text('Version ${_value('version', '1.0.0')}',
              style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        ]),
        const SizedBox(height: AppSpacing.md),
        _section(
            '核心功能',
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              childAspectRatio: 1.35,
              children: features
                  .map((item) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSmall)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.$1,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(item.$2,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              const SizedBox(height: 3),
                              Text(item.$3,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      height: 1.4)),
                            ]),
                      ))
                  .toList(),
            )),
        const SizedBox(height: AppSpacing.sm),
        _section(
            '技术架构',
            Column(children: [
              for (var index = 0; index < tech.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tech[index].$1,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        Text(tech[index].$2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                ),
                if (index != tech.length - 1) const Divider(),
              ],
            ])),
        const SizedBox(height: AppSpacing.sm),
        _section(
            '联系我们',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _contact('📧', _value('email', 'support@healthmanager.com')),
              _contact('🌐', _value('website', 'www.healthmanager.com')),
              _contact('📍', _value('address', '中国 · 深圳')),
            ])),
        const SizedBox(height: AppSpacing.md),
        Text(_value('copyright', '© 2026 健康管家'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 4),
        const Text('用户协议 | 隐私政策',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.primary, fontSize: 12)),
      ]),
    );
  }

  Widget _section(String title, Widget child) => AppCard(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          child,
        ]),
      );

  Widget _contact(String icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Text(icon),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)))
        ]),
      );
}
