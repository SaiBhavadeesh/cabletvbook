import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/screens/signup_screen.dart';
import 'package:cableTvBook/screens/profile_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/services/initial_screen.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:cableTvBook/screens/collection_screen.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:cableTvBook/firebase_options.dart';
import 'package:cableTvBook/theme/app_theme.dart';

class _AuthDeepLinkInterceptor extends WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final location = routeInformation.uri.toString();
    if (location.contains('authType=verifyApp') ||
        location.contains('recaptchaToken') ||
        location.startsWith('/link')) {
      // Intercepted: Firebase Auth handles this natively via openURL.
      // Returning true prevents Flutter Navigator from pushing any route or blank screen.
      return true;
    }
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(_AuthDeepLinkInterceptor());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Support portrait and landscape across phones, tablets, and foldables
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cable TV Book',
      theme: AppTheme.lightTheme,
      home: const InitialScreen(),
      routes: {
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        SigninScreen.routeName: (ctx) => const SigninScreen(),
        SignupScreen.routeName: (ctx) => const SignupScreen(),
        SearchScreen.routeName: (ctx) => const SearchScreen(),
        ProfileScreen.routeName: (ctx) => const ProfileScreen(),
        RegisterScreen.routeName: (ctx) => const RegisterScreen(),
        SettingsScreen.routeName: (ctx) => const SettingsScreen(),
        CollectionScreen.routeName: (ctx) => const CollectionScreen(),
        BottomTabsScreen.routeName: (ctx) => const BottomTabsScreen(),
        AddCustomerScreen.routeName: (ctx) => const AddCustomerScreen(),
        AreaCustomersScreen.routeName: (ctx) => const AreaCustomersScreen(),
        CustomerDetailScreen.routeName: (ctx) => const CustomerDetailScreen(),
      },
    );
  }
}
