import 'package:flutter/foundation.dart';

class Plan {
  int monthCode;
  DateTime date;
  String plan;
  String status;
  String addInfo;
  Plan({
    this.monthCode,
    this.date,
    this.plan,
    this.status = '',
    this.addInfo,
  });

  Plan.fromMap(doc) {
    this.monthCode = doc['monthCode'];
    this.date = doc['date'].toDate();
    this.plan = doc['plan'];
    this.status = doc['status'];
    this.addInfo = doc['addInfo'];
  }

  Map<String, dynamic> toJson() => {
        'monthCode': this.monthCode,
        'date': this.date,
        'plan': this.plan,
        'status': this.status,
        'addInfo': this.addInfo,
      };
}

class Customer {
  String id;
  String name;
  String phoneNumber;
  String address;
  String accountNumber;
  String macId;
  String networkProviderId;
  String area;
  DateTime startDate;
  double currentPlan;
  String currentStatus;
  List<Plan> plans;

  Customer({
    @required this.id,
    @required this.name,
    @required this.area,
    @required this.macId,
    @required this.address,
    @required this.startDate,
    @required this.currentPlan,
    @required this.phoneNumber,
    @required this.accountNumber,
    this.currentStatus = 'Inactive',
    @required this.networkProviderId,
    this.plans,
  });

  Customer.fromMap(documnet) {
    this.id = documnet['id'];
    this.name = documnet['name'];
    this.area = documnet['area'];
    this.macId = documnet['macId'];
    this.address = documnet['address'];
    this.startDate = documnet['startDate'].toDate();
    this.currentPlan = documnet['currentPlan'];
    this.phoneNumber = documnet['phoneNumber'];
    this.accountNumber = documnet['accountNumber'];
    this.currentStatus = documnet['currentStatus'];
    this.networkProviderId = documnet['networkProviderId'];
    this.plans = [...documnet['plans']].map((e) => Plan.fromMap(e)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'area': this.area,
        'macId': this.macId,
        'address': this.address,
        'startDate': this.startDate,
        'currentPlan': this.currentPlan,
        'phoneNumber': this.phoneNumber,
        'accountNumber': this.accountNumber,
        'currentStatus': this.currentStatus,
        'networkProviderId': this.networkProviderId,
        'plans': this.plans != null
            ? this.plans.map((e) => e.toJson()).toList()
            : null,
      };
}

List<Customer> customers = [
  Customer(
    id: '0',
    name: 'Yarlagadda Srinivasa Rao',
    phoneNumber: '9000992143',
    address: 'address',
    accountNumber: '87654321',
    macId: '12DS345678',
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
    networkProviderId: 'Sri Rama Cable Network',
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
