import 'package:flutter_test/flutter_test.dart';
import 'package:tp_integration_mpf/utils/counter_logic.dart';

void main() {
  group('CounterLogic', () {
    test('incrémente de 1', () {
      final logic = CounterLogic();
      expect(logic.increment(0), 1);
      expect(logic.increment(5), 6);
    });

    test('reste positif', () {
      final logic = CounterLogic();
      expect(logic.increment(-1), 0);
    });
  });
}
