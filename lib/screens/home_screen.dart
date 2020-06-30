import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cableTvBook/screens/area_customers_screen.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:flutter_icons/flutter_icons.dart';

final List<Color> colors = [
  Colors.red,
  Colors.blue,
  Colors.purple,
  Colors.pink,
  Colors.green,
  Colors.indigo,
  Colors.brown,
  Colors.orange,
];

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year.floor();
  int _selectedYear;
  bool _isLeftActive = true;
  bool _isRightActive = true;
  bool _animation = true;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _selectedYear = _year;
  }

  void _leftArrowClickAction() {
    setState(() {
      _animation = false;
    });
    if (_year - _selectedYear + 1 <= 0) {
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
    if (_year - _selectedYear - 1 >= 0) {
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
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: width * 0.01),
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
                  curve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 300),
                  style: _animation
                      ? TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.06,
                          letterSpacing: 2,
                        )
                      : TextStyle(fontSize: 0),
                  child: Text(
                    _selectedYear.toString(),
                    textAlign: TextAlign.center,
                  ),
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
        preferredSize: Size(width, width * 0.15),
      ),
      body: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: areas.length,
        itemBuilder: (context, index) => GestureDetector(
          child: Container(
            margin: EdgeInsets.all(width * 0.025),
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.darken,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(3, 3),
                  spreadRadius: 5,
                  blurRadius: 5,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  colors[index % 8].withOpacity(0.4),
                  colors[index % 8].withOpacity(0.6),
                  colors[index % 8].withOpacity(0.8),
                  colors[index % 8].withOpacity(0.6),
                  colors[index % 8].withOpacity(1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              children: <Widget>[
                Text(
                  areas[index].areaName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.06,
                    color: Colors.white,
                  ),
                ),
                Divider(color: Colors.black38),
                Text(
                  'Total customers : ${areas[index].totalAccounts}',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.white,
                  ),
                ),
                Divider(color: Colors.black38),
                Text(
                  'Active : ${areas[index].activeAccounts}',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.white,
                  ),
                ),
                Divider(color: Colors.black38),
                Text(
                  'In-Active : ${areas[index].inActiveAccounts}',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => Navigator.of(context).pushNamed(
            AreaCustomersScreen.routeName,
            arguments: areas[index],
          ),
          onLongPress: () => showDialog(
            context: context,
            builder: (ctx) {
              final textController = TextEditingController();
              return Form(
                key: _formKey,
                child: AlertDialog(
                  title: Text(
                    'Edit name',
                  ),
                  content: TextFormField(
                    maxLength: 10,
                    controller: textController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Name is empty!';
                      } else if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
                        return 'Name must start with a letter!';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            areas[index].areaName = textController.text;
                          });
                          Navigator.of(ctx).pop();
                        }
                      },
                      icon: Icon(FlutterIcons.content_save_edit_mco),
                      label: Text('save'),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: width * 0.025),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (ctx) {
            final textController = TextEditingController();
            return Form(
              key: _formKey,
              child: AlertDialog(
                title: Text('Add New Area'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'NOTE : This action cannot be undone, Please make sure before adding.\n',
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                    TextFormField(
                      maxLength: 10,
                      controller: textController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Name is empty!';
                        } else if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
                          return 'Name must start with a letter!';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        setState(() {
                          areas.add(AreaData(areaName: textController.text));
                        });
                        Navigator.of(ctx).pop();
                      }
                    },
                    icon: Icon(FlutterIcons.content_save_mco),
                    label: Text('save'),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            );
          },
        ),
        child: Icon(
          FlutterIcons.add_to_list_ent,
          color: Theme.of(context).accentColor,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
