import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AreaData {
  String areaName;
  int totalAccounts;
  int activeAccounts;
  int inActiveAccounts;
  AreaData({
    @required this.areaName,
    this.totalAccounts = 0,
    this.activeAccounts = 0,
    this.inActiveAccounts = 0,
  });
}

List<List> plan = [
  [
    DateFormat('d/M').format(DateTime(2020, 1)),
    plans[0].toString(),
    'Active',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 2)),
    plans[0].toString(),
    'Active',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 3)),
    plans[0].toString(),
    'Active',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 4)),
    plans[1].toString(),
    'Active',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 5)),
    plans[1].toString(),
    'Active',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 6)),
    plans[1].toString(),
    'Inactive',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 7)),
    plans[2].toString(),
    'Inactive',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 8)),
    plans[2].toString(),
    'Not Started',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 9)),
    plans[2].toString(),
    'Not Started',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 10)),
    plans[3].toString(),
    'Not Started',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 11)),
    plans[3].toString(),
    'Not Started',
  ],
  [
    DateFormat('d/M').format(DateTime(2020, 12)),
    plans[3].toString(),
    'Not Started',
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
    this.status = 'Not started',
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

List<AreaData> areas = [
  AreaData(
    areaName: 'North',
    totalAccounts: 2,
    activeAccounts: 0,
    inActiveAccounts: 2,
  ),
  AreaData(
    areaName: 'East',
    totalAccounts: 2,
    activeAccounts: 2,
    inActiveAccounts: 0,
  ),
  AreaData(
    areaName: 'West',
    totalAccounts: 2,
    activeAccounts: 0,
    inActiveAccounts: 2,
  ),
  AreaData(
    areaName: 'South',
    totalAccounts: 2,
    activeAccounts: 2,
    inActiveAccounts: 0,
  ),
];

List<int> plans = [200, 250, 300, 350];

List<Customer> customers = [
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderName: 'Sri Rama Cable Network',
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
    startDate: DateTime.now(),
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
