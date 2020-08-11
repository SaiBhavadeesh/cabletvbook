import 'package:flutter/material.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';

class AreaCustomersScreen extends StatelessWidget {
  static const routeName = '/areaCustomer';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AreaData area = ModalRoute.of(context).settings.arguments;
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(area.areaName),
          bottom: PreferredSize(
            child: Container(
              color: Colors.amber[700],
              child: TabBar(
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
                  Text('Active'),
                  Text('All'),
                  Text('Inactive'),
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
            stream: Firestore.instance
                .collection(
                    'users/${operatorDetails.id}/areas/${area.id}/customers')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final customers = getAreaCustomers(snapshot.data.documents);
                return TabBarView(
                  children: [
                    SearchScreenWidget(
                        active: true, providedCustomers: customers),
                    SearchScreenWidget(all: true, providedCustomers: customers),
                    SearchScreenWidget(
                        inactive: true, providedCustomers: customers),
                  ],
                );
              }
              return Container();
            }),
      ),
    );
  }
}
