import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<dynamic> showEditOrAddDialog({int index = -1, bool delete = false}) {
    return showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        if (index >= 0 && index < areas.length) {
          textController.text = areas[index].areaName;
        }
        return Form(
          key: _formKey,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                delete
                    ? 'Delete Area'
                    : index < 0
                        ? 'Add New Area'
                        : 'Edit Area Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: delete
                  ? Text(
                      'Are you sure you want to delete "${areas[index].areaName}"? Customers in this area will need to be reassigned.',
                      style: const TextStyle(fontSize: 14),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (index < 0)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Organize your subscriber network by neighborhood or territory (max 16 areas).',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        TextFormField(
                          maxLength: 15,
                          controller: textController,
                          validator: nameValidator,
                          autofocus: true,
                          decoration: inputDecoration(
                            icon: index < 0
                                ? Icons.add_location_alt_outlined
                                : Icons.edit_location_alt_outlined,
                            hint: 'Area name (e.g. Sector 4, Downtown)',
                          ),
                        ),
                      ],
                    ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: delete ? AppColors.error : AppColors.primary,
                  ),
                  onPressed: delete
                      ? () async {
                          Navigator.pop(ctx);
                          await DatabaseService.deleteArea(
                              context, areas[index].id);
                        }
                      : () async {
                          if (_formKey.currentState?.validate() == true) {
                            _formKey.currentState?.save();
                            final newName = textController.text.trim();
                            if (index < 0) {
                              bool isExist = areas.any((element) =>
                                  element.areaName.toLowerCase() ==
                                  newName.toLowerCase());
                              if (isExist) {
                                await DefaultDialogBox.errorDialog(
                                  ctx,
                                  title: 'Area Exists',
                                  content: 'An area with this name already exists.',
                                );
                                return;
                              } else {
                                await DatabaseService.addArea(
                                  context,
                                  data: AreaData(areaName: newName).toJson(),
                                );
                              }
                            } else {
                              await DatabaseService.updateArea(
                                context,
                                data: areas[index].toJson()..['an'] = newName,
                              );
                            }
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          }
                        },
                  child: Text(delete ? 'Delete' : 'Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOperatorHeader(Operator op, List<AreaData> currentAreas) {
    int totalAccounts = 0;
    int totalActive = 0;
    int totalInactive = 0;

    for (final a in currentAreas) {
      totalAccounts += a.totalAccounts;
      totalActive += a.activeAccounts;
      totalInactive += a.inActiveAccounts;
    }

    final activePercent = totalAccounts > 0
        ? ((totalActive / totalAccounts) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      op.networkName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${op.name} • ${op.phoneNumber}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${currentAreas.length} Areas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _buildStatChip(
                label: 'Total Accounts',
                value: '$totalAccounts',
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                label: 'Active',
                value: '$totalActive',
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                label: 'Inactive',
                value: '$totalInactive',
                color: AppColors.errorLight,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$activePercent% Active',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalAccounts > 0 ? (totalActive / totalAccounts) : 0,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.success),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAreaCard(BuildContext context, AreaData area, int index) {
    final hasAccounts = area.totalAccounts > 0;
    final activeRate =
        hasAccounts ? (area.activeAccounts / area.totalAccounts) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          // Corner-elevated shadow with warm bronze hue (casts toward bottom-right)
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(4, 7),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).pushNamed(
              AreaCustomersScreen.routeName,
              arguments: area,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Top Row: Distinct Icon Badge on left + 3-dots action & active rate on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFB45309).withValues(alpha: 0.15),
                            blurRadius: 5,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                    Row(
                      children: [
                        if (hasAccounts)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: activeRate >= 0.7
                                  ? AppColors.successLight
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${(activeRate * 100).round()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: activeRate >= 0.7
                                    ? AppColors.successDark
                                    : AppColors.warningDark,
                              ),
                            ),
                          ),
                        const SizedBox(width: 2),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: AppColors.textMuted, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (val) {
                            if (val == 'view') {
                              Navigator.of(context).pushNamed(
                                AreaCustomersScreen.routeName,
                                arguments: area,
                              );
                            } else if (val == 'edit') {
                              showEditOrAddDialog(index: index);
                            } else if (val == 'delete') {
                              showEditOrAddDialog(delete: true, index: index);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.people_outline_rounded,
                                      size: 18, color: AppColors.primary),
                                  SizedBox(width: 10),
                                  Text('View Customers'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      size: 18, color: AppColors.textSecondary),
                                  SizedBox(width: 10),
                                  Text('Edit Name'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded,
                                      size: 18, color: AppColors.error),
                                  SizedBox(width: 10),
                                  Text('Delete Area',
                                      style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Area Name & Subscriber count (full width breathing room)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.areaName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${area.totalAccounts} Subscribers',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: activeRate,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      area.activeAccounts > 0
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    minHeight: 4.5,
                  ),
                ),

                const SizedBox(height: 6),

                // Badges Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${area.activeAccounts}',
                            style: const TextStyle(
                              color: AppColors.successDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${area.inActiveAccounts} off',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (op == null) {
      return const Center(child: Text('Operator information not loaded'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users/${op.id}/areas')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              areas = snapshot.data!.docs
                  .map((e) =>
                      AreaData.fromMap(e.data() as Map<String, dynamic>))
                  .toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Dashboard Stats Header
                  SliverToBoxAdapter(
                    child: _buildOperatorHeader(op, areas),
                  ),

                  // Section Title Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Coverage Areas',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (areas.length < 16)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () => showEditOrAddDialog(),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Area'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Areas Grid or Empty State
                  if (areas.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_location_alt_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No Areas Added Yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create areas (like sectors or neighborhoods) to start organizing and managing your subscribers.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: () => showEditOrAddDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Area'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Responsive.gridColumns(
                            context,
                            mobile: 2,
                            tablet: 3,
                            desktop: 4,
                          ),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: Responsive.isMobile(context) ? 0.90 : 1.05,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildAreaCard(context, areas[index], index),
                          childCount: areas.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            }

            return Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: const [AppColors.primary],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: areas.length < 16
          ? FloatingActionButton.extended(
              onPressed: () => showEditOrAddDialog(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Add Area'),
            )
          : null,
    );
  }
}
