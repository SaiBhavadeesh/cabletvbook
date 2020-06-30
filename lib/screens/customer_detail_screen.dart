import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_plan_list.dart';
import 'package:cableTvBook/widgets/customer_primary_info.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  static const routeName = '/customerDetailScreen';

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

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: height * 0.33,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: height * 0.25,
                    width: width,
                    padding: EdgeInsets.symmetric(
                      horizontal: height * 0.01,
                      vertical: height * 0.05,
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
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
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
                    top: height * 0.18,
                    left: width * 0.08,
                    right: width * 0.08,
                    child: CustomerPrimaryInfo(
                      phoneNumber: customer.phoneNumber,
                      accountNumber: customer.accountNumber,
                      macId: customer.macId,
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
                return Column(
                  children: <Widget>[
                    CustomerPlanList(
                      month: DateFormat('MMM').format(
                        DateTime(2020, index + 1),
                      ),
                      billDate: plan[index][0],
                      billAmount: plan[index][1],
                      status: plan[index][2],
                    ),
                    Divider(),
                  ],
                );
              },
              itemCount: plan.length,
            ),
          ],
        ),
      ),
    );
  }
}
