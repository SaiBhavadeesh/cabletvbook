import 'package:flutter/material.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/widgets/search_screen_widget.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class AreaCustomersScreen extends StatelessWidget {
  static const routeName = '/areaCustomer';

  const AreaCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AreaData? area =
        ModalRoute.of(context)?.settings.arguments as AreaData?;

    if (area == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Area Subscribers')),
        body: const Center(child: Text('Area information missing')),
      );
    }

    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                area.areaName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${area.totalAccounts} total • ${area.activeAccounts} active',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
          ),
        ),
        body: ResponsiveContainer(
          maxWidth: 1000,
          child: TabBarView(
            children: [
              SearchScreenWidget(all: true, areaId: area.id),
              SearchScreenWidget(pending: true, areaId: area.id),
              SearchScreenWidget(credits: true, areaId: area.id),
              SearchScreenWidget(active: true, areaId: area.id),
              SearchScreenWidget(inactive: true, areaId: area.id),
            ],
          ),
        ),
      ),
    );
  }
}
