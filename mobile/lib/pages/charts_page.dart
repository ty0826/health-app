import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_view.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  static const _metrics = [
    ('steps', '🚶', '步数', '步', AppColors.primary),
    ('heartRate', '❤️', '心率', 'bpm', AppColors.danger),
    ('sleep', '😴', '睡眠', '小时', Color(0xff8b5cf6)),
    ('weight', '⚖️', '体重', 'kg', AppColors.success),
  ];

  Map<String, dynamic>? _stats;
  int _days = 7;
  int _metricIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final value =
          await widget.api.get('/health/stats', query: {'days': _days});
      if (mounted) setState(() => _stats = value as Map<String, dynamic>);
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<num> get _values {
    final key = switch (_metrics[_metricIndex].$1) {
      'steps' => 'weeklySteps',
      'heartRate' => 'weeklyHeartRate',
      'sleep' => 'weeklySleep',
      _ => 'monthlyWeight',
    };
    return ((_stats?[key] as List?) ?? const []).whereType<num>().toList();
  }

  List<String> get _labels {
    final key =
        _metrics[_metricIndex].$1 == 'weight' ? 'monthDates' : 'weekDates';
    return ((_stats?[key] as List?) ?? const [])
        .map((value) => '$value')
        .toList();
  }

  String _summary(String mode) {
    if (_values.isEmpty) return '--';
    if (mode == 'max') return '${_values.reduce((a, b) => a > b ? a : b)}';
    if (mode == 'min') return '${_values.reduce((a, b) => a < b ? a : b)}';
    final average =
        _values.fold<double>(0, (sum, value) => sum + value) / _values.length;
    return average.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final metric = _metrics[_metricIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('数据分析')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          children: [
            _periodTabs(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: List.generate(_metrics.length, (index) {
                final item = _metrics[index];
                final active = index == _metricIndex;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: index == _metrics.length - 1 ? 0 : 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      onTap: () => setState(() => _metricIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: active ? item.$5 : Colors.white,
                          border: Border.all(
                              color: active ? item.$5 : AppColors.border),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radius),
                        ),
                        child: Column(children: [
                          Text(item.$2, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(item.$3,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: active
                                      ? Colors.white
                                      : AppColors.textSecondary)),
                        ]),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_loading)
              const SizedBox(height: 320, child: LoadingView())
            else ...[
              Row(children: [
                Expanded(
                    child: _stat(
                        '平均值', _summary('average'), metric.$4, metric.$5)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                    child: _stat(
                        '最高值', _summary('max'), metric.$4, AppColors.success)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                    child: _stat(
                        '最低值', _summary('min'), metric.$4, AppColors.warning)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${metric.$2} ${metric.$3}趋势',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(height: 220, child: _barChart(metric.$5)),
                    ]),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 数据洞察',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      _insight(AppColors.success,
                          '平均${metric.$3}为 ${_summary('average')} ${metric.$4}'),
                      _insight(AppColors.warning, '与上周相比呈稳定趋势，请继续保持！'),
                      _insight(AppColors.danger, '建议通过 AI 助手获取个性化健康建议'),
                    ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _periodTabs() => AppCard(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _period('近一周', 7),
            _period('近一月', 30),
          ],
        ),
      );

  Widget _period(String label, int days) {
    final active = _days == days;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          if (_days == days) return;
          setState(() => _days = days);
          _load();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, String unit, Color color) => AppCard(
        padding:
            const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 6),
        child: Column(children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              style: TextStyle(
                  color: color, fontSize: 21, fontWeight: FontWeight.w800)),
          Text(unit,
              style: const TextStyle(color: AppColors.textLight, fontSize: 10)),
        ]),
      );

  Widget _barChart(Color color) {
    if (_values.isEmpty) {
      return const Center(
          child: Text('暂无健康数据', style: TextStyle(color: AppColors.textLight)));
    }
    final maximum = _values.reduce((a, b) => a > b ? a : b).toDouble();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_values.length, (index) {
        final value = _values[index];
        final height = maximum == 0 ? 0.0 : value / maximum * 150;
        final label = index < _labels.length ? _labels[index] : '';
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$value',
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                  width: 18,
                  height: height.clamp(2, 150),
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5)))),
              const SizedBox(height: 6),
              Text(label.length > 5 ? label.substring(label.length - 5) : label,
                  maxLines: 1,
                  style:
                      const TextStyle(fontSize: 8, color: AppColors.textLight)),
            ],
          ),
        );
      }),
    );
  }

  Widget _insight(Color color, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13))),
        ]),
      );
}
