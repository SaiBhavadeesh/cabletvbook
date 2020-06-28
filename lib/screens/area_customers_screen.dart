import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:flutter/material.dart';

class AreaCustomersScreen extends StatelessWidget {
  static const routeName = '/areaCustomer';
  @override
  Widget build(BuildContext context) {
    final AreaData area = ModalRoute.of(context).settings.arguments;
    final List<Customer> customers = getAreaCustomers(area.areaName);
    return Scaffold(
      appBar: AppBar(
        title: Text(area.areaName),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (ctx, index) {
          return CustomerTile(
            customer: customers[index],
          );
        },
      ),
    );
  }
}
