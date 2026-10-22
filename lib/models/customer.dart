import 'package:cloud_firestore/cloud_firestore.dart';

class Recharge {
  String id;
  DateTime? date;
  DateTime ymRec;
  String? plan;
  bool? billPay;
  bool status;
  String? addInfo;

  Recharge({
    required this.id,
    required this.ymRec,
    this.date,
    this.plan,
    required this.status,
    this.billPay,
    this.addInfo,
  });

  factory Recharge.fromMap(Map<String, dynamic> doc) {
    return Recharge(
      id: doc['id'] ?? '',
      ymRec: doc['ymRec'] != null
          ? (doc['ymRec'] as Timestamp).toDate()
          : DateTime.now(),
      date: doc['date'] != null ? (doc['date'] as Timestamp).toDate() : null,
      plan: doc['plan']?.toString(),
      status: doc['status'] ?? false,
      billPay: doc['billPay'],
      addInfo: doc['addInfo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'ymRec': ymRec,
        'plan': plan,
        'status': status,
        'billPay': billPay,
        'addInfo': addInfo,
      };
}

class Customer {
  String id;
  String name;
  String macId;
  String areaId;
  String address;
  String? tempInfo;
  double currentPlan;
  DateTime startDate;
  int runningYear;
  int expiryMonth;
  int noOfPendingBills;
  String phoneNumber;
  String accountNumber;
  String currentStatus;
  String? profileImageUrl;
  String networkProviderId;

  Customer({
    required this.id,
    required this.name,
    required this.macId,
    required this.areaId,
    required this.address,
    this.tempInfo,
    DateTime? startDate,
    int? runningYear,
    int? expiryMonth,
    this.profileImageUrl,
    this.noOfPendingBills = 0,
    required this.currentPlan,
    required this.phoneNumber,
    required this.accountNumber,
    this.currentStatus = 'Inactive',
    required this.networkProviderId,
  })  : startDate = startDate ?? DateTime.now(),
        runningYear = runningYear ?? DateTime.now().year,
        expiryMonth = expiryMonth ?? 0;

  factory Customer.fromMap(Map<String, dynamic> document) {
    return Customer(
      id: document['id'] ?? '',
      name: document['name'] ?? '',
      macId: document['macId'] ?? '',
      areaId: document['areaId'] ?? '',
      address: document['adrs'] ?? '',
      tempInfo: document['tempInfo'],
      startDate: document['sd'] is Timestamp
          ? (document['sd'] as Timestamp).toDate()
          : document['sd'] is DateTime
              ? document['sd'] as DateTime
              : DateTime.now(),
      runningYear: document['runYear'] ?? DateTime.now().year,
      expiryMonth: document['expMon'] ?? 0,
      noOfPendingBills: document['noOfPenBil'] ?? 0,
      profileImageUrl: document['piUrl'],
      currentPlan: (document['curPlan'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: document['pn'] ?? '',
      accountNumber: document['accNo'] ?? '',
      currentStatus: document['curSts'] ?? 'Inactive',
      networkProviderId: document['npId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'macId': macId,
        'areaId': areaId,
        'adrs': address,
        'tempInfo': tempInfo,
        'curPlan': currentPlan,
        'runYear': runningYear,
        'expMon': expiryMonth,
        'pn': phoneNumber,
        'accNo': accountNumber,
        'curSts': currentStatus,
        'piUrl': profileImageUrl,
        'noOfPenBil': noOfPendingBills,
        'sd': FieldValue.serverTimestamp(),
        'npId': networkProviderId,
      };
}

List<Customer> getCustomersFromDoc(
  QuerySnapshot snapshot, {
  bool all = false,
  bool pending = false,
  bool credits = false,
  bool active = false,
  bool inactive = false,
}) {
  final cust = snapshot.docs
      .map((e) => Customer.fromMap(e.data() as Map<String, dynamic>))
      .toList();
  return getSelectedCustomers(
    active: active,
    all: all,
    credits: credits,
    inactive: inactive,
    pending: pending,
    providedCustomers: cust,
  );
}

List<Customer> getSelectedCustomers({
  bool all = false,
  bool pending = false,
  bool credits = false,
  bool active = false,
  bool inactive = false,
  List<Customer> providedCustomers = const [],
}) {
  if (all) {
    return providedCustomers;
  } else if (pending) {
    final now = DateTime.now();
    return providedCustomers
        .where((element) =>
            element.expiryMonth < now.month && element.runningYear <= now.year)
        .toList();
  } else if (credits) {
    return providedCustomers
        .where((element) => element.noOfPendingBills > 0)
        .toList();
  } else if (active) {
    return providedCustomers
        .where((element) => element.currentStatus == 'Active')
        .toList();
  } else if (inactive) {
    return providedCustomers
        .where((element) => element.currentStatus == 'Inactive')
        .toList();
  } else {
    return [];
  }
}

List<Recharge> getCustomerYearlyRecharge(
    List<DocumentSnapshot> docs, int year) {
  return docs
      .map((e) => Recharge.fromMap(e.data() as Map<String, dynamic>))
      .where((element) => element.ymRec.year == year)
      .toList();
}

Recharge? getMonthlyRecharge(List<DocumentSnapshot> docs, int year, int month) {
  try {
    return docs
        .map((e) => Recharge.fromMap(e.data() as Map<String, dynamic>))
        .firstWhere((element) =>
            element.ymRec.year == year && element.ymRec.month == month);
  } catch (_) {
    return null;
  }
}
