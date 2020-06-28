import 'package:flutter/cupertino.dart';

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
    @required this.currentPlan,
    this.currentStatus = 'Inactive',
    this.plans,
  });
}

List<AreaData> areas = [
  AreaData(
    areaName: 'North',
    totalAccounts: 1,
    activeAccounts: 0,
    inActiveAccounts: 1,
  ),
  AreaData(
    areaName: 'East',
    totalAccounts: 1,
    activeAccounts: 0,
    inActiveAccounts: 1,
  ),
  AreaData(
    areaName: 'West',
    totalAccounts: 1,
    activeAccounts: 0,
    inActiveAccounts: 1,
  ),
  AreaData(
    areaName: 'South',
    totalAccounts: 1,
    activeAccounts: 0,
    inActiveAccounts: 1,
  ),
];

List<int> plans = [200, 250, 300, 350];

List<Customer> customers = [
  Customer(
    id: '0',
    name: 'customer 1',
    phoneNumber: '123456',
    address: 'address 1',
    accountNumber: 'account 1',
    macId: 'mac 1',
    networkProviderName: 'Sri Rama Cable Network',
    area: 'North',
    currentPlan: 200,
  ),
  Customer(
    id: '1',
    name: 'customer 2',
    phoneNumber: '123456',
    address: 'address 2',
    accountNumber: 'account 2',
    macId: 'mac 2',
    networkProviderName: 'Sri Rama Cable Network',
    area: 'East',
    currentPlan: 250,
  ),
  Customer(
    id: '2',
    name: 'customer 3',
    phoneNumber: '123456',
    address: 'address 3',
    accountNumber: 'account 3',
    macId: 'mac 3',
    networkProviderName: 'Sri Rama Cable Network',
    area: 'West',
    currentPlan: 300,
  ),
  Customer(
    id: '3',
    name: 'customer 4',
    phoneNumber: '123456',
    address: 'address 4',
    accountNumber: 'account 4',
    macId: 'mac 4',
    networkProviderName: 'Sri Rama Cable Network',
    area: 'South',
    currentPlan: 350,
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
