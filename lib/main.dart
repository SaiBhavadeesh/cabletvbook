import 'dart:ui';

import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cableTvBook/helpers/custom_transition.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: BottomTabsScreen(),
      initialRoute: BottomTabsScreen.routeName,
      routes: {
        BottomTabsScreen.routeName: (ctx) => BottomTabsScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        SearchScreen.routeName: (ctx) => SearchScreen(),
        AddCustomerScreen.routeName: (ctx) => AddCustomerScreen(),
        AreaCustomersScreen.routeName: (ctx) => AreaCustomersScreen(),
        CustomerDetailScreen.routeName: (ctx) => CustomerDetailScreen(),
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
      },
    );
  }
}
