import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/widgets/customer_plan_list.dart';
import 'package:cableTvBook/widgets/activate_bottom_sheet.dart';
import 'package:cableTvBook/widgets/customer_edit_bottom_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  static const routeName = '/customerDetailScreen';

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final moreInfoController = TextEditingController();
  Size size;
  int _selectedYear;
  bool _isEdit = false;
  bool _init = true;
  File _pickedImage;
  Customer customer;
  List<Recharge> rechargeData;

  List<int> getAllYears(DateTime date, int runningYear) {
    List<int> years = [];
    final startyear = date.year;
    for (int i = startyear; i <= runningYear; i++) {
      years.add(i);
    }
    return years;
  }

  void onMoreInfo() {
    if (_isEdit && customer.tempInfo != null) {
      DatabaseService.updateCustomerData(context,
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
    Navigator.of(ctx).push(PageRouteBuilder(
        pageBuilder: (context, _, __) =>
            CustomerEditBottomSheet(customer: data),
        opaque: false));
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

  void activateButton(BuildContext ctx) {
    Navigator.of(ctx).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => ActivateBottomSheet(
              customerId: customer.id,
              areaId: customer.areaId,
              status: customer.currentStatus,
              year: customer.runningYear,
              plan: customer.currentPlan,
              unpaidNo: customer.noOfPendingBills,
            ),
        opaque: false));
  }

  void deactivateButton() async {
    if (customer.currentStatus != 'Active') {
      DefaultDialogBox.errorDialog(context,
          title: 'Alert !',
          content: 'Customer has no active plan to deactivate !');
    } else {
      final url = "https://partnerportal.actcorp.in/packages";
      if (await canLaunch(url)) {
        try {
          await launch(
            url,
            // forceSafariVC: true,
            // forceWebView: true,
            enableJavaScript: true,
          );
        } catch (_) {}
      } else {
        Fluttertoast.showToast(
            msg: 'Could not process your request, Please try again');
      }
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text('De-activation successful ?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('no'),
              color: Theme.of(ctx).errorColor,
            ),
            FlatButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await DatabaseService.deactivateCustomer(context,
                    customerId: customer.id,
                    areaId: customer.areaId,
                    year: customer.runningYear.toString());
              },
              child: Text('yes'),
              color: Theme.of(ctx).primaryColor,
            ),
          ],
        ),
      );
    }
  }

  void deleteRecharge(
      BuildContext ctx, Recharge recharge, bool prevRecharge) async {
    if (recharge.status &&
        DateTime.now().difference(recharge.date) < Duration(days: 10))
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete recharge'),
          content: Text('Are you sure ?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('no'),
              color: Theme.of(ctx).errorColor,
            ),
            FlatButton(
              onPressed: () async {
                String year = _selectedYear.toString();
                if (_selectedYear != customer.startDate.year)
                  _selectedYear -= 1;
                Navigator.pop(ctx);
                final value = await DatabaseService.deleteRecharge(context,
                    customerId: customer.id,
                    areaId: customer.areaId,
                    year: year,
                    startYear: customer.startDate.year.toString(),
                    prevRecharge: prevRecharge,
                    recharge: recharge,
                    unPaidNo: customer.noOfPendingBills);
                setState(() {
                  if (!value && int.parse(year) != customer.startDate.year)
                    _selectedYear = _selectedYear + 1;
                });
              },
              child: Text('yes'),
              color: Theme.of(ctx).primaryColor,
            ),
          ],
        ),
      );
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_init) {
      customer = ModalRoute.of(context).settings.arguments;
      _isEdit = customer.tempInfo == null ? false : true;
      _selectedYear = customer.runningYear;
    }
    _init = false;
    size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customer.areaId}/customers')
          .doc(customer.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          customer = Customer.fromMap(snapshot.data);
          final years = getAllYears(customer.startDate, customer.runningYear);
          moreInfoController.text = customer.tempInfo ?? '';
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red[500],
              title: Text(operatorDetails.networkName),
              bottom: PreferredSize(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
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
                  onChanged: (value) {
                    if (_selectedYear != value)
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
                                        child:
                                            richText('Name : ', customer.name)),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: richText(
                                            'Start Date : ',
                                            DateFormat('MMMM d, y / EEEE')
                                                .format(customer.startDate))),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: richText(
                                            'Address : ', customer.address)),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: richText(
                                            'Phone : ', customer.phoneNumber)),
                                    copyValueWidget(
                                        context,
                                        'Account no : ',
                                        customer.accountNumber,
                                        'Account number'),
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
                                      if (_pickedImage != null) {
                                        await DatabaseService
                                            .updateCustomerPicture(context,
                                                file: _pickedImage,
                                                customerId: customer.id,
                                                areaId: customer.areaId);
                                        setState(() {});
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: size.width * 0.1,
                                      backgroundImage: customer
                                                  .profileImageUrl ==
                                              null
                                          ? _pickedImage == null
                                              ? AssetImage(
                                                  'assets/images/default_profile.jpg')
                                              : FileImage(_pickedImage)
                                          : NetworkImage(
                                              customer.profileImageUrl),
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
                                        Fluttertoast.showToast(
                                            msg:
                                                'Could not process your request, Please try again');
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
                                  DatabaseService.updateCustomerData(context,
                                      data: {
                                        'tempInfo': moreInfoController.text
                                      },
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
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(
                            'users/${firebaseUser.uid}/areas/${customer.areaId}/customers/${customer.id}/$_selectedYear')
                        .orderBy('code')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        rechargeData =
                            getCustomerYearlyRecharge(snapshot.data.documents);
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () => deleteRecharge(
                                  context,
                                  rechargeData[index],
                                  _selectedYear != customer.startDate.year ||
                                          index > 0
                                      ? true
                                      : false),
                              child: CustomerPlanList(
                                customerId: customer.id,
                                areaId: customer.areaId,
                                id: rechargeData[index].id,
                                billPay: rechargeData[index].billPay,
                                year: _selectedYear.toString(),
                                month: DateFormat('MMMM').format(
                                  DateTime(
                                      _selectedYear, rechargeData[index].code),
                                ),
                                billDate: rechargeData[index].billPay == null
                                    ? ''
                                    : DateFormat('dd/MM/yyyy').format(
                                        rechargeData[index].date ??
                                            DateTime.now()),
                                billAmount: rechargeData[index].plan ?? '',
                                status: rechargeData[index].status
                                    ? 'Active'
                                    : 'Inactive',
                                addInfo: rechargeData[index].addInfo,
                                unpaidBill: customer.noOfPendingBills,
                              ),
                            );
                          },
                          itemCount: rechargeData.length,
                        );
                      }
                      return Container(
                          alignment: Alignment.center,
                          height: 250,
                          child: FadingText('Please wait ...'));
                    },
                  ),
                  SizedBox(height: size.height * 0.125),
                ],
              ),
            ),
            floatingActionButton: Row(
              children: <Widget>[
                SizedBox(width: 10),
                floatingButton(
                    0, () => activateButton(context), 'Activate', Colors.green),
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red[500],
              title: Text(operatorDetails.networkName),
              bottom: PreferredSize(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
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
            ),
          );
        }
      },
    );
  }
}
