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
import 'package:cableTvBook/helpers/custom_transition.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:cableTvBook/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarDividerColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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
    const primaryBlue = Color.fromRGBO(14, 137, 234, 1);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cable Tv Book',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: Colors.white,
          error: Colors.red,
        ),
        iconTheme: const IconThemeData(
          color: primaryBlue,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
          },
        ),
        dividerTheme: DividerThemeData(
          color: primaryBlue.withAlpha(51),
          endIndent: 10,
          indent: 10,
          thickness: 1.5,
        ),
        dialogTheme: DialogThemeData(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titleTextStyle: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        fontFamily: 'Roboto',
      ),
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
