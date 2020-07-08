import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';
import 'package:flutter/material.dart';

class AreaCustomersScreen extends StatelessWidget {
  static const routeName = '/areaCustomer';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AreaData area = ModalRoute.of(context).settings.arguments;
    final List<Customer> customers = getAreaCustomers(area.areaName);
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
                indicator: BoxDecoration(),
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
              size.height * 0.02,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SearchScreenWidget(
              active: true,
              providedCustomers: customers,
            ),
            SearchScreenWidget(
              all: true,
              providedCustomers: customers,
            ),
            SearchScreenWidget(
              inactive: true,
              providedCustomers: customers,
            ),
          ],
        ),
      ),
    );
  }
}
