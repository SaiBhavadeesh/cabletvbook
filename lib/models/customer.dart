import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import 'package:cableTvBook/models/operator.dart';

List<List> plan = [
  [
    DateFormat('d/M').format(DateTime(2020, 1)),
    getOperatorDetails().plans[0].toString(),
    'Completed',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 2)),
    getOperatorDetails().plans[0].toString(),
    'Completed',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 3)),
    getOperatorDetails().plans[0].toString(),
    'Completed',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 4)),
    getOperatorDetails().plans[1].toString(),
    'Completed',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 5)),
    getOperatorDetails().plans[1].toString(),
    'Completed',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 6)),
    getOperatorDetails().plans[1].toString(),
    'Active',
  ],
  [
    '',
    '',
    'Inactive',
  ],
  [
    '',
    '',
    '',
  ],
  [
    '',
    '',
    '',
  ],
  [
    '',
    '',
    '',
  ],
  [
    '',
    '',
    '',
  ],
  [
    '',
    '',
    '',
  ],
];

class Plan {
  int monthCode;
  String date;
  String plan;
  String status;
  Plan({
    this.monthCode,
    this.date,
    this.plan,
    this.status = '',
  });
}

class Customer {
  String id;
  String name;
  String phoneNumber;
  String address;
  String accountNumber;
  String macId;
  String networkProviderName;
  String area;
  DateTime startDate;
  int currentPlan;
  String currentStatus;
  List<Plan> plans;

  Customer({
    @required this.id,
    @required this.name,
    @required this.phoneNumber,
    @required this.address,
    @required this.accountNumber,
    @required this.macId,
    @required this.networkProviderName,
    @required this.area,
    @required this.startDate,
    @required this.currentPlan,
    this.currentStatus = 'Active',
    this.plans,
  });
}

List<Customer> customers = [
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'North',
    currentPlan: 200,
    currentStatus: 'Inactive',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'East',
    currentPlan: 250,
    currentStatus: 'Active',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'West',
    currentPlan: 300,
    currentStatus: 'Inactive',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'South',
    currentPlan: 350,
    currentStatus: 'Active',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'North',
    currentPlan: 200,
    currentStatus: 'Inactive',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'East',
    currentPlan: 250,
    currentStatus: 'Active',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'West',
    currentPlan: 300,
    currentStatus: 'Inactive',
  ),
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    area: 'South',
    currentPlan: 350,
    currentStatus: 'Active',
  ),
];

List<Customer> getAreaCustomers(String areaName) {
  List<Customer> areaCustomers = [];
  customers.forEach((element) {
    if (element.area == areaName) {
      areaCustomers.add(element);
    }
  });
  return areaCustomers;
}

List<Customer> getSelectedCustomers({
  bool active = false,
  bool all = false,
  bool inactive = false,
  List<Customer> providedCustomers,
}) {
  if (providedCustomers == null) {
    providedCustomers = customers;
  }
  List<Customer> selectedCustomers = [];
  if (all) {
    return providedCustomers;
  } else if (active) {
    providedCustomers.forEach((element) {
      if (element.currentStatus == 'Active') {
        selectedCustomers.add(element);
      }
    });
  } else if (inactive) {
    providedCustomers.forEach((element) {
      if (element.currentStatus == 'Inactive') {
        selectedCustomers.add(element);
      }
    });
  }
  return selectedCustomers;
}
