import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';

import 'package:cableTvBook/theme/app_colors.dart';

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
      backgroundColor: AppColors.canvasDark,
      body: FutureBuilder(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Seamless full-screen brand splash background
                Image.asset(
                  'assets/images/splash.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Bottom loading indicator with subtle theme palette
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 38,
                        width: 38,
                        child: const LoadingIndicator(
                          colors: [
                            AppColors.secondary,
                            AppColors.primary,
                            AppColors.champagne,
                          ],
                          indicatorType: Indicator.ballSpinFadeLoader,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Initializing operator workspace...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
