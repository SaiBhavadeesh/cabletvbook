import 'package:flutter_test/flutter_test.dart';
import 'package:cableTvBook/models/customer.dart';

void main() {
  group('Customer & Recharge Domain Logic', () {
    final activeCustomer = Customer(
      id: 'c1',
      name: 'Ramesh Kumar',
      macId: 'AA:BB:CC:DD:EE:01',
      areaId: 'area_1',
      address: 'Plot 42, Green Avenue',
      currentPlan: 300.0,
      phoneNumber: '+919876543210',
      accountNumber: 'ACC-101',
      currentStatus: 'Active',
      networkProviderId: 'op_1',
      noOfPendingBills: 0,
      expiryMonth: 12,
      runningYear: 2026,
    );

    final inactiveCustomer = Customer(
      id: 'c2',
      name: 'Suresh Verma',
      macId: 'AA:BB:CC:DD:EE:02',
      areaId: 'area_1',
      address: 'House 7, Market Road',
      currentPlan: 250.0,
      phoneNumber: '+919876543211',
      accountNumber: 'ACC-102',
      currentStatus: 'Inactive',
      networkProviderId: 'op_1',
      noOfPendingBills: 2,
      expiryMonth: 1,
      runningYear: 2026,
    );

    final customersList = [activeCustomer, inactiveCustomer];

    test('getSelectedCustomers with all=true returns all customers', () {
      final result = getSelectedCustomers(all: true, providedCustomers: customersList);
      expect(result.length, equals(2));
    });

    test('getSelectedCustomers with active=true filters active only', () {
      final result = getSelectedCustomers(active: true, providedCustomers: customersList);
      expect(result.length, equals(1));
      expect(result.first.name, equals('Ramesh Kumar'));
    });

    test('getSelectedCustomers with inactive=true filters inactive only', () {
      final result = getSelectedCustomers(inactive: true, providedCustomers: customersList);
      expect(result.length, equals(1));
      expect(result.first.name, equals('Suresh Verma'));
    });

    test('getSelectedCustomers with credits=true filters customers with pending bills', () {
      final result = getSelectedCustomers(credits: true, providedCustomers: customersList);
      expect(result.length, equals(1));
      expect(result.first.noOfPendingBills, equals(2));
    });

    test('Customer model serialization and deserialization retains data integrity', () {
      final json = activeCustomer.toJson();
      expect(json['name'], equals('Ramesh Kumar'));
      expect(json['accNo'], equals('ACC-101'));
      expect(json['curPlan'], equals(300.0));
      expect(json['curSts'], equals('Active'));

      final restored = Customer.fromMap(json);
      expect(restored.name, equals(activeCustomer.name));
      expect(restored.phoneNumber, equals(activeCustomer.phoneNumber));
      expect(restored.currentPlan, equals(300.0));
    });

    test('Recharge model correctly parses status and billPay', () {
      final recharge = Recharge(
        id: 'rec_1',
        ymRec: DateTime(2026, 10),
        status: true,
        billPay: true,
        plan: '300.0',
      );

      final json = recharge.toJson();
      expect(json['status'], isTrue);
      expect(json['billPay'], isTrue);
      expect(json['plan'], equals('300.0'));
    });
  });
}
