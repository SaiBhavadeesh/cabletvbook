import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/searchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).primaryColor.withOpacity(0.3),
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              prefixIcon: Icon(FlutterIcons.ios_search_ion),
              hintText: 'Search by Name / mac no / acc no.',
            ),
          ),
        ),
      ),
    );
  }
}
