import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/loading_view.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.api, this.user});
  final ApiClient api;
  final UserInfo? user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final Map<String, TextEditingController> _fields;
  late int _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _gender = user?.gender ?? 0;
    _fields = {
      'nickname': TextEditingController(text: user?.nickname ?? ''),
      'age': TextEditingController(
          text: user?.age == 0 ? '' : '${user?.age ?? ''}'),
      'height': TextEditingController(
          text: user?.height == 0 ? '' : '${user?.height ?? ''}'),
      'weight': TextEditingController(
          text: user?.weight == 0 ? '' : '${user?.weight ?? ''}'),
      'phone': TextEditingController(text: user?.phone ?? ''),
      'email': TextEditingController(text: user?.email ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_fields['nickname']!.text.trim().isEmpty) {
      showAppMessage(context, '请填写昵称');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.api.put('/user/info', {
        'nickname': _fields['nickname']!.text.trim(),
        'gender': _gender,
        'age': int.tryParse(_fields['age']!.text) ?? 0,
        'height': double.tryParse(_fields['height']!.text) ?? 0,
        'weight': double.tryParse(_fields['weight']!.text) ?? 0,
        'phone': _fields['phone']!.text.trim(),
        'email': _fields['email']!.text.trim(),
      });
      if (!mounted) return;
      showAppMessage(context, '保存成功');
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
        title: '编辑资料',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(children: [
              _field('昵称', 'nickname', '请输入昵称'),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<int>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: '性别'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('未知')),
                    DropdownMenuItem(value: 1, child: Text('男')),
                    DropdownMenuItem(value: 2, child: Text('女')),
                  ],
                  onChanged: (value) => setState(() => _gender = value ?? 0),
                ),
              ),
              _field('年龄', 'age', '请输入年龄', numeric: true),
              const Divider(),
              _field('身高 (cm)', 'height', '请输入身高', numeric: true),
              const Divider(),
              _field('体重 (kg)', 'weight', '请输入体重', numeric: true),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('联系方式',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  _field('手机号', 'phone', '请输入手机号', numeric: true),
                  const Divider(),
                  _field('邮箱', 'email', '请输入邮箱'),
                ]),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中...' : '保存修改')),
        ]),
      );

  Widget _field(String label, String key, String hint,
          {bool numeric = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: _fields[key],
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}
