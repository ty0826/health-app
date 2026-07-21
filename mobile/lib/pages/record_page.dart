import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/loading_view.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  static const _fields = [
    ('steps', '🚶', '步数', '请输入今日步数'),
    ('heartRate', '❤️', '心率', '次/分钟'),
    ('sleepHours', '😴', '睡眠', '小时'),
    ('weight', '⚖️', '体重', 'kg'),
    ('systolicBp', '🫀', '收缩压', 'mmHg'),
    ('diastolicBp', '🩺', '舒张压', 'mmHg'),
    ('bloodSugar', '🩸', '血糖', 'mmol/L'),
    ('calories', '🔥', '热量消耗', 'kcal'),
    ('waterIntake', '💧', '饮水量', 'ml'),
  ];
  static const _moods = [
    (5, '😄', '很好'),
    (4, '😊', '不错'),
    (3, '😐', '一般'),
    (2, '😟', '较差'),
    (1, '😫', '很差'),
  ];

  final Map<String, TextEditingController> _controllers = {
    for (final field in _fields) field.$1: TextEditingController(),
  };
  final TextEditingController _note = TextEditingController();
  int _mood = 3;
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    const decimals = {'sleepHours', 'weight', 'bloodSugar'};
    final now = DateTime.now();
    final body = <String, dynamic>{
      'recordDate':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'mood': _mood,
      'note': _note.text,
    };
    for (final entry in _controllers.entries) {
      body[entry.key] = decimals.contains(entry.key)
          ? double.tryParse(entry.value.text) ?? 0
          : int.tryParse(entry.value.text) ?? 0;
    }
    try {
      await widget.api.post('/health/record', body);
      if (!mounted) return;
      showAppMessage(context, '记录成功！');
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return AppPage(
      title: '健康数据录入',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('📅', style: TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.xs),
              Text('${now.year}年${now.month}月${now.day}日',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          _section(
            '📋 健康指标',
            Column(
              children: [
                for (var index = 0; index < _fields.length; index++) ...[
                  _field(_fields[index]),
                  if (index != _fields.length - 1) const Divider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _section(
            '🎭 今日心情',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((item) {
                final selected = item.$1 == _mood;
                return InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  onTap: () => setState(() => _mood = item.$1),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xffeef2ff)
                          : Colors.transparent,
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Column(children: [
                      Text(item.$2, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(item.$3,
                          style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _section(
            '📝 备注',
            TextField(
              controller: _note,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(hintText: '记录今天的健康状况...'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? '提交中...' : '✅ 保存记录'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      );

  Widget _field((String, String, String, String) field) => Row(
        children: [
          SizedBox(
            width: 112,
            child: Row(children: [
              Text(field.$2, style: const TextStyle(fontSize: 19)),
              const SizedBox(width: AppSpacing.xs),
              Text(field.$3, style: const TextStyle(fontSize: 13)),
            ]),
          ),
          Expanded(
            child: TextField(
              controller: _controllers[field.$1],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: field.$4,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      );
}
