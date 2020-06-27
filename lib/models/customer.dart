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

List<AreaData> areas = [
  AreaData(areaName: 'North'),
  AreaData(areaName: 'East'),
  AreaData(areaName: 'West'),
  AreaData(areaName: 'South'),
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
  String accountNumber;
  String macId;
  String networkProviderName;
  String area;
  String currentStatus;
  List<Plan> plans;

  Customer({
    @required this.id,
    @required this.name,
    @required this.phoneNumber,
    @required this.accountNumber,
    @required this.macId,
    @required this.networkProviderName,
    @required this.area,
    this.currentStatus,
    this.plans,
  });
}
