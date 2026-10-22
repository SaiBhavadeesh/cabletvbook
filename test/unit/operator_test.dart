import 'package:flutter_test/flutter_test.dart';
import 'package:cableTvBook/models/operator.dart';

void main() {
  group('Operator and AreaData Tests', () {
    test('Operator should serialize without storing passwords or payment secrets', () {
      final op = Operator(
        id: 'op_123',
        name: 'Srinivasa Cable Network',
        email: 'operator@cabletv.com',
        networkName: 'SCN Prime',
        phoneNumber: '+919988776655',
        plans: [250.0, 350.0, 500.0],
      );

      final json = op.toJson();

      // Verify essential fields exist
      expect(json['id'], equals('op_123'));
      expect(json['name'], equals('Srinivasa Cable Network'));
      expect(json['email'], equals('operator@cabletv.com'));
      expect(json['nn'], equals('SCN Prime'));
      expect(json['pn'], equals('+919988776655'));
      expect(json['plans'], equals([250.0, 350.0, 500.0]));

      // Security Check: Password must NEVER be serialized in Operator json
      expect(json.containsKey('pswd'), isFalse);
      expect(json.containsKey('password'), isFalse);

      // Payment Gateway Check: No payment secret fields
      expect(json.containsKey('tId'), isFalse);
      expect(json.containsKey('mnyPd'), isFalse);
    });

    test('AreaData fromMap and toJson handle counters safely', () {
      final area = AreaData(
        id: 'area_1',
        areaName: 'Gandhi Nagar',
        totalAccounts: 150,
        activeAccounts: 120,
        inActiveAccounts: 30,
      );

      final json = area.toJson();
      expect(json['an'], equals('Gandhi Nagar'));
      expect(json['ta'], equals(150));
      expect(json['aa'], equals(120));
      expect(json['iaa'], equals(30));

      final restored = AreaData.fromMap(json);
      expect(restored.areaName, equals('Gandhi Nagar'));
      expect(restored.totalAccounts, equals(150));
      expect(restored.activeAccounts, equals(120));
      expect(restored.inActiveAccounts, equals(30));
    });
  });
}
