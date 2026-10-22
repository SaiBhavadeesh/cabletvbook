import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/profile_screen.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:cableTvBook/screens/collection_screen.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/widgets/app_logo.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';

class HomeDrawer extends StatelessWidget {
  final File? image;

  const HomeDrawer({super.key, this.image});

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    ImageProvider avatarImage;
    if (image != null) {
      avatarImage = FileImage(image!);
    } else {
      avatarImage = getAvatarImageProvider(op?.profileImageLink);
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // Drawer Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 20,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 46, borderRadius: 12),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cable TV Book',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              op?.networkName ?? 'Cable Operator Suite',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: avatarImage,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                op?.name ?? 'Operator',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                op?.phoneNumber ?? '',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader('Management'),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    onTap: () =>
                        Navigator.of(context).pushNamed(ProfileScreen.routeName),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.analytics_outlined,
                    title: 'Collections & Revenue',
                    onTap: () => Navigator.of(context)
                        .pushNamed(CollectionScreen.routeName),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.tune_rounded,
                    title: 'Settings',
                    onTap: () => Navigator.of(context)
                        .pushNamed(SettingsScreen.routeName),
                  ),

                  const Divider(height: 24, indent: 20, endIndent: 20),

                  _buildSectionHeader('Support & Legal'),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () async {
                      final emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'srinivasasoftwares@gmail.com',
                      );
                      if (await canLaunchUrl(emailLaunchUri)) {
                        try {
                          await launchUrl(emailLaunchUri);
                        } catch (_) {}
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Could not process request, please try again',
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    onTap: () async {
                      final uri = Uri.parse(
                        "https://sites.google.com/view/srinivasasoftwares-privacy",
                      );
                      if (await canLaunchUrl(uri)) {
                        try {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () async {
                      final uri = Uri.parse(
                        "https://sites.google.com/view/srinivasasoftwares-terms",
                      );
                      if (await canLaunchUrl(uri)) {
                        try {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      }
                    },
                  ),

                  const Divider(height: 24, indent: 20, endIndent: 20),

                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () async =>
                        await Authentication.signout(context),
                  ),
                ],
              ),
            ),

            // Footer Version
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Cable TV Book • v1.0.0',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
