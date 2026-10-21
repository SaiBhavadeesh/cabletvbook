import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/services/database_services.dart';

class ActivateBottomSheet extends StatefulWidget {
  final String customerId;
  final String areaId;
  final int year;
  final String status;
  final double plan;
  final int unpaidNo;

  const ActivateBottomSheet({
    super.key,
    required this.customerId,
    required this.areaId,
    required this.status,
    required this.year,
    required this.plan,
    required this.unpaidNo,
  });

  @override
  _ActivateBottomSheetState createState() => _ActivateBottomSheetState();
}

class _ActivateBottomSheetState extends State<ActivateBottomSheet> {
  late double _selectedPlan;
  bool _checked = true;
  bool _selected = false;
  int _selectedTerm = 1;

  void _selectPlanField(double? value) {
    if (value != null) {
      setState(() {
        _selectedPlan = value;
      });
    }
  }

  void _selectTermField(int? value) {
    if (value != null) {
      setState(() {
        _selectedTerm = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.plan;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final opPlans = operatorDetails?.plans ?? [];
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Container(
            height: size.height * 0.75 -
                size.height * 0.04 * ((16 - opPlans.length) / 4).floor(),
            alignment: Alignment.bottomCenter,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Select Plan : ',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemBuilder: (context, index) => FittedBox(
                    fit: BoxFit.contain,
                    child: Row(
                      children: <Widget>[
                        Radio<double>(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: Theme.of(context).primaryColor,
                          value: opPlans[index],
                          groupValue: _selectedPlan,
                          onChanged: _selectPlanField,
                        ),
                        Text('\u20B9 ${opPlans[index]}'),
                      ],
                    ),
                  ),
                  itemCount: opPlans.length,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Select Period : ',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 20),
                    DropdownButton<int>(
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1} Month${index == 0 ? '' : 's'}'),
                        ),
                      ),
                      onChanged: _selectTermField,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      value: _selectedTerm,
                    ),
                  ],
                ),
                const Divider(),
                CheckboxListTile(
                  activeColor: Colors.green,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checked,
                  title: const Text('If bill paid'),
                  onChanged: (value) {
                    setState(() {
                      _checked = value ?? false;
                    });
                  },
                ),
                const Divider(),
                CheckboxListTile(
                  activeColor: Colors.green,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _selected,
                  title: const Text('Launch portal.'),
                  onChanged: (value) {
                    setState(() {
                      _selected = value ?? false;
                    });
                  },
                ),
                const Divider(),
                const SizedBox(height: 10),
                Align(
                  child: defaultbutton(
                    context: context,
                    function: () async {
                      final uri = Uri.parse("https://partnerportal.actcorp.in/packages");
                      if (await canLaunchUrl(uri) || !_selected) {
                        try {
                          if (_selected) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                          if (!context.mounted) return;
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              content: const Text('Activation successful ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(ctx).colorScheme.error,
                                  ),
                                  child: const Text('no'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await DatabaseService.rechargeCustomer(
                                      context,
                                      customerId: widget.customerId,
                                      areaId: widget.areaId,
                                      status: widget.status,
                                      plan: _selectedPlan,
                                      term: _selectedTerm,
                                      billPay: _checked,
                                      unPaidNo: widget.unpaidNo,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(ctx).primaryColor,
                                  ),
                                  child: const Text('yes'),
                                ),
                              ],
                            ),
                          );
                        } catch (_) {}
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Could not process your request, Please try again');
                      }
                    },
                    title: 'Recharge',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
