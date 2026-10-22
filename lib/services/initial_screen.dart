import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  late Future<void> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
      final user = firebaseUser;
      if (user != null) {
        await user.reload();
        await DatabaseService.getuserData();
      }
    } catch (_) {
      Fluttertoast.showToast(msg: 'Failed getting user data');
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      firebaseUser = null;
      operatorDetails = null;
    }
    if (firebaseUser != null && firebaseUser!.phoneNumber == null) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      firebaseUser = null;
      operatorDetails = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            final width = MediaQuery.of(context).size.width;
            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/splash.png'),
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                height: width * 0.15,
                width: width * 0.15,
                child: const LoadingIndicator(
                  colors: [Colors.orange],
                  indicatorType: Indicator.ballSpinFadeLoader,
                ),
              ),
            );
          } else {
            final user = firebaseUser;
            final op = operatorDetails;
            if (user == null || user.phoneNumber == null || op == null) {
              return const SigninScreen();
            } else {
              return const BottomTabsScreen();
            }
          }
        },
      ),
    );
  }
}
