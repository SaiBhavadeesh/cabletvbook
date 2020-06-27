import 'package:cableTvBook/models/customer.dart';
import 'package:flutter/material.dart';

class AreaCustomersScreen extends StatelessWidget {
  static const routeName = '/areaCustomer';
  @override
  Widget build(BuildContext context) {
    final AreaData area = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(area.areaName),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Container(
            child: Center(
              child: Text('No customers'),
            ),
          );
        },
      ),
    );
  }
}
