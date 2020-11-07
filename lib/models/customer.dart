import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recharge {
  String id;
  DateTime date;
  DateTime ymRec;
  String plan;
  bool billPay;
  bool status;
  String addInfo;
  Recharge({
    @required this.id,
    @required this.ymRec,
    @required this.date,
    @required this.plan,
    @required this.status,
    @required this.billPay,
    @required this.addInfo,
  });

  Recharge.fromMap(doc) {
    this.id = doc['id'];
    this.ymRec = doc['ymRec']?.toDate();
    this.date = doc['date']?.toDate();
    this.plan = doc['plan'];
    this.status = doc['status'];
    this.billPay = doc['billPay'];
    this.addInfo = doc['addInfo'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'date': this.date,
        'ymRec': this.ymRec,
        'plan': this.plan,
        'status': this.status,
        'billPay': this.billPay,
        'addInfo': this.addInfo,
      };
}

class Customer {
  String id;
  String name;
  String macId;
  String areaId;
  String address;
  String tempInfo;
  double currentPlan;
  DateTime startDate;
  int runningYear;
  int expiryMonth;
  int noOfPendingBills;
  String phoneNumber;
  String accountNumber;
  String currentStatus;
  String profileImageUrl;
  String networkProviderId;

  Customer({
    @required this.id,
    @required this.name,
    @required this.macId,
    @required this.areaId,
    @required this.address,
    this.tempInfo,
    this.startDate,
    this.runningYear,
    this.expiryMonth,
    this.profileImageUrl,
    this.noOfPendingBills = 0,
    @required this.currentPlan,
    @required this.phoneNumber,
    @required this.accountNumber,
    this.currentStatus = 'Inactive',
    @required this.networkProviderId,
  });

  Customer.fromMap(document) {
    this.id = document['id'];
    this.name = document['name'];
    this.macId = document['macId'];
    this.areaId = document['areaId'];
    this.address = document['adrs'];
    this.tempInfo = document['tempInfo'];
    this.startDate = document['sd']?.toDate();
    this.runningYear = document['runYear'];
    this.expiryMonth = document['expMon'];
    this.noOfPendingBills = document['noOfPenBil'];
    this.profileImageUrl = document['piUrl'];
    this.currentPlan = document['curPlan'];
    this.phoneNumber = document['pn'];
    this.accountNumber = document['accNo'];
    this.currentStatus = document['curSts'];
    this.networkProviderId = document['npId'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'macId': this.macId,
        'areaId': this.areaId,
        'adrs': this.address,
        'tempInfo': this.tempInfo,
        'curPlan': this.currentPlan,
        'runYear': this.runningYear,
        'expMon': this.expiryMonth,
        'pn': this.phoneNumber,
        'accNo': this.accountNumber,
        'curSts': this.currentStatus,
        'piUrl': this.profileImageUrl,
        'noOfPenBil': this.noOfPendingBills,
        'sd': FieldValue.serverTimestamp(),
        'npId': this.networkProviderId,
      };
}

List<Customer> getCustomersFromDoc(QuerySnapshot snapshot) {
  return snapshot.docs.map((e) => Customer.fromMap(e.data())).toList();
}

List<Customer> getSelectedCustomers({
  bool all = false,
  bool pending = false,
  bool credits = false,
  bool active = false,
  bool inactive = false,
  List<Customer> providedCustomers,
}) {
  if (all)
    return providedCustomers;
  else if (pending)
    return providedCustomers
        .where((element) =>
            element.expiryMonth < DateTime.now().month &&
            element.runningYear <= DateTime.now().year)
        .toList();
  else if (credits)
    return providedCustomers
        .where((element) => element.noOfPendingBills > 0)
        .toList();
  else if (active)
    return providedCustomers
        .where((element) => element.currentStatus == 'Active')
        .toList();
  else if (inactive)
    return providedCustomers
        .where((element) => element.currentStatus == 'Inactive')
        .toList();
  else
    return [];
}

List<Recharge> getCustomerYearlyRecharge(
    List<DocumentSnapshot> docs, int year) {
  return docs
      .where((element) => Recharge.fromMap(element.data()).ymRec.year == year)
      .toList()
      .map((e) => Recharge.fromMap(e.data()))
      .toList();
}
