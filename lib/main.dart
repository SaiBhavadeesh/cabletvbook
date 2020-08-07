import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/screens/signup_screen.dart';
import 'package:cableTvBook/screens/profile_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/services/initial_screen.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:cableTvBook/screens/crop_image_screen.dart';
import 'package:cableTvBook/screens/collection_screen.dart';
import 'package:cableTvBook/helpers/custom_transition.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: Colors.grey,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cable Tv Book',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(14, 137, 234, 1),
        accentColor: Colors.white,
        primaryColorBrightness: Brightness.dark,
        accentColorBrightness: Brightness.light,
        cursorColor: Color.fromRGBO(14, 137, 234, 1),
        iconTheme: IconThemeData(
          color: Color.fromRGBO(14, 137, 234, 1),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(14, 137, 234, 1),
          disabledColor: Colors.blueGrey,
          textTheme: ButtonTextTheme.primary,
        ),
        disabledColor: Colors.blueGrey,
        dividerColor: Color.fromRGBO(14, 137, 234, 1),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
          },
        ),
        platform: TargetPlatform.android,
        dividerTheme: DividerThemeData(
          color: Color.fromRGBO(14, 137, 234, 1).withOpacity(0.2),
          endIndent: 10,
          indent: 10,
          thickness: 1.5,
        ),
        dialogTheme: DialogTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titleTextStyle: TextStyle(
            color: Color.fromRGBO(14, 137, 234, 1),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        fontFamily: 'Roboto',
      ),
      home: InitialScreen(),
      routes: {
        HomeScreen.routeName: (ctx) => HomeScreen(),
        SigninScreen.routeName: (ctx) => SigninScreen(),
        SignupScreen.routeName: (ctx) => SignupScreen(),
        SearchScreen.routeName: (ctx) => SearchScreen(),
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
        RegisterScreen.routeName: (ctx) => RegisterScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        CropImageScreen.routeName: (ctx) => CropImageScreen(),
        CollectionScreen.routeName: (ctx) => CollectionScreen(),
        BottomTabsScreen.routeName: (ctx) => BottomTabsScreen(),
        AddCustomerScreen.routeName: (ctx) => AddCustomerScreen(),
        AreaCustomersScreen.routeName: (ctx) => AreaCustomersScreen(),
        CustomerDetailScreen.routeName: (ctx) => CustomerDetailScreen(),
      },
    );
  }
}
