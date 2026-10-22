import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';

class BottomTabsScreen extends StatefulWidget {
  static const routeName = '/bottomTabsScreen';
  final int index;

  const BottomTabsScreen({super.key, this.index = 0});

  @override
  _BottomTabsScreenState createState() => _BottomTabsScreenState();
}

class _BottomTabsScreenState extends State<BottomTabsScreen> {
  late int _currentIndex;
  File? _profilePic;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    final user = firebaseUser;

    ImageProvider avatarImage;
    if (_profilePic != null) {
      avatarImage = FileImage(_profilePic!);
    } else {
      avatarImage = getAvatarImageProvider(op?.profileImageLink);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_count == 0) {
          _count++;
          Fluttertoast.showToast(
            msg: 'Press again to exit',
            backgroundColor: Colors.grey[800],
            textColor: Colors.white,
          );
          Future.delayed(const Duration(seconds: 2), () => _count = 0);
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cable Tv Book'),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () async {
                  final picked = await ImageGetter.getImageFromDevice(context);
                  if (picked != null) {
                    _profilePic = picked;
                    await DatabaseService.uploadProfilePicture(context,
                        file: _profilePic!);
                    if (mounted) setState(() {});
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: avatarImage,
                ),
              ),
            )
          ],
        ),
        drawer: HomeDrawer(image: _profilePic),
        body: const [
          HomeScreen(),
          SearchScreen(),
          AddCustomerScreen(),
        ][_currentIndex],
        bottomNavigationBar: ConvexAppBar(
          elevation: 5,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          initialActiveIndex: _currentIndex,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlpha(200),
              Theme.of(context).primaryColor.withAlpha(150),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          style: TabStyle.textIn,
          items: [
            TabItem(
              icon: Icon(Icons.home,
                  color: _currentIndex == 0 ? Colors.white : Colors.black),
              title: 'Home',
            ),
            TabItem(
              icon: Icon(Icons.search,
                  color: _currentIndex == 1 ? Colors.white : Colors.black),
              title: 'Search',
            ),
            TabItem(
              icon: Icon(Icons.person_add,
                  color: _currentIndex == 2 ? Colors.white : Colors.black),
              title: 'Add customer',
            ),
          ],
        ),
        bottomSheet: (user != null && user.emailVerified)
            ? null
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.elliptical(50, 50)),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Please verify your email & Restart the App\n\n',
                    children: [
                      TextSpan(
                        text:
                            'Go to ( \u2630 -> settings ) to get link to verify email',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                    style: TextStyle(color: Colors.white, fontSize: 26),
                  ),
                ),
              ),
      ),
    );
  }
}
