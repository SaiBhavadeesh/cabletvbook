import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';
import 'package:cableTvBook/widgets/app_logo.dart';

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

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return operatorDetails?.networkName ?? 'Cable TV Book';
      case 1:
        return 'Customer Directory';
      case 2:
        return 'Add Customer';
      default:
        return 'Cable TV Book';
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    final user = firebaseUser;
    final isWide = Responsive.isWide(context);

    ImageProvider avatarImage;
    if (_profilePic != null) {
      avatarImage = FileImage(_profilePic!);
    } else {
      avatarImage = getAvatarImageProvider(op?.profileImageLink);
    }

    final screens = const [
      HomeScreen(),
      SearchScreen(),
      AddCustomerScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        if (_count == 0) {
          _count++;
          Fluttertoast.showToast(
            msg: 'Press back again to exit',
            backgroundColor: AppColors.textPrimary,
            textColor: Colors.white,
          );
          Future.delayed(const Duration(seconds: 2), () => _count = 0);
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentIndex == 0) ...[
                const AppLogo(size: 32, borderRadius: 8, hasShadow: false),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  _getScreenTitle(_currentIndex),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12),
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
                child: Tooltip(
                  message: 'Tap to change profile picture',
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.transparent,
                    backgroundImage: avatarImage,
                  ),
                ),
              ),
            )
          ],
        ),
        drawer: HomeDrawer(image: _profilePic),
        body: Column(
          children: [
            // Unverified Email Alert Banner (Non-intrusive)
            if (user != null && !user.emailVerified)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.warningLight,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warningDark, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Email not verified. Verify in Settings for full security.',
                        style: TextStyle(
                          color: AppColors.warningDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.warningDark,
                      ),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(SettingsScreen.routeName),
                      child: const Text('Verify'),
                    ),
                  ],
                ),
              ),

            // Main Body with Responsive Layout
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        NavigationRail(
                          selectedIndex: _currentIndex,
                          onDestinationSelected: (value) {
                            setState(() => _currentIndex = value);
                          },
                          labelType: NavigationRailLabelType.all,
                          leading: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: AppLogo(size: 40, borderRadius: 10),
                          ),
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.grid_view_outlined, size: 22),
                              selectedIcon: Icon(Icons.grid_view_rounded,
                                  size: 23, color: AppColors.primary),
                              label: Text('Areas'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.group_outlined, size: 23),
                              selectedIcon: Icon(Icons.group_rounded,
                                  size: 24, color: AppColors.primary),
                              label: Text('Customers'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.person_add_alt_1_outlined,
                                  size: 23),
                              selectedIcon: Icon(Icons.person_add_alt_1_rounded,
                                  size: 24, color: AppColors.primary),
                              label: Text('Add'),
                            ),
                          ],
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: screens[_currentIndex]),
                      ],
                    )
                  : screens[_currentIndex],
            ),
          ],
        ),
        bottomNavigationBar: isWide
            ? null
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFB45309).withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -1),
                    ),
                  ],
                  border: const Border(
                    top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: NavigationBar(
                    height: 64,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    indicatorColor: AppColors.primaryContainer,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (value) {
                      setState(() => _currentIndex = value);
                    },
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.grid_view_outlined, size: 22),
                        selectedIcon: Icon(Icons.grid_view_rounded,
                            size: 23, color: AppColors.primary),
                        label: 'Areas',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.group_outlined, size: 23),
                        selectedIcon: Icon(Icons.group_rounded,
                            size: 24, color: AppColors.primary),
                        label: 'Customers',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_add_alt_1_outlined, size: 23),
                        selectedIcon: Icon(Icons.person_add_alt_1_rounded,
                            size: 24, color: AppColors.primary),
                        label: 'Add Customer',
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
