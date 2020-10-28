import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cableTvBook/global/variables.dart';

class Recharge {
  String id;
  int code;
  DateTime date;
  String plan;
  bool billPay;
  bool status;
  String addInfo;
  Recharge({
    this.id,
    this.code,
    this.date,
    this.plan,
    this.status,
    this.billPay,
    this.addInfo,
  });

  Recharge.fromMap(doc) {
    this.id = doc['id'];
    this.code = doc['code'];
    this.date = doc['date']?.toDate();
    this.plan = doc['plan'];
    this.status = doc['status'];
    this.billPay = doc['billPay'];
    this.addInfo = doc['addInfo'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'date': this.date,
        'code': this.code,
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

List<Customer> getAreaCustomers(List<DocumentSnapshot> docs) {
  return docs.map((e) => Customer.fromMap(e)).toList();
}

Future<List<Customer>> getSelectedAreaCustomers(String id) async {
  final snap = await FirebaseFirestore.instance
      .collection('users/${operatorDetails.id}/areas/$id/customers')
      .orderBy('name')
      .get();
  return snap.docs.map((e) => Customer.fromMap(e)).toList();
}

Future<List<Customer>> getAllCustomers() async {
  List<DocumentSnapshot> doc = [];
  for (int i = 0; i < areas.length; i++) {
    doc += (await FirebaseFirestore.instance
            .collection(
                'users/${firebaseUser.uid}/areas/${areas[i].id}/customers')
            .orderBy('name')
            .get())
        .docs;
  }
  return doc.map((e) => Customer.fromMap(e)).toList();
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

List<Recharge> getCustomerYearlyRecharge(List<DocumentSnapshot> docs) {
  return docs.map((e) => Recharge.fromMap(e)).toList();
}
