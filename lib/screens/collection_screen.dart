import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/box_decoration.dart';

class CollectionScreen extends StatelessWidget {
  static const routeName = '/collectionScreen';

  Widget getTitleText(BuildContext context, String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: defaultBoxDecoration(context, true),
      child: Text(
        title,
        style: TextStyle(
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
          style: TextStyle(fontSize: 16, color: Colors.black),
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

  Widget valueText(double subtotal, double paid, {double total, int inactive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (total != null)
          getValueText('Total amount : \t', '\u20B9 $total', Colors.deepOrange),
        getValueText('Total bill amount : \t', '\u20B9 $subtotal', Colors.blue),
        getValueText('Amount collected : \t', '\u20B9 $paid', Colors.green),
        getValueText('Bill amount pending : \t', '\u20B9 ${subtotal - paid}',
            Colors.red),
        if (inactive != null)
          getValueText(
              'Inactive customers : \t', '$inactive', Colors.deepPurple),
      ],
    );
  }

  Future<Map<int, dynamic>> getMonthlyData() async {
    double total = 0;
    double subtotal = 0;
    double paid = 0;
    for (int i = 0; i < customers.length; i++) {
      final data = await FirebaseFirestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customers[i].areaId}/customers/${customers[i].id}/${DateTime.now().year}')
          .where('code', isEqualTo: DateTime.now().month)
          .get();
      if (data.docs.isNotEmpty) {
        final recharge = Recharge.fromMap(data.docs.first.data);
        if (recharge.billPay != null) {
          subtotal += double.parse(recharge.plan);
          if (recharge.billPay) {
            paid += double.parse(recharge.plan);
          }
        }
      }
      total += customers[i].currentPlan;
    }
    final inactive = areas.fold(0,
        (previousValue, element) => previousValue += element.inActiveAccounts);
    return {0: total, 1: subtotal, 2: paid, 3: inactive};
  }

  Future<Map<int, double>> getYearlyData() async {
    double subtotal = 0;
    double paid = 0;
    for (int i = 0; i < customers.length; i++) {
      final data = await FirebaseFirestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customers[i].areaId}/customers/${customers[i].id}/${DateTime.now().year}')
          .get();
      if (data.docs.isNotEmpty) {
        for (int i = 0; i < data.docs.length; i++) {
          final recharge = Recharge.fromMap(data.docs[i].data);
          if (recharge.billPay != null) {
            subtotal += double.parse(recharge.plan);
            if (recharge.billPay) {
              paid += double.parse(recharge.plan);
            }
          }
        }
      }
    }
    return {0: subtotal, 1: paid};
  }

  static List<Customer> customers;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Information'),
      ),
      body: FutureBuilder(
        future: getAllCustomers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            customers = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(30),
              physics: BouncingScrollPhysics(),
              children: [
                getTitleText(
                    context,
                    'This month : ' +
                        DateFormat('MMMM').format(DateTime.now())),
                FutureBuilder(
                  future: getMonthlyData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return valueText(snapshot.data[1], snapshot.data[2],
                          total: snapshot.data[0], inactive: snapshot.data[3]);
                    }
                    return Container(
                        alignment: Alignment.center,
                        height: 250,
                        child: FadingText('Please wait ...'));
                  },
                ),
                SizedBox(height: 20),
                getTitleText(
                    context,
                    'Upto \t' +
                        DateFormat('MMMM, yyyy').format(DateTime.now())),
                FutureBuilder(
                  future: getYearlyData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return valueText(snapshot.data[0], snapshot.data[1]);
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
