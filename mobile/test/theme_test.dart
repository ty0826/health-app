import 'package:flutter_test/flutter_test.dart';
import 'package:health_manager_mobile/theme/app_colors.dart';
import 'package:health_manager_mobile/theme/app_spacing.dart';

void main() {
  test('theme tokens match the Taro visual baseline', () {
    expect(AppColors.primary.toARGB32(), 0xff4f46e5);
    expect(AppColors.background.toARGB32(), 0xfff3f4f6);
    expect(AppSpacing.xs, 8);
    expect(AppSpacing.sm, 16);
    expect(AppSpacing.md, 24);
    expect(AppSpacing.lg, 32);
    expect(AppSpacing.xl, 48);
  });
}
