import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';

class AreaCustomersScreen extends StatelessWidget {
  static const routeName = '/areaCustomer';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AreaData area = ModalRoute.of(context).settings.arguments;
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(area.areaName),
          bottom: PreferredSize(
            child: Container(
              color: Colors.amber[700],
              child: TabBar(
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  fontSize: size.height * 0.03,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelColor: Colors.white,
                unselectedLabelStyle: TextStyle(
                  fontSize: size.height * 0.02,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  SizedBox(
                      width: size.width * 0.225,
                      child: Align(child: Text('All'))),
                  SizedBox(
                      width: size.width * 0.225,
                      child: Align(child: Text('Pending'))),
                  SizedBox(
                      width: size.width * 0.225,
                      child: Align(child: Text('Credits'))),
                  SizedBox(
                      width: size.width * 0.225,
                      child: Align(child: Text('Active'))),
                  SizedBox(
                      width: size.width * 0.225,
                      child: Align(child: Text('Inactive'))),
                ],
              ),
            ),
            preferredSize: Size(
              size.width,
              size.height * 0.025,
            ),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(
                    'users/${operatorDetails.id}/areas/${area.id}/customers')
                .orderBy('name')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final customers = getAreaCustomers(snapshot.data.documents);
                return customers.isEmpty
                    ? Center(
                        child: Text('No customer to show',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      )
                    : TabBarView(
                        children: [
                          SearchScreenWidget(
                              all: true, providedCustomers: customers),
                          SearchScreenWidget(
                              inactive: true, providedCustomers: customers),
                          SearchScreenWidget(
                              credits: true, providedCustomers: customers),
                          SearchScreenWidget(
                              active: true, providedCustomers: customers),
                          SearchScreenWidget(
                              inactive: true, providedCustomers: customers),
                        ],
                      );
              }
              return Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.3),
                child: Center(
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballClipRotateMultiple),
                ),
              );
            }),
      ),
    );
  }
}
