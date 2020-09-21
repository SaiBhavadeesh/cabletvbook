import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/Payment%20Gateway/razor_pay_screen.dart';

class InitialScreen extends StatelessWidget {
  Future<void> initialData(BuildContext context) async {
    firebaseUser = await FirebaseAuth.instance.currentUser();
    try {
      await DatabaseService.getuserData();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed getting data !');
      await FirebaseAuth.instance.signOut();
      firebaseUser = null;
    }
    if (firebaseUser != null && firebaseUser.phoneNumber == null)
      try {
        await FirebaseAuth.instance.signOut();
        firebaseUser = null;
      } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: initialData(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'))),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.15,
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: LoadingIndicator(
                      color: Colors.orange,
                      indicatorType: Indicator.ballSpinFadeLoader),
                ),
              );
            else {
              if (firebaseUser == null)
                return SigninScreen();
              else if (firebaseUser.phoneNumber == null)
                return SigninScreen();
              else if (!operatorDetails.isSubscribed)
                return RazorPayScreen();
              else
                return BottomTabsScreen();
            }
          }),
    );
  }
}
