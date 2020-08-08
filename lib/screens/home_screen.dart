import 'dart:ui';
import 'dart:async';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:flutter/material.dart';

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';

final List<Color> colors = [
  Colors.red,
  Colors.blue,
  Colors.purple,
  Colors.pink,
  Colors.indigo,
  Colors.green,
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
  int _initYear = operatorDetails.startDate.year;
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
    if (_selectedYear == _initYear) _isLeftActive = false;
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

  Future<dynamic> showEditOrAddDialog({int index = -1}) {
    return showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        if (index >= 0) textController.text = areas[index].areaName;
        return Form(
          key: _formKey,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: AlertDialog(
              title: Text(
                index < 0 ? 'Add new area' : 'Edit area name',
              ),
              content: index < 0
                  ? Column(
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
                          validator: nameValidator,
                          decoration: inputDecoration(icon: Icons.add_location),
                        ),
                      ],
                    )
                  : TextFormField(
                      maxLength: 10,
                      controller: textController,
                      validator: nameValidator,
                      decoration: inputDecoration(icon: Icons.edit_location),
                    ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'),
                  textColor: Theme.of(context).errorColor,
                ),
                FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      if (index < 0) {
                        bool isExist = false;
                        areas.forEach((element) {
                          if (element.areaName == textController.text.trim())
                            isExist = true;
                        });
                        if (isExist) {
                          await DefaultDialogBox.errorDialog(ctx,
                              title: 'Alert !',
                              content: 'Area already exists !');
                        } else
                          await DatabaseService.addArea(context, scaffoldKey,
                              data: AreaData(areaName: textController.text)
                                  .toJson());
                      } else
                        await DatabaseService.updateArea(context, scaffoldKey,
                            data: areas[index].toJson()
                              ..['areaName'] = textController.text);
                      Navigator.of(ctx).pop();
                      setState(() {});
                    }
                  },
                  child: Text(
                    'save',
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox(),
        elevation: 0,
        bottom: PreferredSize(
          child: Column(
            children: <Widget>[
              Text(
                operatorDetails.networkName,
                style: TextStyle(
                  fontSize: (size.height - top) * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.width * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      operatorDetails.name,
                      style: TextStyle(
                        fontSize: (size.height - top) * 0.023,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      operatorDetails.phoneNumber,
                      style: TextStyle(
                        fontSize: (size.height - top) * 0.023,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
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
            ],
          ),
          preferredSize: Size(size.width, size.width * 0.15),
        ),
      ),
      body: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: areas.length,
        itemBuilder: (context, index) => GestureDetector(
          child: Container(
            margin: EdgeInsets.all(size.width * 0.025),
            padding: EdgeInsets.all(size.width * 0.04),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  areas[index].areaName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.06,
                    color: Colors.white,
                  ),
                ),
                Divider(color: Colors.black38),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Total customers : ${areas[index].totalAccounts}',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ),
                Divider(color: Colors.black38),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Active : ${areas[index].activeAccounts}',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ),
                Divider(color: Colors.black38),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'In-Active : ${areas[index].inActiveAccounts}',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () => Navigator.of(context).pushNamed(
            AreaCustomersScreen.routeName,
            arguments: areas[index],
          ),
          onLongPress: () => showEditOrAddDialog(index: index),
        ),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
      ),
      floatingActionButton: areas.length < 16
          ? defaultbutton(
              context: context,
              function: () => showEditOrAddDialog(),
              title: 'Add Area',
              height: 12,
              width: 18,
              icon: Icons.add_location)
          : null,
    );
  }
}
