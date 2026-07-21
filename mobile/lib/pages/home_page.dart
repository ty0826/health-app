import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/health_metric_card.dart';
import '../widgets/loading_view.dart';
import 'record_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api, required this.onSelectTab});
  final ApiClient api;
  final ValueChanged<int> onSelectTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserInfo? _user;
  HealthRecord? _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        widget.api.get('/user/info'),
        widget.api.get('/health/today'),
      ]);
      if (!mounted) return;
      setState(() {
        _user = UserInfo.fromJson(values[0] as Map<String, dynamic>);
        _record = values[1] == null
            ? null
            : HealthRecord.fromJson(values[1] as Map<String, dynamic>);
      });
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openRecord() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecordPage(api: widget.api)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('健康管家')),
        body: _loading
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  children: [
                    _header(),
                    _section(
                      title: '快捷操作',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _quickAction('📝', '记录数据', const Color(0xffeef2ff),
                              _openRecord),
                          _quickAction('📊', '数据分析', const Color(0xfffef3c7),
                              () => widget.onSelectTab(1)),
                          _quickAction('⚙️', '我的设置', const Color(0xfffce7f3),
                              () => widget.onSelectTab(3)),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('今日健康',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              TextButton(
                                  onPressed: _openRecord,
                                  child: const Text('记录 →')),
                            ],
                          ),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 1.55,
                            children: [
                              _metric('🚶', '步数', _record?.steps, '步',
                                  AppColors.primary),
                              _metric('❤️', '心率', _record?.heartRate, 'bpm',
                                  AppColors.danger),
                              _metric('😴', '睡眠', _record?.sleepHours, '小时',
                                  const Color(0xff8b5cf6)),
                              _metric('⚖️', '体重', _record?.weight, 'kg',
                                  AppColors.success),
                              _metric('🩸', '血糖', _record?.bloodSugar, 'mmol/L',
                                  AppColors.warning),
                              _metric('🔥', '热量', _record?.calories, 'kcal',
                                  const Color(0xfff97316)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: AppCard(
                        border: const Border(
                            left:
                                BorderSide(color: AppColors.warning, width: 4)),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('💡', style: TextStyle(fontSize: 24)),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('今日健康提示',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text(
                                    '建议每天饮水 2000ml 以上，保持充足睡眠 7-8 小时，有助于提升免疫力。',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.6,
                                        fontSize: 13),
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
              ),
      );

  Widget _header() {
    final now = DateTime.now();
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final name = _user?.nickname.isNotEmpty == true ? _user!.nickname : '用户';
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, AppSpacing.md),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusLarge),
          bottomRight: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('你好，$name 👋',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        '${now.month}月${now.day}日 ${weekdays[now.weekday - 1]}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .8),
                            fontSize: 13)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: .25),
                child: Text(name.substring(0, 1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(AppSpacing.radius)),
            child: Row(
              children: [
                const SizedBox(
                  width: 72,
                  child: Column(children: [
                    Text('86',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 1,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('健康评分',
                        style:
                            TextStyle(color: Color(0xccffffff), fontSize: 11)),
                  ]),
                ),
                Container(
                    width: 1,
                    height: 48,
                    color: Colors.white.withValues(alpha: .2)),
                Expanded(child: _score('${_record?.steps ?? 0}', '今日步数')),
                Expanded(child: _score('${_record?.sleepHours ?? 0}h', '睡眠时长')),
                Expanded(child: _score('${_record?.calories ?? 0}', '消耗热量')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _score(String value, String label) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: .7), fontSize: 10)),
      ]);

  Widget _section({required String title, required Widget child}) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          child,
        ]),
      );

  Widget _quickAction(
          String icon, String label, Color color, VoidCallback onTap) =>
      InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSpacing.radius)),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ]),
      );

  Widget _metric(
          String icon, String label, num? value, String unit, Color color) =>
      HealthMetricCard(
        icon: icon,
        label: label,
        value: value == null || value == 0 ? '--' : '$value',
        unit: unit,
        color: color,
      );
}
