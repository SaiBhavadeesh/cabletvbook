import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';

class BottomTabsScreen extends StatefulWidget {
  final networkName;
  final username;
  final phoneNumber;
  BottomTabsScreen({
    this.networkName = 'Sri Rama Cable Network',
    this.username = 'Srinivasa Rao',
    this.phoneNumber = '+ 91 8106263461',
  });

  @override
  _BottomTabsScreenState createState() => _BottomTabsScreenState();
}

class _BottomTabsScreenState extends State<BottomTabsScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cable Tv Book'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(height * 0.01),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/drawer.jpg'),
            ),
          )
        ],
        bottom: PreferredSize(
          child: Column(
            children: <Widget>[
              Text(
                widget.networkName,
                style: TextStyle(fontSize: height * 0.025),
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Welcome ' + widget.username,
                      style: TextStyle(
                       fontSize: height * 0.02,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Phone : ' + widget.phoneNumber,
                      style: TextStyle(
                       fontSize: height * 0.02,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          preferredSize: Size(width, height * 0.07),
        ),
      ),
      drawer: HomeDrawer(),
      body: [HomeScreen(), SearchScreen(), AddCustomerScreen()][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            title: Text('Add customer'),
          ),
        ],
      ),
    );
  }
}
