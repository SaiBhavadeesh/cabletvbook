import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/box_decoration.dart';

class CollectionScreen extends StatelessWidget {
  static const routeName = '/collectionScreen';

  const CollectionScreen({super.key});

  Widget getTitleText(BuildContext context, String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: defaultBoxDecoration(context, true),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget getValueText(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget valueText(double subtotal, double paid,
      {double total = 0, int inactive = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getValueText('Total amount : \t', '\u20B9 $total', Colors.deepOrange),
        getValueText('Total bill amount : \t', '\u20B9 $subtotal', Colors.blue),
        getValueText('Amount collected : \t', '\u20B9 $paid', Colors.green),
        getValueText('Bill amount pending : \t',
            '\u20B9 ${subtotal - paid}', Colors.red),
        getValueText(
            'Inactive customers : \t', '$inactive', Colors.deepPurple),
      ],
    );
  }

  Future<Map<int, dynamic>> getMonthlyData(List<Customer> customersList) async {
    double total = 0;
    double subtotal = 0;
    double paid = 0;
    final op = operatorDetails;
    if (op == null) return {0: 0.0, 1: 0.0, 2: 0.0, 3: 0};

    for (int i = 0; i < customersList.length; i++) {
      final data = await FirebaseFirestore.instance
          .collection(
              'users/${op.id}/customers/${customersList[i].id}/recharges')
          .get();
      if (data.docs.isNotEmpty) {
        final recharge = getMonthlyRecharge(
            data.docs, DateTime.now().year, DateTime.now().month);
        if (recharge != null && recharge.billPay != null) {
          final p = double.tryParse(recharge.plan ?? '0') ?? 0.0;
          subtotal += p;
          if (recharge.billPay == true) {
            paid += p;
          }
        }
      }
      total += customersList[i].currentPlan;
    }
    final inactive = areas.fold<int>(
      0,
      (previousValue, element) => previousValue + element.inActiveAccounts,
    );
    return {0: total, 1: subtotal, 2: paid, 3: inactive};
  }

  Future<Map<int, double>> getYearlyData(List<Customer> customersList) async {
    double subtotal = 0;
    double paid = 0;
    final op = operatorDetails;
    if (op == null) return {0: 0.0, 1: 0.0};

    for (int i = 0; i < customersList.length; i++) {
      final data = await FirebaseFirestore.instance
          .collection(
              'users/${op.id}/customers/${customersList[i].id}/recharges')
          .get();
      final yearlyRecharges =
          getCustomerYearlyRecharge(data.docs, DateTime.now().year);
      if (yearlyRecharges.isNotEmpty) {
        for (int j = 0; j < yearlyRecharges.length; j++) {
          if (yearlyRecharges[j].billPay != null) {
            final p = double.tryParse(yearlyRecharges[j].plan ?? '0') ?? 0.0;
            subtotal += p;
            if (yearlyRecharges[j].billPay == true) {
              paid += p;
            }
          }
        }
      }
    }
    return {0: subtotal, 1: paid};
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Information'),
      ),
      body: op == null
          ? const Center(child: Text('Operator information missing'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users/${op.id}/customers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final customers =
                      getCustomersFromDoc(snapshot.data!, all: true);
                  return ListView(
                    padding: const EdgeInsets.all(30),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      getTitleText(
                        context,
                        'This month : ${DateFormat('MMMM').format(DateTime.now())}',
                      ),
                      FutureBuilder<Map<int, dynamic>>(
                        future: getMonthlyData(customers),
                        builder: (context, mSnapshot) {
                          if (mSnapshot.hasData) {
                            return valueText(
                              mSnapshot.data![1] as double,
                              mSnapshot.data![2] as double,
                              total: mSnapshot.data![0] as double,
                              inactive: mSnapshot.data![3] as int,
                            );
                          }
                          return Container(
                            alignment: Alignment.center,
                            height: 250,
                            child: FadingText('Please wait ...'),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      getTitleText(
                        context,
                        'Upto \t${DateFormat('MMMM, yyyy').format(DateTime.now())}',
                      ),
                      FutureBuilder<Map<int, double>>(
                        future: getYearlyData(customers),
                        builder: (context, ySnapshot) {
                          if (ySnapshot.hasData) {
                            return valueText(
                              ySnapshot.data![0]!,
                              ySnapshot.data![1]!,
                            );
                          }
                          return Container(
                            alignment: Alignment.center,
                            height: 250,
                            child: FadingText('Please wait ...'),
                          );
                        },
                      ),
                    ],
                  );
                }
                return Center(child: FadingText('Please wait ...'));
              },
            ),
    );
  }
}
