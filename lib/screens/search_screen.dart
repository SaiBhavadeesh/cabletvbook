import 'package:flutter/material.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/searchScreen';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ResponsiveContainer(
          maxWidth: 1000,
          child: Column(
            children: [
              // Modern Tab Bar Container
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'All Subscribers'),
                    Tab(text: 'Pending Bills'),
                    Tab(text: 'Advance Credits'),
                    Tab(text: 'Active Only'),
                    Tab(text: 'Inactive Only'),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Tab Views
              const Expanded(
                child: TabBarView(
                  children: <Widget>[
                    SearchScreenWidget(all: true),
                    SearchScreenWidget(pending: true),
                    SearchScreenWidget(credits: true),
                    SearchScreenWidget(active: true),
                    SearchScreenWidget(inactive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
