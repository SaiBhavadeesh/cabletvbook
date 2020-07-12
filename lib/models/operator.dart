import 'package:flutter/foundation.dart';

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

class Operator {
  String id;
  String email;
  String name;
  String networkName;
  String profileImageLink;
  String phoneNumber;
  DateTime startDate;
  List<AreaData> areas;
  List<int> plans;
  Operator({
    @required this.id,
    @required this.email,
    @required this.name,
    @required this.networkName,
    @required this.phoneNumber,
    @required this.areas,
    @required this.plans,
    @required this.startDate,
    this.profileImageLink,
  });
}

List<AreaData> areas = [
  AreaData(
    areaName: 'North east',
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

Operator getOperatorDetails() {
  return Operator(
    id: '1',
    email: 'ysr_yarlagadda@yahoo.com',
    name: 'Srinivasa Rao Yarlagadda',
    networkName: 'Sri Rama Cable Network',
    phoneNumber: '+91 900092143',
    startDate: DateTime.now().subtract(Duration(days: 730)),
    areas: areas,
    plans: plans,
  );
}
