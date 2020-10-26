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
    this.areaName = doc['an'];
    this.totalAccounts = doc['ta'];
    this.activeAccounts = doc['aa'];
    this.inActiveAccounts = doc['iaa'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'an': this.areaName,
        'ta': this.totalAccounts,
        'aa': this.activeAccounts,
        'iaa': this.inActiveAccounts,
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
    this.password = document['pswd'];
    this.networkName = document['nn'];
    this.phoneNumber = document['pn'];
    this.profileImageLink = document['pil'];
    this.startDate = document['sd']?.toDate();
    this.plans = [...document['plans']];
    this.transactionId = document['tId'];
    this.transactionTime = document['tt']?.toDate();
    this.amountPaid = document['mnyPd'];
    this.isSubscribed = document['isSub'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'email': this.email,
        'pswd': this.password,
        'nn': this.networkName,
        'pil': this.profileImageLink,
        'pn': this.phoneNumber,
        'sd': FieldValue.serverTimestamp(),
        'plans': this.plans,
        'tId': this.transactionId,
        'tt': this.transactionTime,
        'mnyPd': this.amountPaid,
        'isSub': this.isSubscribed,
      };
}
