import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/searchScreen';
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          backgroundColor: Colors.amber[700],
          bottom: PreferredSize(
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
            preferredSize: Size(
              size.width,
              size.height * -0.025,
            ),
          ),
        ),
        body: FutureBuilder(
          future: getAllCustomers(),
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
              children: <Widget>[
                SearchScreenWidget(
                    active: true, providedCustomers: snapshot.data),
                SearchScreenWidget(all: true, providedCustomers: snapshot.data),
                SearchScreenWidget(
                    inactive: true, providedCustomers: snapshot.data),
              ],
            );
          },
        ),
      ),
    );
  }
}
