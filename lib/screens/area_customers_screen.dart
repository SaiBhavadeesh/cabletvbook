import 'package:flutter/material.dart';
import 'package:cableTvBook/models/operator.dart';
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
            body: TabBarView(children: [
              SearchScreenWidget(all: true, areaId: area.id),
              SearchScreenWidget(pending: true, areaId: area.id),
              SearchScreenWidget(credits: true, areaId: area.id),
              SearchScreenWidget(active: true, areaId: area.id),
              SearchScreenWidget(inactive: true, areaId: area.id),
            ])));
  }
}
