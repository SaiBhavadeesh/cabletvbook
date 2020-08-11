import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cableTvBook/widgets/customer_plan_list.dart';
import 'package:cableTvBook/widgets/modal_bottom_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  static const routeName = '/customerDetailScreen';

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final moreInfoController = TextEditingController();
  Size size;
  int _selectedYear = DateTime.now().year;
  bool _isEdit = false;
  bool _init = true;
  File _pickedImage;
  Customer customer;
  double _selectedPlan;

  List<int> getAllYears(DateTime date) {
    List<int> years = [];
    final startyear = date.year;
    final endYear = DateTime.now().year;
    for (int i = startyear; i <= endYear + 1; i++) {
      years.add(i);
    }
    return years;
  }

  void onMoreInfo() {
    if (_isEdit) {
      DatabaseService.updateCustomerData(context, scaffoldKey,
          data: {'tempInfo': null},
          customerId: customer.id,
          areaId: customer.areaId);
      moreInfoController.clear();
      customer.tempInfo = null;
    }
    setState(() {
      _isEdit = !_isEdit;
    });
  }

  void modalBottomSheet(BuildContext ctx, Customer data) {
    Navigator.of(ctx)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => ModalBottomSheet(customer: data),
        opaque: false,
      ),
    )
        .then((value) {
      setState(() {});
    });
  }

  void copyTextOnLongTap(
    BuildContext ctx,
    String copy,
    String text,
  ) {
    Clipboard.setData(ClipboardData(text: copy));
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: Duration(milliseconds: 300),
        content: Text('$text copied to Clipboard'),
      ),
    );
  }

  Widget richText(String title, String value) {
    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget copyValueWidget(
      BuildContext context, String title, String value, String display) {
    return GestureDetector(
      onTap: () => copyTextOnLongTap(context, value, display),
      child: Card(
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: RichText(
            text: TextSpan(
              text: title,
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget floatingButton(
      Object tag, Function function, String title, Color color) {
    return FloatingActionButton.extended(
      heroTag: tag,
      onPressed: function,
      label: SizedBox(
        width: size.width * 0.25,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.height * 0.025,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      backgroundColor: color,
    );
  }

  void _selectPlanField(double value) {
    setState(() {
      _selectedPlan = value;
    });
  }

  void activateButton() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            
          ],
        ),
      ),
    );
    // final url = "https://www.actcorp.in";
    // if (await canLaunch(url)) {
    //   await launch(
    //     url,
    //     enableJavaScript: true,
    //   );
    // } else {
    //   scaffoldKey.currentState.showSnackBar(SnackBar(
    //     content: Text('Could not process your request, Please try again'),
    //     duration: Duration(seconds: 1),
    //   ));
    // }
    // await showDialog(
    //   context: context,
    //   builder: (ctx) => AlertDialog(
    //     content: Text('Activation successful ?'),
    //     actions: [
    //       FlatButton(
    //         onPressed: () => Navigator.pop(ctx),
    //         child: Text('no'),
    //         color: Theme.of(context).errorColor,
    //       ),
    //       FlatButton(
    //         onPressed: () {},
    //         child: Text('yes'),
    //         color: Theme.of(context).primaryColor,
    //       ),
    //     ],
    //   ),
    // );
  }

  void deactivateButton() async {
    final url = "https://www.actcorp.in";
    if (await canLaunch(url)) {
      await launch(
        url,
        enableJavaScript: true,
      );
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Could not process your request, Please try again'),
        duration: Duration(seconds: 1),
      ));
    }
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('De-activation successful ?'),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('no'),
            color: Theme.of(context).errorColor,
          ),
          FlatButton(
            onPressed: () {},
            child: Text('yes'),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    customer = ModalRoute.of(context).settings.arguments;
    moreInfoController.text = customer.tempInfo ?? '';
    if (_init) _isEdit = customer.tempInfo == null ? false : true;
    _init = false;
    size = MediaQuery.of(context).size;
    final years = getAllYears(customer.startDate);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.red[500],
        title: Text(operatorDetails.networkName),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  operatorDetails.name,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  operatorDetails.phoneNumber,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          preferredSize: Size(size.width, 10),
        ),
        actions: <Widget>[
          DropdownButton(
            icon: Icon(Icons.keyboard_arrow_down),
            underline: SizedBox(),
            value: _selectedYear,
            items: [
              ...years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                  ),
                );
              }).toList()
            ],
            onChanged: (int value) {
              setState(() {
                _selectedYear = value;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.02,
                vertical: size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.yellow,
              ),
              child: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: size.width * 0.75,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: richText('Name : ', customer.name)),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: richText(
                                      'Start Date : ',
                                      DateFormat('MMMM d, y / EEEE')
                                          .format(customer.startDate))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child:
                                      richText('Address : ', customer.address)),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: richText(
                                      'Phone : ', customer.phoneNumber)),
                              copyValueWidget(context, 'Account no : ',
                                  customer.accountNumber, 'Account number'),
                              copyValueWidget(context, 'MAC Id : ',
                                  customer.macId, 'MAC-ID'),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                _pickedImage =
                                    await ImageGetter.getImageFromDevice(
                                        context);
                                await DatabaseService.updateCustomerPicture(
                                    context, scaffoldKey,
                                    file: _pickedImage,
                                    customerId: customer.id,
                                    areaId: customer.areaId);
                                setState(() {});
                              },
                              child: CircleAvatar(
                                radius: size.width * 0.1,
                                backgroundImage: customer.profileImageUrl ==
                                        null
                                    ? _pickedImage == null
                                        ? AssetImage(
                                            'assets/images/default_profile.jpg')
                                        : FileImage(_pickedImage)
                                    : NetworkImage(customer.profileImageUrl),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.call,
                                size: size.height * 0.05,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                final url = "tel:${customer.phoneNumber}";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Could not process your request, Please try again'),
                                    duration: Duration(seconds: 1),
                                  ));
                                }
                              },
                            ),
                            AnimatedCrossFade(
                              duration: Duration(seconds: 1),
                              crossFadeState: _isEdit
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: IconButton(
                                  onPressed: onMoreInfo,
                                  icon: Icon(Icons.note_add)),
                              secondChild: IconButton(
                                  onPressed: onMoreInfo,
                                  icon: Icon(Icons.delete)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: size.width,
                      height: _isEdit ? size.width * 0.10 : 0,
                      padding: const EdgeInsets.only(
                          top: 4.0, left: 4.0, right: 4.0),
                      child: TextFormField(
                        controller: moreInfoController,
                        enabled: customer.tempInfo == null && _isEdit,
                        onEditingComplete: () {
                          if (moreInfoController.text.isNotEmpty)
                            DatabaseService.updateCustomerData(
                                context, scaffoldKey,
                                data: {'tempInfo': moreInfoController.text},
                                customerId: customer.id,
                                areaId: customer.areaId);
                          customer.tempInfo = moreInfoController.text;
                        },
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          labelText: _isEdit ? 'Temperory Info' : null,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
              endIndent: 0,
              indent: 0,
              thickness: 3,
              color: Theme.of(context).primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CustomerPlanList(),
            ),
            Divider(
                endIndent: 0,
                indent: 0,
                thickness: 3,
                color: Theme.of(context).primaryColor),
            FutureBuilder(
              future: getCustomerYearlyRecharge(
                  customer.areaId, customer.id, _selectedYear.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                List<Recharge> rechargeData = snapshot.data;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CustomerPlanList(
                      month: DateFormat('MMM').format(
                        DateTime(_selectedYear, rechargeData[index].date.month),
                      ),
                      billDate:
                          DateFormat('dd/MM').format(rechargeData[index].date),
                      billAmount: rechargeData[index].plan,
                      status: rechargeData[index].status,
                    );
                  },
                  itemCount: rechargeData.length,
                );
              },
            ),
            SizedBox(height: 45),
          ],
        ),
      ),
      floatingActionButton: Row(
        children: <Widget>[
          SizedBox(width: 10),
          floatingButton(0, activateButton, 'Activate', Colors.green),
          Expanded(child: SizedBox()),
          FloatingActionButton(
            onPressed: () => modalBottomSheet(context, customer),
            child: Icon(FlutterIcons.account_edit_outline_mco),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          Expanded(child: SizedBox()),
          floatingButton(1, deactivateButton, 'Deactivate', Colors.red),
          SizedBox(width: 10),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
