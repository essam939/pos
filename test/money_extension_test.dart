import 'package:flutter_test/flutter_test.dart';
import 'package:pos/src/util/money.dart';

void main() {
  test('asMoney formats number to 2 decimal places', () {
    expect(12.0.asMoney, '12.00');
    expect(12.3456.asMoney, '12.35');
    expect(0.asMoney, '0.00');
    expect((-5.1).asMoney, '-5.10');
  });
}
