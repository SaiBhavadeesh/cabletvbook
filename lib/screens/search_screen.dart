import 'package:flutter/material.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/searchScreen';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
        length: 5,
        initialIndex: 0,
        child: Scaffold(
            appBar: AppBar(
              leading: SizedBox(),
              backgroundColor: Colors.amber[700],
              bottom: PreferredSize(
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
                preferredSize: Size(
                  size.width,
                  size.height * -0.025,
                ),
              ),
            ),
            body: TabBarView(children: <Widget>[
              SearchScreenWidget(all: true),
              SearchScreenWidget(pending: true),
              SearchScreenWidget(credits: true),
              SearchScreenWidget(active: true),
              SearchScreenWidget(inactive: true),
            ])));
  }
}
