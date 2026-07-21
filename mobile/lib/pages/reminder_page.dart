import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/loading_view.dart';

class _ReminderItem {
  const _ReminderItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.enabled,
    required this.time,
  });

  final int id;
  final String icon;
  final String label;
  final String description;
  final bool enabled;
  final String time;

  factory _ReminderItem.fromJson(Map<String, dynamic> json) => _ReminderItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        icon: '${json['icon'] ?? '🔔'}',
        label: '${json['label'] ?? json['reminderType'] ?? '健康提醒'}',
        description: '${json['description'] ?? ''}',
        enabled: json['enabled'] == 1 || json['enabled'] == true,
        time: '${json['reminderTime'] ?? '08:00'}',
      );

  _ReminderItem copyWith({bool? enabled, String? time}) => _ReminderItem(
        id: id,
        icon: icon,
        label: label,
        description: description,
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<_ReminderItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await widget.api.get('/reminder/list');
      if (mounted) {
        setState(() => _items = ((value as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_ReminderItem.fromJson)
            .toList());
      }
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update(_ReminderItem item,
      {bool? enabled, String? time}) async {
    final next = item.copyWith(enabled: enabled, time: time);
    try {
      await widget.api.put('/reminder/${item.id}', {
        'enabled': next.enabled ? 1 : 0,
        'reminderTime': next.time,
      });
      if (!mounted) return;
      setState(() => _items = _items
          .map((current) => current.id == item.id ? next : current)
          .toList());
      if (enabled == true) showAppMessage(context, '已开启${item.label}');
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    }
  }

  Future<void> _pickTime(_ReminderItem item) async {
    final parts = item.time.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 8,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (picked == null) return;
    await _update(item,
        time:
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
  }

  @override
  Widget build(BuildContext context) => AppPage(
        title: '提醒设置',
        child: _loading
            ? const SizedBox(height: 320, child: LoadingView())
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const AppCard(
                  color: Color(0xfffffbeb),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 22)),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                            child: Text(
                                '开启提醒后，系统将在指定时间通过微信服务通知提醒您。请确保已授权消息通知权限。',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                    fontSize: 13))),
                      ]),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: _items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: Text('暂无提醒设置')))
                      : Column(children: [
                          for (var index = 0;
                              index < _items.length;
                              index++) ...[
                            _tile(_items[index]),
                            if (index != _items.length - 1)
                              const Divider(indent: 58),
                          ],
                        ]),
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('温馨提示',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                            '• 提醒功能依赖微信订阅消息，首次使用需要授权\n• 提醒时间设置后将在每天固定时段推送\n• 关闭提醒后将不再收到对应消息',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.7)),
                      ]),
                ),
              ]),
      );

  Widget _tile(_ReminderItem item) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(children: [
          Text(item.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (item.description.isNotEmpty)
                  Text(item.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
              ])),
          TextButton(
              onPressed: () => _pickTime(item),
              child: Text(item.time,
                  style: TextStyle(
                      color: item.enabled
                          ? AppColors.primary
                          : AppColors.textLight))),
          Switch(
              value: item.enabled,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => _update(item, enabled: value)),
        ]),
      );
}
