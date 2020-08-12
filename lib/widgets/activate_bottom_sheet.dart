import 'dart:ui';

import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivateBottomSheet extends StatefulWidget {
  final customerId;
  final areaId;
  final int year;
  final plan;
  ActivateBottomSheet(
      {@required this.customerId,
      @required this.areaId,
      @required this.year,
      @required this.plan});
  @override
  _ActivateBottomSheetState createState() => _ActivateBottomSheetState();
}

class _ActivateBottomSheetState extends State<ActivateBottomSheet> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double _selectedPlan;
  bool _checked = true;
  int _selectedTerm = 1;

  void _selectPlanField(double value) {
    setState(() {
      _selectedPlan = value;
    });
  }

  void _selectTermField(int value) {
    setState(() {
      _selectedTerm = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.plan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black45,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Plan : ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  ...operatorDetails.plans.map(
                    (plan) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Radio(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: Theme.of(context).primaryColor,
                            value: plan,
                            groupValue: _selectedPlan,
                            onChanged: _selectPlanField,
                          ),
                          Text('\u20B9 ' + plan.toString()),
                        ],
                      );
                    },
                  ).toList(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Period : ',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 20),
                      DropdownButton(
                          items: [
                            DropdownMenuItem(child: Text('1 Month'), value: 1),
                            DropdownMenuItem(child: Text('2 Months'), value: 2),
                            DropdownMenuItem(child: Text('3 Months'), value: 3),
                            DropdownMenuItem(child: Text('4 Months'), value: 4),
                            DropdownMenuItem(child: Text('5 Months'), value: 5),
                            DropdownMenuItem(child: Text('6 Months'), value: 6),
                            DropdownMenuItem(child: Text('7 Months'), value: 7),
                            DropdownMenuItem(child: Text('8 Months'), value: 8),
                            DropdownMenuItem(child: Text('9 Months'), value: 9),
                            DropdownMenuItem(
                                child: Text('10 Months'), value: 10),
                            DropdownMenuItem(
                                child: Text('11 Months'), value: 11),
                            DropdownMenuItem(
                                child: Text('12 Months'), value: 12),
                          ],
                          onChanged: _selectTermField,
                          isDense: true,
                          underline: SizedBox(),
                          value: _selectedTerm),
                    ],
                  ),
                  Divider(),
                  CheckboxListTile(
                    activeColor: Colors.green,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _checked,
                    title: Text('Un-check this box, if bill not paid.'),
                    onChanged: (value) {
                      setState(() {
                        _checked = !_checked;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 10),
                  Align(
                    child: defaultbutton(
                      context: context,
                      function: () async {
                        final url = "https://partnerportal.actcorp.in/packages";
                        if (await canLaunch(url)) {
                          try {
                            await launch(
                              url,
                              forceSafariVC: true,
                              forceWebView: true,
                              enableJavaScript: true,
                            );
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                content: Text('Activation successful ?'),
                                actions: [
                                  FlatButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('no'),
                                    color: Theme.of(ctx).errorColor,
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await DatabaseService.rechargeCustomer(
                                        context,
                                        scaffoldKey,
                                        customerId: widget.customerId,
                                        areaId: widget.areaId,
                                        year: widget.year.toString(),
                                        plan: _selectedPlan,
                                        term: _selectedTerm,
                                        billPay: _checked,
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text('yes'),
                                    color: Theme.of(ctx).primaryColor,
                                  ),
                                ],
                              ),
                            );
                          } catch (_) {}
                        } else {
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                                'Could not process your request, Please try again'),
                            duration: Duration(seconds: 1),
                          ));
                        }
                      },
                      title: 'Recharge',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
