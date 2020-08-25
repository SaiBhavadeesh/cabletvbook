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
    this.date = doc['date'] == null ? null : doc['date'].toDate();
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
    this.address = document['address'];
    this.tempInfo = document['tempInfo'];
    this.startDate = document['startDate'].toDate();
    this.runningYear = document['runningYear'];
    this.noOfPendingBills = document['noOfPendingBills'];
    this.profileImageUrl = document['profileImageUrl'];
    this.currentPlan = document['currentPlan'];
    this.phoneNumber = document['phoneNumber'];
    this.accountNumber = document['accountNumber'];
    this.currentStatus = document['currentStatus'];
    this.networkProviderId = document['networkProviderId'];
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'macId': this.macId,
        'areaId': this.areaId,
        'address': this.address,
        'tempInfo': this.tempInfo,
        'currentPlan': this.currentPlan,
        'runningYear': this.runningYear,
        'phoneNumber': this.phoneNumber,
        'accountNumber': this.accountNumber,
        'currentStatus': this.currentStatus,
        'profileImageUrl': this.profileImageUrl,
        'noOfPendingBills': this.noOfPendingBills,
        'startDate': FieldValue.serverTimestamp(),
        'networkProviderId': this.networkProviderId,
      };
}

List<Customer> getAreaCustomers(List<DocumentSnapshot> docs) {
  return docs.map((e) => Customer.fromMap(e)).toList();
}

Future<List<Customer>> getAllCustomers() async {
  List<DocumentSnapshot> doc = [];
  for (int i = 0; i < areas.length; i++) {
    doc += (await Firestore.instance
            .collection(
                'users/${firebaseUser.uid}/areas/${areas[i].id}/customers')
            .orderBy('name')
            .getDocuments())
        .documents;
  }
  return doc.map((e) => Customer.fromMap(e)).toList();
}

List<Customer> getSelectedCustomers({
  bool active = false,
  bool all = false,
  bool inactive = false,
  List<Customer> providedCustomers,
}) {
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

List<Recharge> getCustomerYearlyRecharge(List<DocumentSnapshot> docs) {
  return docs.map((e) => Recharge.fromMap(e)).toList();
}
