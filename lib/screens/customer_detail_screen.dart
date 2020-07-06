import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_plan_list.dart';
import 'package:cableTvBook/widgets/customer_primary_info.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatefulWidget {
  static const routeName = '/customerDetailScreen';

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _isEdit = false;

  void copyTextOnLongTap(
    BuildContext ctx,
    String copy,
    String text,
  ) {
    Clipboard.setData(ClipboardData(text: copy));
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: Duration(milliseconds: 300),
        content: Text('$text copied to Clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Customer customer = ModalRoute.of(context).settings.arguments;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[500],
          title: Text('Service provider'),
          bottom: PreferredSize(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Service provider name',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'phone number',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            preferredSize: Size(width, 10),
          ),
          actions: <Widget>[
            DropdownButton(
              underline: SizedBox(),
              items: [
                DropdownMenuItem(child: Text('2020')),
                DropdownMenuItem(child: Text('2021')),
              ],
              onChanged: (value) {},
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isEdit ? height * 0.355 : height * 0.3,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: height * 0.2,
                      width: width,
                      padding: EdgeInsets.symmetric(
                        horizontal: height * 0.01,
                        vertical: height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(width * 0.2, height * 0.08),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                customer.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Address : ',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: customer.address,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Start Date : ',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: DateFormat('MMMM d, y / EEEE')
                                            .format(customer.startDate),
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: width * 0.075,
                            backgroundImage:
                                AssetImage('assets/images/default_profile.jpg'),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: height * 0.13,
                      left: width * 0.08,
                      right: width * 0.08,
                      child: CustomerPrimaryInfo(
                        phoneNumber: customer.phoneNumber,
                        accountNumber: customer.accountNumber,
                        macId: customer.macId,
                        moreInfo: _isEdit,
                      ),
                    ),
                    Positioned(
                      top: height * 0.22,
                      right: width * 0.1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isEdit = !_isEdit;
                          });
                        },
                        icon: Icon(
                          _isEdit ? Icons.delete : FlutterIcons.edit_ant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 3,
                color: Theme.of(context).primaryColor,
              ),
              CustomerPlanList(),
              Divider(
                thickness: 3,
                color: Theme.of(context).primaryColor,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return CustomerPlanList(
                    month: DateFormat('MMM').format(
                      DateTime(2020, index + 1),
                    ),
                    billDate: plan[index][0],
                    billAmount: plan[index][1],
                    status: plan[index][2],
                  );
                },
                itemCount: plan.length,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      heroTag: 0,
                      onPressed: () {},
                      label: Text(
                        'Activate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.025,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    FloatingActionButton.extended(
                      heroTag: 1,
                      onPressed: () {},
                      label: Text(
                        'Deactivate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.025,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
              Container(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.edit),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
