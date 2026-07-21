import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_outlined, Icons.home, '首页'),
    (Icons.bar_chart_outlined, Icons.bar_chart, '数据'),
    (Icons.smart_toy_outlined, Icons.smart_toy, 'AI助手'),
    (Icons.person_outline, Icons.person, '我的'),
  ];

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.primary,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 50,
            child: Row(
              children: List.generate(_items.length, (itemIndex) {
                final item = _items[itemIndex];
                final selected = itemIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => onChanged(itemIndex),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.$2 : item.$1,
                          color: Colors.white
                              .withValues(alpha: selected ? 1 : .72),
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$3,
                          style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: selected ? 1 : .72),
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
}
