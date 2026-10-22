import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/box_decoration.dart';

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

  Widget _buildTitleText(BuildContext context, String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: defaultBoxDecoration(context, true),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildValueRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildMetricsCard({
    required double subtotal,
    required double paid,
    double? total,
    int? inactive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (total != null)
          _buildValueRow('Total amount : \t', '\u20B9 $total', Colors.deepOrange),
        _buildValueRow('Total bill amount : \t', '\u20B9 $subtotal', Colors.blue),
        _buildValueRow('Amount collected : \t', '\u20B9 $paid', Colors.green),
        _buildValueRow(
          'Bill amount pending : \t',
          '\u20B9 ${subtotal - paid}',
          Colors.red,
        ),
        if (inactive != null)
          _buildValueRow('Inactive customers : \t', '$inactive', Colors.deepPurple),
      ],
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
              'year': currentYear,
              'month': m,
              'totalBilled': 0.0,
              'billedCount': 0,
              'totalPaid': 0.0,
              'paidCount': 0,
            });

            if (recharge.billPay != null) {
              yearlySubtotal += planAmount;
              agg['totalBilled'] = (agg['totalBilled'] as double) + planAmount;
              agg['billedCount'] = (agg['billedCount'] as int) + 1;
              if (recharge.billPay == true) {
                yearlyPaid += planAmount;
                agg['totalPaid'] = (agg['totalPaid'] as double) + planAmount;
                agg['paidCount'] = (agg['paidCount'] as int) + 1;
              }
            }

            if (recharge.ymRec.month == currentMonth && recharge.billPay != null) {
              monthlySubtotal += planAmount;
              if (recharge.billPay == true) {
                monthlyPaid += planAmount;
              }
            }
          }
        }
      }
    }

    // Persist monthly aggregates to Firestore
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final entry in monthlyAggs.entries) {
        entry.value['totalExpected'] = monthlyTotal;
        entry.value['updatedAt'] = FieldValue.serverTimestamp();
        final repRef = FirebaseFirestore.instance
            .collection('users/$opId/reports')
            .doc('${currentYear}_${entry.key}');
        batch.set(repRef, entry.value, SetOptions(merge: true));
      }
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
    Fluttertoast.showToast(msg: 'Syncing collections report...');
    try {
      await _backfillAndCalculate(opId);
      Fluttertoast.showToast(msg: 'Collections report up to date!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Sync failed: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (op == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection Information')),
        body: const Center(child: Text('Operator information missing')),
      );
    }

    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Information'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sync Collections',
            onPressed: _isSyncing ? null : () => _handleManualSync(op.id),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users/${op.id}/reports')
            .where('year', isEqualTo: currentYear)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: FadingText('Loading collections...'));
          }

          final reportDocs = snapshot.data!.docs;

          // If no pre-aggregated reports exist yet, run one-time backfill
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

          // Instant rendering from aggregated report documents
          final metrics = _metricsFromReports(reportDocs);
          return _buildMetricsView(metrics);
        },
      ),
    );
  }

  Widget _buildMetricsView(CollectionMetrics metrics) {
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTitleText(
          context,
          'This Month (${DateFormat('MMMM yyyy').format(now)})',
        ),
        _buildMetricsCard(
          subtotal: metrics.monthlySubtotal,
          paid: metrics.monthlyPaid,
          total: metrics.monthlyTotal > 0 ? metrics.monthlyTotal : null,
          inactive: metrics.inactiveCustomers,
        ),
        const SizedBox(height: 24),
        _buildTitleText(
          context,
          'Year-to-Date Collections (${now.year})',
        ),
        _buildMetricsCard(
          subtotal: metrics.yearlySubtotal,
          paid: metrics.yearlyPaid,
        ),
      ],
    );
  }
}
