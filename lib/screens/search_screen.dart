import 'dart:async';

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/searchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  int _initYear = getOperatorDetails().startDate.year;
  int _endYear = DateTime.now().year;
  int _selectedYear;
  bool _isLeftActive = true;
  bool _isRightActive = true;
  bool _animation = true;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _selectedYear = _endYear;
  }

  void _leftArrowClickAction() {
    setState(() {
      _animation = false;
    });
    if (_initYear + 1 < _selectedYear) {
      setState(() {
        _isLeftActive = true;
        _isRightActive = true;
        _selectedYear = _selectedYear - 1;
      });
    } else {
      setState(() {
        _isLeftActive = false;
        _isRightActive = true;
        _selectedYear = _selectedYear - 1;
      });
    }
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
        _animation = true;
      });
      timer.cancel();
    });
  }

  void _rightArrowClickAction() {
    setState(() {
      _animation = false;
    });
    if (_endYear > _selectedYear) {
      setState(() {
        _isRightActive = true;
        _isLeftActive = true;
        _selectedYear = _selectedYear + 1;
      });
    } else {
      setState(() {
        _isRightActive = false;
        _isLeftActive = true;
        _selectedYear = _selectedYear + 1;
      });
    }
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
        _animation = true;
      });
      timer.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _timer.cancel();
    } catch (error) {}
  }

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        disabledColor: Colors.black,
                        color: Theme.of(context).primaryColor,
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: _isLeftActive ? _leftArrowClickAction : null,
                      ),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          curve: Curves.easeOutSine,
                          duration: Duration(milliseconds: 300),
                          style: _animation
                              ? TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.06,
                                  letterSpacing: 2,
                                )
                              : TextStyle(fontSize: 0),
                          child: _animation
                              ? Text(
                                  _selectedYear.toString(),
                                  textAlign: TextAlign.center,
                                )
                              : Text(''),
                        ),
                      ),
                      IconButton(
                        disabledColor: Colors.black,
                        color: Theme.of(context).primaryColor,
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: _isRightActive ? _rightArrowClickAction : null,
                      ),
                    ],
                  ),
                ),
                TabBar(
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
              ],
            ),
            preferredSize: Size(
              size.width,
              size.height * 0.03,
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
