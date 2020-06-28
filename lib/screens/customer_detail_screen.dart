import 'package:cableTvBook/models/customer.dart';
import 'package:flutter/material.dart';

class CustomerDetailScreen extends StatelessWidget {
  static const routeName = '/customerDetailScreen';
  @override
  Widget build(BuildContext context) {
    final Customer customer = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
      ),
    );
  }
}
