import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/loading_view.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  static const _formats = [('csv', 'CSV 表格'), ('json', 'JSON 数据')];
  static const _ranges = [
    (7, '最近 7 天'),
    (30, '最近 30 天'),
    (90, '最近 90 天'),
    (9999, '全部数据')
  ];
  String _format = 'csv';
  int _days = 30;
  bool _exporting = false;
  int? _exportedCount;

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _exportedCount = null;
    });
    try {
      final value = await widget.api
          .get('/health/export', query: {'days': _days, 'format': _format});
      final result = value as Map<String, dynamic>;
      final count = (result['totalRecords'] as num?)?.toInt() ?? 0;
      if (count == 0) {
        if (mounted) showAppMessage(context, '暂无数据可导出');
        return;
      }
      await Clipboard.setData(
          ClipboardData(text: '${result['content'] ?? ''}'));
      if (!mounted) return;
      setState(() => _exportedCount = count);
      showAppMessage(context, '数据已复制到剪贴板');
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
        title: '数据导出',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Column(children: [
            Text('📎', style: TextStyle(fontSize: 50)),
            SizedBox(height: AppSpacing.xs),
            Text('导出健康数据',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('将您的健康记录导出为文件，方便备份或分享给医生',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(children: [
              DropdownButtonFormField<String>(
                initialValue: _format,
                decoration: const InputDecoration(labelText: '导出格式'),
                items: _formats
                    .map((item) =>
                        DropdownMenuItem(value: item.$1, child: Text(item.$2)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _format = value ?? _format),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                initialValue: _days,
                decoration: const InputDecoration(labelText: '时间范围'),
                items: _ranges
                    .map((item) =>
                        DropdownMenuItem(value: item.$1, child: Text(item.$2)))
                    .toList(),
                onChanged: (value) => setState(() => _days = value ?? _days),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(
            color: Color(0xffeef2ff),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('导出说明', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: AppSpacing.xs),
              Text(
                  '• 数据由服务端生成，确保完整性和准确性\n• CSV 格式可直接导入 Excel 进行分析\n• JSON 格式适合开发者使用',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.7)),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
              onPressed: _exporting ? null : _export,
              child: Text(_exporting ? '导出中...' : '开始导出')),
          if (_exportedCount != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              color: const Color(0xffecfdf5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅ 导出成功',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text('数据已复制到剪贴板，共导出 $_exportedCount 条记录',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ]),
            ),
          ],
        ]),
      );
}
