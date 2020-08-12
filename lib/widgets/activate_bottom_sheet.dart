import 'dart:ui';

import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivateBottomSheet extends StatefulWidget {
  final customerId;
  final areaId;
  final recentRecharge;
  final plan;
  ActivateBottomSheet(
      {this.customerId, this.areaId, this.recentRecharge, this.plan});
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Select Period : ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: Theme.of(context).primaryColor,
                        value: 1,
                        groupValue: _selectedTerm,
                        onChanged: _selectTermField,
                      ),
                      Text('1 Month'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: Theme.of(context).primaryColor,
                        value: 12,
                        groupValue: _selectedTerm,
                        onChanged: _selectTermField,
                      ),
                      Text('12 Months'),
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
                  Align(
                    child: defaultbutton(
                      context: context,
                      function: () async {
                        final url = "https://www.actcorp.in";
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
                                          context, scaffoldKey,
                                          customerId: widget.customerId,
                                          areaId: widget.areaId,
                                          plan: _selectedPlan,
                                          term: _selectedTerm,
                                          billPay: _checked,
                                          recentRecharge:
                                              widget.recentRecharge);
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
