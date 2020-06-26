import 'package:flutter/cupertino.dart';

class Plan {
  int monthCode;
  String date;
  String plan;
  String status;
  Plan({
    this.monthCode,
    this.date,
    this.plan,
    this.status,
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
  });
}
