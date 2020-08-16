import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';

List<Customer> customers = [];

class SearchScreen extends StatefulWidget {
  static const routeName = '/searchScreen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
            if (snapshot.hasData) {
              customers = snapshot.data;
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
                      children: <Widget>[
                        SearchScreenWidget(active: true, isRefreshable: true),
                        SearchScreenWidget(all: true, isRefreshable: true),
                        SearchScreenWidget(inactive: true, isRefreshable: true),
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
          },
        ),
      ),
    );
  }
}
