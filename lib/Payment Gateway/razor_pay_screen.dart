import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';

class RazorPayScreen extends StatefulWidget {
  static const routeName = 'razorPayScreen';
  @override
  _RazorPayScreenState createState() => _RazorPayScreenState();
}

class _RazorPayScreenState extends State<RazorPayScreen> {
  Razorpay _razorpay;
  Size size;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment successful!\nTransaction-Id : ${response.paymentId}');
    DefaultDialogBox.loadingDialog(context);
    DatabaseService.updateData(context, data: {
      'transactionId': response.paymentId,
      'transactionTime': FieldValue.serverTimestamp(),
      'amountPaid': 1999.00,
      'isSubscribed': true,
    }).then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil(BottomTabsScreen.routeName, (route) => false));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment unsuccessful!\nERROR : ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment not accepted!\nEXTERNAL_WALLET : ${response.walletName}');
  }

  // void _createOrder() {
  //   try {} on PlatformException catch (error) {} catch (_) {}
  // }

  void _openGateway() async {
    var options = {
      'key': 'rzp_live_VB1FsRjK35lsW5',
      'amount': 199900,
      'currency': 'INR',
      'name': 'Srinivasa Softwares',
      'description': 'Subscription for Cable Tv Book',
      'prefill': {
        'name': '${operatorDetails.name}',
        'contact': '${firebaseUser.phoneNumber}',
        'email': '${firebaseUser.email}'
      },
      'theme': {
        'hide_topbar': true,
        'color': '#0e89ea',
      },
    };
    try {
      _razorpay.open(options);
    } catch (_) {
      print('unable to load payment gateway');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Subscribe to continue...'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: CarouselSlider(
                  items: [
                    Image.asset('assets/images/razorpaylogo.png'),
                    Image.asset('assets/images/secure.png'),
                    Image.asset('assets/images/partner.png'),
                    Image.asset('assets/images/razorpay.jpg'),
                  ],
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.vertical)),
            ),
          ),
          Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                    top: Radius.elliptical(
                        size.height * 0.25, size.width * 0.25)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, -5),
                      blurRadius: 5)
                ],
                gradient: LinearGradient(colors: [
                  Colors.green.withOpacity(0.5),
                  Colors.orange.withOpacity(0.5),
                  Colors.pink.withOpacity(0.5)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 75, bottom: 45),
              physics: BouncingScrollPhysics(),
              children: [
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'One time subscription\n',
                        children: [
                          TextSpan(
                              text: '\u20B9 1999.00 Only\n',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5)),
                          TextSpan(
                              text: '  ',
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 16)),
                          TextSpan(
                              text: '\u26A0',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  color: Theme.of(context).errorColor,
                                  fontSize: 14)),
                          TextSpan(
                              text: '  Non-Refundable  ',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  color: Theme.of(context).errorColor,
                                  fontSize: 16,
                                  height: 1.5))
                        ],
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold))),
                SizedBox(height: 30),
                defaultbutton(
                    context: context, function: _openGateway, title: 'Proceed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
