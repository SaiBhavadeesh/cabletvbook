import 'package:flutter/material.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/searchScreen';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox.shrink(),
          backgroundColor: Colors.amber[700],
          bottom: PreferredSize(
            preferredSize: Size(
              size.width,
              size.height * 0.05,
            ),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                fontSize: size.height * 0.025,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelColor: Colors.white,
              unselectedLabelStyle: TextStyle(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                SizedBox(
                    width: size.width * 0.2,
                    child: const Align(child: Text('All'))),
                SizedBox(
                    width: size.width * 0.2,
                    child: const Align(child: Text('Pending'))),
                SizedBox(
                    width: size.width * 0.2,
                    child: const Align(child: Text('Credits'))),
                SizedBox(
                    width: size.width * 0.2,
                    child: const Align(child: Text('Active'))),
                SizedBox(
                    width: size.width * 0.2,
                    child: const Align(child: Text('Inactive'))),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            SearchScreenWidget(all: true),
            SearchScreenWidget(pending: true),
            SearchScreenWidget(credits: true),
            SearchScreenWidget(active: true),
            SearchScreenWidget(inactive: true),
          ],
        ),
      ),
    );
  }
}
