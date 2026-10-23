import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cableTvBook/widgets/app_svg_icon.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/collection_screen.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
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
        return 'Collections & Revenue';
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
      CollectionScreen(isEmbedded: true),
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
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 32, borderRadius: 8, hasShadow: false),
              const SizedBox(width: 10),
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
            Builder(
              builder: (ctx) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Tooltip(
                    message: 'Open Menu',
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.transparent,
                      backgroundImage: avatarImage,
                    ),
                  ),
                ),
              ),
            ),
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
                              icon: AppSvgIcon(
                                AppSvgIconType.areas,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                              selectedIcon: AppSvgIcon(
                                AppSvgIconType.areas,
                                color: AppColors.primary,
                                size: 23,
                              ),
                              label: Text('Areas'),
                            ),
                            NavigationRailDestination(
                              icon: AppSvgIcon(
                                AppSvgIconType.customers,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                              selectedIcon: AppSvgIcon(
                                AppSvgIconType.customers,
                                color: AppColors.primary,
                                size: 23,
                              ),
                              label: Text('Customers'),
                            ),
                            NavigationRailDestination(
                              icon: AppSvgIcon(
                                AppSvgIconType.collections,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                              selectedIcon: AppSvgIcon(
                                AppSvgIconType.collections,
                                color: AppColors.primary,
                                size: 23,
                              ),
                              label: Text('Collections'),
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
        extendBody: true,
        bottomNavigationBar: isWide
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFB45309).withValues(alpha: 0.14),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color:
                              const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _AnimatedNavTab(
                          index: 0,
                          selectedIndex: _currentIndex,
                          label: 'Areas',
                          icon: AppSvgIconType.areas,
                          onTap: (val) => setState(() => _currentIndex = val),
                        ),
                        _AnimatedNavTab(
                          index: 1,
                          selectedIndex: _currentIndex,
                          label: 'Customers',
                          icon: AppSvgIconType.customers,
                          onTap: (val) => setState(() => _currentIndex = val),
                        ),
                        _AnimatedNavTab(
                          index: 2,
                          selectedIndex: _currentIndex,
                          label: 'Collections',
                          icon: AppSvgIconType.collections,
                          onTap: (val) => setState(() => _currentIndex = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _AnimatedNavTab extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final AppSvgIconType icon;
  final ValueChanged<int> onTap;

  const _AnimatedNavTab({
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFEF3C7) // warm amber accent container
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                child: AppSvgIcon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                  letterSpacing: isSelected ? 0.1 : 0,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
