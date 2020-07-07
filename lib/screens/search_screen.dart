import 'package:cableTvBook/widgets/search_screen_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/searchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber[700],
          bottom: PreferredSize(
            child: TabBar(
              indicator: BoxDecoration(),
              labelColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                fontSize: height * 0.03,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelColor: Colors.white,
              unselectedLabelStyle: TextStyle(
                fontSize: height * 0.02,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Text('Active'),
                Text('All'),
                Text('Inactive'),
              ],
            ),
            preferredSize: Size(
              width,
              -height * 0.03,
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            SearchScreenWidget(active: true),
            SearchScreenWidget(all: true),
            SearchScreenWidget(inactive: true),
          ],
        ),
      ),
    );
  }
}
