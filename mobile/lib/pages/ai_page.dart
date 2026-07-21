import 'package:flutter/material.dart';

import '../api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<AiPage> createState() => _AiPageState();
}

class _Message {
  const _Message(this.fromUser, this.content, this.time);
  final bool fromUser;
  final String content;
  final DateTime time;
}

class _AiPageState extends State<AiPage> {
  static const _questions = [
    '我的健康数据有什么异常？',
    '如何改善睡眠质量？',
    '推荐今天的运动计划',
    '我需要注意哪些饮食？',
  ];

  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [
    _Message(
      false,
      '你好！我是你的 AI 健康助手 🤖\n\n我可以根据你的健康数据为你提供个性化的健康建议。你可以问我任何关于健康、运动、饮食、睡眠等方面的问题。',
      DateTime.now(),
    ),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggested]) async {
    final content = (suggested ?? _input.text).trim();
    if (content.isEmpty || _busy) return;
    setState(() {
      _messages.add(_Message(true, content, DateTime.now()));
      _input.clear();
      _busy = true;
    });
    _scrollToEnd();
    try {
      final data = await widget.api.post('/ai/chat', {'message': content})
          as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _messages.add(_Message(false,
          '${data['reply'] ?? '抱歉，我暂时无法回答你的问题，请稍后再试。'}', DateTime.now())));
    } on ApiException {
      if (mounted) {
        setState(() =>
            _messages.add(_Message(false, '网络异常，请检查网络后重试 🔄', DateTime.now())));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AI 健康助手')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.sm),
                children: [
                  for (final message in _messages) _bubble(message),
                  if (_busy) _typingBubble(),
                  if (_messages.length == 1) _quickQuestions(),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      onChanged: (_) => setState(() {}),
                      decoration:
                          const InputDecoration(hintText: '输入你的健康问题...'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    onPressed:
                        _input.text.trim().isEmpty || _busy ? null : _send,
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.border),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );

  Widget _bubble(_Message message) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: message.fromUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.fromUser) ...[
              const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xffeef2ff),
                  child: Text('🤖')),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: message.fromUser ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppSpacing.radius),
                    topRight: const Radius.circular(AppSpacing.radius),
                    bottomLeft: Radius.circular(
                        message.fromUser ? AppSpacing.radius : 4),
                    bottomRight: Radius.circular(
                        message.fromUser ? 4 : AppSpacing.radius),
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0d000000),
                        blurRadius: 8,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.content,
                          style: TextStyle(
                              color: message.fromUser
                                  ? Colors.white
                                  : AppColors.text,
                              height: 1.5)),
                      const SizedBox(height: 5),
                      Text(
                        '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            color: message.fromUser
                                ? Colors.white70
                                : AppColors.textLight,
                            fontSize: 10),
                      ),
                    ]),
              ),
            ),
            if (message.fromUser) ...[
              const SizedBox(width: AppSpacing.xs),
              const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xffe0e7ff),
                  child: Text('👤')),
            ],
          ],
        ),
      );

  Widget _typingBubble() => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xffeef2ff),
              child: Text('🤖')),
          SizedBox(width: AppSpacing.xs),
          DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.all(Radius.circular(AppSpacing.radius))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
        ]),
      );

  Widget _quickQuestions() => Padding(
        padding: const EdgeInsets.only(left: 44, top: AppSpacing.xs),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('试试问我：',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _questions
                .map((question) => ActionChip(
                      label:
                          Text(question, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      onPressed: () => _send(question),
                    ))
                .toList(),
          ),
        ]),
      );
}
