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

  AreaData.fromMap(Map<String, dynamic> doc) {
    this.areaName = doc['areaName'];
    this.totalAccounts = doc['totalAccounts'];
    this.activeAccounts = doc['activeAccounts'];
    this.inActiveAccounts = doc['inActiveAccounts'];
  }

  Map<String, dynamic> toJson() => {
        'areaName': this.areaName,
        'totalAccounts': this.totalAccounts,
        'activeAccounts': this.activeAccounts,
        'inActiveAccounts': this.inActiveAccounts,
      };
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

  Operator.fromMap(Map<String, dynamic> document) {
    this.id = document['id'];
    this.email = document['email'];
    this.name = document['name'];
    this.networkName = document['networkName'];
    this.phoneNumber = document['phoneNumber'];
    this.startDate = document['startDate'];
    this.profileImageLink = document['profileImageLink'];
    this.plans = document['plans'];
    this.areas = document['areas'].map((e) => AreaData.fromMap(e)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'email': this.email,
        'name': this.name,
        'networkName': this.networkName,
        'profileImageLink': this.profileImageLink,
        'phoneNumber': this.phoneNumber,
        'startDate': this.startDate,
        'areas': this.areas.map((e) => e.toJson()).toList(),
        'plans': this.plans,
      };
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
