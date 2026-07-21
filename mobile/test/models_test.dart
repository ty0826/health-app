import 'package:flutter_test/flutter_test.dart';
import 'package:health_manager_mobile/models.dart';

void main() {
  test('health record safely decodes numeric values', () {
    final record = HealthRecord.fromJson({'steps': 8000, 'weight': 65.5});
    expect(record.steps, 8000);
    expect(record.weight, 65.5);
  });
}
