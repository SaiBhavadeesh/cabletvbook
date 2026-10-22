import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class CollectionMetrics {
  final double monthlyTotal;
  final double monthlySubtotal;
  final double monthlyPaid;
  final int inactiveCustomers;
  final double yearlySubtotal;
  final double yearlyPaid;

  const CollectionMetrics({
    required this.monthlyTotal,
    required this.monthlySubtotal,
    required this.monthlyPaid,
    required this.inactiveCustomers,
    required this.yearlySubtotal,
    required this.yearlyPaid,
  });

  factory CollectionMetrics.empty() {
    return const CollectionMetrics(
      monthlyTotal: 0.0,
      monthlySubtotal: 0.0,
      monthlyPaid: 0.0,
      inactiveCustomers: 0,
      yearlySubtotal: 0.0,
      yearlyPaid: 0.0,
    );
  }
}

class CollectionScreen extends StatefulWidget {
  static const routeName = '/collectionScreen';

  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  bool _isSyncing = false;

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (subtitle != null)
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard(double billed, double collected) {
    final rate = billed > 0 ? (collected / billed) : 0.0;
    final percent = (rate * 100).clamp(0, 100).round();

    return Container(
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
              const Text(
                'Collection Efficiency',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$percent% Collected',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collected: \u20B9 ${collected.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              Text(
                'Pending: \u20B9 ${(billed - collected).clamp(0, double.infinity).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.warningLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  CollectionMetrics _metricsFromReports(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final now = DateTime.now();
    final currentMonth = now.month;

    double monthlyTotal = 0;
    double monthlySubtotal = 0;
    double monthlyPaid = 0;
    double yearlySubtotal = 0;
    double yearlyPaid = 0;

    for (final doc in docs) {
      final data = doc.data();
      final billed = (data['totalBilled'] as num?)?.toDouble() ?? 0.0;
      final paid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;
      final exp = (data['totalExpected'] as num?)?.toDouble() ?? 0.0;

      yearlySubtotal += billed;
      yearlyPaid += paid;
      if (exp > monthlyTotal) monthlyTotal = exp;

      if (data['month'] == currentMonth) {
        monthlySubtotal = billed;
        monthlyPaid = paid;
      }
    }

    final inactive = areas.fold<int>(
      0,
      (previousValue, element) => previousValue + element.inActiveAccounts,
    );

    return CollectionMetrics(
      monthlyTotal: monthlyTotal,
      monthlySubtotal: monthlySubtotal,
      monthlyPaid: monthlyPaid,
      inactiveCustomers: inactive,
      yearlySubtotal: yearlySubtotal,
      yearlyPaid: yearlyPaid,
    );
  }

  Future<CollectionMetrics> _backfillAndCalculate(String opId) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    final custSnap = await FirebaseFirestore.instance
        .collection('users/$opId/customers')
        .get();

    double monthlyTotal = 0;
    double monthlySubtotal = 0;
    double monthlyPaid = 0;
    double yearlySubtotal = 0;
    double yearlyPaid = 0;

    final Map<int, Map<String, dynamic>> monthlyAggs = {};

    const int chunkSize = 15;
    for (int i = 0; i < custSnap.docs.length; i += chunkSize) {
      final chunk = custSnap.docs.skip(i).take(chunkSize).toList();
      final futures = chunk.map((c) async {
        try {
          return await c.reference.collection('recharges').get();
        } catch (_) {
          return null;
        }
      });
      final results = await Future.wait(futures);

      for (int j = 0; j < chunk.length; j++) {
        final custDoc = chunk[j];
        final plan = (custDoc.data()['curPlan'] as num?)?.toDouble() ?? 0.0;
        monthlyTotal += plan;

        final querySnapshot = results[j];
        if (querySnapshot == null || querySnapshot.docs.isEmpty) continue;

        for (final doc in querySnapshot.docs) {
          final recharge = Recharge.fromMap(doc.data());
          if (recharge.ymRec.year == currentYear) {
            final planAmount = double.tryParse(recharge.plan ?? '0') ?? 0.0;
            final m = recharge.ymRec.month;
            final agg = monthlyAggs.putIfAbsent(m, () => {
                  'totalBilled': 0.0,
                  'totalPaid': 0.0,
                  'activeRecharges': 0,
                });

            agg['totalBilled'] =
                (agg['totalBilled'] as double) + planAmount;
            yearlySubtotal += planAmount;

            if (recharge.billPay == true) {
              agg['totalPaid'] =
                  (agg['totalPaid'] as double) + planAmount;
              yearlyPaid += planAmount;
            }
            if (recharge.status) {
              agg['activeRecharges'] =
                  (agg['activeRecharges'] as int) + 1;
            }

            if (m == currentMonth) {
              monthlySubtotal = agg['totalBilled'] as double;
              monthlyPaid = agg['totalPaid'] as double;
            }
          }
        }
      }
    }

    final batch = FirebaseFirestore.instance.batch();
    for (int m = 1; m <= 12; m++) {
      final agg = monthlyAggs[m];
      final docRef = FirebaseFirestore.instance
          .collection('users/$opId/reports')
          .doc('${currentYear}_$m');

      final billed = (agg?['totalBilled'] as double?) ?? 0.0;
      final paid = (agg?['totalPaid'] as double?) ?? 0.0;
      final actives = (agg?['activeRecharges'] as int?) ?? 0;

      batch.set(docRef, {
        'year': currentYear,
        'month': m,
        'totalBilled': billed,
        'totalPaid': paid,
        'totalExpected': monthlyTotal,
        'activeCount': actives,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    try {
      await batch.commit();
    } catch (_) {}

    final inactive = areas.fold<int>(
      0,
      (previousValue, element) => previousValue + element.inActiveAccounts,
    );

    return CollectionMetrics(
      monthlyTotal: monthlyTotal,
      monthlySubtotal: monthlySubtotal,
      monthlyPaid: monthlyPaid,
      inactiveCustomers: inactive,
      yearlySubtotal: yearlySubtotal,
      yearlyPaid: yearlyPaid,
    );
  }

  Future<void> _handleManualSync(String opId) async {
    setState(() => _isSyncing = true);
    try {
      await _backfillAndCalculate(opId);
      Fluttertoast.showToast(msg: 'Collections synchronized successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Sync error: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (op == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collections & Revenue')),
        body: const Center(child: Text('Operator information missing')),
      );
    }

    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Collections & Revenue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.sync_rounded),
            tooltip: 'Sync Collections',
            onPressed: _isSyncing ? null : () => _handleManualSync(op.id),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users/${op.id}/reports')
              .where('year', isEqualTo: currentYear)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: FadingText('Loading collections...'));
            }

            final reportDocs = snapshot.data!.docs;

            if (reportDocs.isEmpty) {
              return FutureBuilder<CollectionMetrics>(
                future: _backfillAndCalculate(op.id),
                builder: (context, metricSnapshot) {
                  if (!metricSnapshot.hasData) {
                    return Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: 250,
                        child: FadingText('Calculating collections...'),
                      ),
                    );
                  }
                  return _buildMetricsView(metricSnapshot.data!);
                },
              );
            }

            final metrics = _metricsFromReports(reportDocs);
            return _buildMetricsView(metrics);
          },
        ),
      ),
    );
  }

  Widget _buildMetricsView(CollectionMetrics metrics) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final isWide = Responsive.isWide(context);
    final pendingMonth = (metrics.monthlySubtotal - metrics.monthlyPaid)
        .clamp(0, double.infinity)
        .toDouble();
    final pendingYear = (metrics.yearlySubtotal - metrics.yearlyPaid)
        .clamp(0, double.infinity)
        .toDouble();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Monthly Section Header
        _buildSectionHeader('Current Month Overview', monthName),

        // Efficiency Card
        _buildEfficiencyCard(metrics.monthlySubtotal, metrics.monthlyPaid),
        const SizedBox(height: 16),

        // 2x2 or 4x1 KPI Grid for Monthly
        GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 1.4 : 1.05,
          children: [
            _buildKpiCard(
              title: 'Total Billed',
              value: '\u20B9 ${metrics.monthlySubtotal.toStringAsFixed(0)}',
              icon: Icons.receipt_long_rounded,
              color: AppColors.primary,
              bgColor: AppColors.primaryContainer,
              subtitle: 'Active Plans',
            ),
            _buildKpiCard(
              title: 'Collected',
              value: '\u20B9 ${metrics.monthlyPaid.toStringAsFixed(0)}',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              bgColor: AppColors.successLight,
              subtitle: 'Paid',
            ),
            _buildKpiCard(
              title: 'Pending Due',
              value: '\u20B9 ${pendingMonth.toStringAsFixed(0)}',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warningDark,
              bgColor: AppColors.warningLight,
              subtitle: 'To Collect',
            ),
            _buildKpiCard(
              title: 'Inactive Accounts',
              value: '${metrics.inactiveCustomers}',
              icon: Icons.person_off_outlined,
              color: AppColors.error,
              bgColor: AppColors.errorLight,
              subtitle: 'Subscribers',
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Yearly Section
        _buildSectionHeader(
          'Year-to-Date Collections',
          'Cumulative totals for year ${now.year}',
        ),

        GridView.count(
          crossAxisCount: isWide ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 1.4 : 1.05,
          children: [
            _buildKpiCard(
              title: 'Total Billed (${now.year})',
              value: '\u20B9 ${metrics.yearlySubtotal.toStringAsFixed(0)}',
              icon: Icons.calendar_today_rounded,
              color: AppColors.primary,
              bgColor: AppColors.primaryContainer,
            ),
            _buildKpiCard(
              title: 'Total Collected',
              value: '\u20B9 ${metrics.yearlyPaid.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.success,
              bgColor: AppColors.successLight,
            ),
            _buildKpiCard(
              title: 'Total Outstanding',
              value: '\u20B9 ${pendingYear.toStringAsFixed(0)}',
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              bgColor: AppColors.errorLight,
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
