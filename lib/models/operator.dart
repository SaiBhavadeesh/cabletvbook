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
      totalAccounts: (doc['ta'] as num?)?.toInt() ?? 0,
      activeAccounts: (doc['aa'] as num?)?.toInt() ?? 0,
      inActiveAccounts: (doc['iaa'] as num?)?.toInt() ?? 0,
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
  String networkName;
  String phoneNumber;
  DateTime? startDate;
  List<double> plans;
  String? profileImageLink;

  Operator({
    required this.id,
    required this.name,
    required this.email,
    required this.networkName,
    required this.phoneNumber,
    required this.plans,
    this.startDate,
    this.profileImageLink,
  });

  factory Operator.fromMap(Map<String, dynamic> document) {
    return Operator(
      id: document['id'] ?? '',
      name: document['name'] ?? '',
      email: document['email'] ?? '',
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'nn': networkName,
        'pil': profileImageLink,
        'pn': phoneNumber,
        'sd': FieldValue.serverTimestamp(),
        'plans': plans,
      };
}
