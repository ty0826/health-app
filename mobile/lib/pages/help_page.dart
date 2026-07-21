import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/loading_view.dart';

class _Faq {
  const _Faq(this.id, this.question, this.answer);
  final int id;
  final String question;
  final String answer;

  factory _Faq.fromJson(Map<String, dynamic> json) => _Faq(
        (json['id'] as num?)?.toInt() ?? 0,
        '${json['question'] ?? ''}',
        '${json['answer'] ?? ''}',
      );
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<_Faq> _faqs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await widget.api.get('/system/faq');
      if (mounted) {
        setState(() => _faqs = ((value as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_Faq.fromJson)
            .toList());
      }
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
        title: '帮助中心',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Column(children: [
            Text('❓', style: TextStyle(fontSize: 50)),
            SizedBox(height: AppSpacing.xs),
            Text('帮助中心',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('常见问题解答，帮助您快速上手',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const SizedBox(height: 240, child: LoadingView())
          else if (_faqs.isEmpty)
            const AppCard(child: Center(child: Text('暂无常见问题')))
          else
            ..._faqs.map((faq) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: ExpansionTile(
                      key: ValueKey(faq.id),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(faq.question,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      childrenPadding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(faq.answer,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                    fontSize: 13)))
                      ],
                    ),
                  ),
                )),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(
            color: Color(0xffeef2ff),
            child: Column(children: [
              Text('仍有疑问？', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('请联系我们的客服团队',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              SizedBox(height: AppSpacing.xs),
              Text('📧 support@healthmanager.com',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      );
}
