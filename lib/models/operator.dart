import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AreaData {
  String id;
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
    this.id = doc['id'];
    this.areaName = doc['areaName'];
    this.totalAccounts = doc['totalAccounts'];
    this.activeAccounts = doc['activeAccounts'];
    this.inActiveAccounts = doc['inActiveAccounts'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'areaName': this.areaName,
        'totalAccounts': this.totalAccounts,
        'activeAccounts': this.activeAccounts,
        'inActiveAccounts': this.inActiveAccounts,
      };
}

class Operator {
  String id;
  String name;
  String email;
  String password;
  String networkName;
  String phoneNumber;
  String transactionId;
  DateTime transactionTime;
  double amountPaid;
  bool isSubscribed;
  DateTime startDate;
  List<double> plans;
  String profileImageLink;
  Operator({
    @required this.id,
    @required this.name,
    @required this.email,
    @required this.password,
    @required this.networkName,
    @required this.phoneNumber,
    @required this.plans,
    this.startDate,
    this.profileImageLink,
    this.transactionId,
    this.transactionTime,
    this.isSubscribed = false,
    this.amountPaid,
  });

  Operator.fromMap(Map<String, dynamic> document) {
    this.id = document['id'];
    this.name = document['name'];
    this.email = document['email'];
    this.password = document['password'];
    this.networkName = document['networkName'];
    this.phoneNumber = document['phoneNumber'];
    this.profileImageLink = document['profileImageLink'];
    this.startDate = document['startDate'].toDate();
    this.plans = [...document['plans']];
    this.transactionId = document['transactionId'];
    this.transactionTime = document['transactionTime'].toDate();
    this.amountPaid = document['amountPaid'];
    this.isSubscribed = document['isSubscribed'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'email': this.email,
        'password': this.password,
        'networkName': this.networkName,
        'profileImageLink': this.profileImageLink,
        'phoneNumber': this.phoneNumber,
        'startDate': FieldValue.serverTimestamp(),
        'plans': this.plans,
        'transactionId': this.transactionId,
        'transactionTime': this.transactionTime,
        'amountPaid': this.amountPaid,
        'isSubscribed': this.isSubscribed,
      };
}
