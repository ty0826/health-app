import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.scrollable = true,
    this.actions,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(
          top: false,
          child: scrollable
              ? ListView(padding: padding, children: [child])
              : Padding(padding: padding, child: child),
        ),
      );
}
