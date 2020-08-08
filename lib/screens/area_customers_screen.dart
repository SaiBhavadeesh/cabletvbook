import 'package:cableTvBook/models/operator.dart';
import 'package:flutter/material.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';

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
              size.height * 0.02,
            ),
          ),
        ),
        body: FutureBuilder(
          future: getAreaCustomers(area.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.3),
                child: Center(
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballClipRotateMultiple),
                ),
              );
            return TabBarView(
              children: [
                SearchScreenWidget(
                  active: true,
                  providedCustomers: snapshot.data,
                ),
                SearchScreenWidget(
                  all: true,
                  providedCustomers: snapshot.data,
                ),
                SearchScreenWidget(
                  inactive: true,
                  providedCustomers: snapshot.data,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
