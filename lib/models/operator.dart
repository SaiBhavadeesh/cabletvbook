import 'package:cloud_firestore/cloud_firestore.dart';

class AreaData {
  String id;
  String areaName;
  int totalAccounts;
  int activeAccounts;
  int inActiveAccounts;

  AreaData({
    this.id = '',
    required this.areaName,
    this.totalAccounts = 0,
    this.activeAccounts = 0,
    this.inActiveAccounts = 0,
  });

  factory AreaData.fromMap(Map<String, dynamic> doc) {
    return AreaData(
      id: doc['id'] ?? '',
      areaName: doc['an'] ?? '',
      totalAccounts: doc['ta'] ?? 0,
      activeAccounts: doc['aa'] ?? 0,
      inActiveAccounts: doc['iaa'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'an': areaName,
        'ta': totalAccounts,
        'aa': activeAccounts,
        'iaa': inActiveAccounts,
      };
}

class Operator {
  String id;
  String name;
  String email;
  String? password;
  String networkName;
  String phoneNumber;
  String? transactionId;
  DateTime? transactionTime;
  double? amountPaid;
  bool isSubscribed;
  DateTime? startDate;
  List<double> plans;
  String? profileImageLink;

  Operator({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.networkName,
    required this.phoneNumber,
    required this.plans,
    this.startDate,
    this.profileImageLink,
    this.transactionId,
    this.transactionTime,
    this.isSubscribed = false,
    this.amountPaid,
  });

  factory Operator.fromMap(Map<String, dynamic> document) {
    return Operator(
      id: document['id'] ?? '',
      name: document['name'] ?? '',
      email: document['email'] ?? '',
      password: document['pswd'],
      networkName: document['nn'] ?? '',
      phoneNumber: document['pn'] ?? '',
      profileImageLink: document['pil'],
      startDate: document['sd'] != null
          ? (document['sd'] as Timestamp).toDate()
          : null,
      plans: document['plans'] != null
          ? List<double>.from(
              (document['plans'] as List).map((e) => (e as num).toDouble()))
          : [],
      transactionId: document['tId'],
      transactionTime: document['tt'] != null
          ? (document['tt'] as Timestamp).toDate()
          : null,
      amountPaid: (document['mnyPd'] as num?)?.toDouble(),
      isSubscribed: document['isSub'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'pswd': password,
        'nn': networkName,
        'pil': profileImageLink,
        'pn': phoneNumber,
        'sd': FieldValue.serverTimestamp(),
        'plans': plans,
        'tId': transactionId,
        'tt': transactionTime,
        'mnyPd': amountPaid,
        'isSub': isSubscribed,
      };
}
