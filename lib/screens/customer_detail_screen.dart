import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/widgets/customer_plan_list.dart';
import 'package:cableTvBook/widgets/activate_bottom_sheet.dart';
import 'package:cableTvBook/widgets/customer_edit_bottom_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  static const routeName = '/customerDetailScreen';

  const CustomerDetailScreen({super.key});

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final moreInfoController = TextEditingController();
  late Size size;
  late int _selectedYear;
  bool _isEdit = false;
  bool _init = true;
  File? _pickedImage;
  late Customer customer;
  List<Recharge> rechargeData = [];

  @override
  void dispose() {
    moreInfoController.dispose();
    super.dispose();
  }

  List<int> getAllYears(DateTime date, int runningYear) {
    List<int> years = [];
    final startyear = date.year;
    for (int i = startyear; i <= runningYear; i++) {
      years.add(i);
    }
    return years.isEmpty ? [DateTime.now().year] : years;
  }

  void onMoreInfo() {
    if (_isEdit && customer.tempInfo != null) {
      DatabaseService.updateCustomerData(
        context,
        data: {'tempInfo': null},
        customerId: customer.id,
      );
      moreInfoController.clear();
      customer.tempInfo = null;
    }
    setState(() {
      _isEdit = !_isEdit;
    });
  }

  void modalBottomSheet(BuildContext ctx, Customer data) {
    Navigator.of(ctx).push(PageRouteBuilder(
      pageBuilder: (context, _, __) =>
          CustomerEditBottomSheet(customer: data),
      opaque: false,
    ));
  }

  void copyTextOnLongTap(
    BuildContext ctx,
    String copy,
    String text,
  ) {
    Clipboard.setData(ClipboardData(text: copy));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(milliseconds: 300),
        content: Text('$text copied to Clipboard'),
      ),
    );
  }

  Widget richText(String title, String value) {
    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget copyValueWidget(
      BuildContext context, String title, String value, String display) {
    return GestureDetector(
      onTap: () => copyTextOnLongTap(context, value, display),
      child: Card(
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: RichText(
            text: TextSpan(
              text: title,
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget floatingButton(
      Object tag, VoidCallback function, String title, Color color) {
    return FloatingActionButton.extended(
      heroTag: tag,
      onPressed: function,
      label: SizedBox(
        width: size.width * 0.25,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.height * 0.025,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      backgroundColor: color,
    );
  }

  void activateButton(BuildContext ctx) {
    Navigator.of(ctx).push(PageRouteBuilder(
      pageBuilder: (context, _, __) => ActivateBottomSheet(
        customerId: customer.id,
        areaId: customer.areaId,
        status: customer.currentStatus,
        year: customer.runningYear,
        plan: customer.currentPlan,
        unpaidNo: customer.noOfPendingBills,
      ),
      opaque: false,
    ));
  }

  void deactivateButton() async {
    if (customer.currentStatus != 'Active') {
      DefaultDialogBox.errorDialog(
        context,
        title: 'Alert !',
        content: 'Customer has no active plan to deactivate !',
      );
    } else {
      final uri = Uri.parse("https://partnerportal.actcorp.in/packages");
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      } else {
        Fluttertoast.showToast(
            msg: 'Could not process your request, Please try again');
      }
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text('De-activation successful ?'),
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
                await DatabaseService.deactivateCustomer(
                  context,
                  customerId: customer.id,
                  areaId: customer.areaId,
                  year: customer.runningYear.toString(),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).primaryColor,
              ),
              child: const Text('yes'),
            ),
          ],
        ),
      );
    }
  }

  void deleteRecharge(
      BuildContext ctx, Recharge recharge, bool prevRecharge) async {
    final bool valid = rechargeData
        .any((element) => element.ymRec.month > recharge.ymRec.month);
    final recDate = recharge.date;
    if (recharge.status &&
        customer.runningYear == _selectedYear &&
        !valid &&
        recDate != null &&
        DateTime.now().difference(recDate) < const Duration(days: 10)) {
      await showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Delete recharge'),
          content: const Text('Are you sure ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogCtx).colorScheme.error,
              ),
              child: const Text('no'),
            ),
            TextButton(
              onPressed: () async {
                String year = _selectedYear.toString();
                if (_selectedYear != customer.startDate.year) {
                  _selectedYear -= 1;
                }
                Navigator.pop(dialogCtx);
                final value = await DatabaseService.deleteRecharge(
                  context,
                  customerId: customer.id,
                  areaId: customer.areaId,
                  recharge: recharge,
                  unPaidNo: customer.noOfPendingBills,
                );
                if (mounted) {
                  setState(() {
                    if (!value &&
                        int.parse(year) != customer.startDate.year) {
                      _selectedYear = _selectedYear + 1;
                    }
                  });
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogCtx).primaryColor,
              ),
              child: const Text('yes'),
            ),
          ],
        ),
      );
    } else if (customer.runningYear == _selectedYear || !valid) {
      Fluttertoast.showToast(msg: 'Delete recent recharge first');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_init) {
      customer = ModalRoute.of(context)!.settings.arguments as Customer;
      _isEdit = customer.tempInfo != null;
      _selectedYear = customer.runningYear;
      _init = false;
    }
    size = MediaQuery.of(context).size;
    final op = operatorDetails;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/${op?.id}/customers')
          .doc(customer.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.data() != null) {
          customer = Customer.fromMap(
              snapshot.data!.data() as Map<String, dynamic>);
          final years = getAllYears(customer.startDate, customer.runningYear);
          moreInfoController.text = customer.tempInfo ?? '';
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red[500],
              title: Text(op?.networkName ?? ''),
              bottom: PreferredSize(
                preferredSize: Size(size.width, 10),
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        op?.name ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        op?.phoneNumber ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                DropdownButton<int>(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  underline: const SizedBox.shrink(),
                  value: _selectedYear,
                  items: years.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && _selectedYear != value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: size.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.01,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: size.width * 0.75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: richText('Name : ', customer.name),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: richText(
                                      'Start Date : ',
                                      DateFormat('MMMM d, y / EEEE')
                                          .format(customer.startDate),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: richText(
                                        'Address : ', customer.address),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: richText(
                                        'Phone : ', customer.phoneNumber),
                                  ),
                                  copyValueWidget(
                                    context,
                                    'Account no : ',
                                    customer.accountNumber,
                                    'Account number',
                                  ),
                                  copyValueWidget(
                                    context,
                                    'MAC Id : ',
                                    customer.macId,
                                    'MAC-ID',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    final picked =
                                        await ImageGetter.getImageFromDevice(
                                            context);
                                    if (picked != null) {
                                      _pickedImage = picked;
                                      await DatabaseService
                                          .updateCustomerPicture(context,
                                              file: _pickedImage!,
                                              customerId: customer.id);
                                      if (mounted) setState(() {});
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: size.width * 0.1,
                                    backgroundImage:
                                        customer.profileImageUrl == null
                                            ? (_pickedImage != null
                                                ? FileImage(_pickedImage!)
                                                : const AssetImage(
                                                        'assets/images/default_profile.jpg')
                                                    as ImageProvider)
                                            : NetworkImage(
                                                customer.profileImageUrl!),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.call,
                                    size: size.height * 0.05,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () async {
                                    final uri = Uri.parse(
                                        "tel:${customer.phoneNumber}");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Could not process your request, Please try again');
                                    }
                                  },
                                ),
                                AnimatedCrossFade(
                                  duration: const Duration(seconds: 1),
                                  crossFadeState: _isEdit
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: IconButton(
                                    onPressed: onMoreInfo,
                                    icon: const Icon(Icons.note_add),
                                  ),
                                  secondChild: IconButton(
                                    onPressed: onMoreInfo,
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: size.width,
                          height: _isEdit ? size.width * 0.10 : 0,
                          padding: const EdgeInsets.only(
                              top: 4.0, left: 4.0, right: 4.0),
                          child: TextFormField(
                            controller: moreInfoController,
                            enabled: customer.tempInfo == null && _isEdit,
                            onEditingComplete: () {
                              if (moreInfoController.text.isNotEmpty) {
                                DatabaseService.updateCustomerData(
                                  context,
                                  data: {
                                    'tempInfo': moreInfoController.text
                                  },
                                  customerId: customer.id,
                                );
                              }
                              customer.tempInfo = moreInfoController.text;
                            },
                            decoration: InputDecoration(
                              disabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow),
                              ),
                              labelText: _isEdit ? 'Temporary Info' : null,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0,
                    endIndent: 0,
                    indent: 0,
                    thickness: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CustomerPlanList(),
                  ),
                  Divider(
                    endIndent: 0,
                    indent: 0,
                    thickness: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(
                            'users/${op?.id}/customers/${customer.id}/recharges')
                        .snapshots(),
                    builder: (context, rSnapshot) {
                      if (rSnapshot.hasData && rSnapshot.data != null) {
                        rechargeData = getCustomerYearlyRecharge(
                            rSnapshot.data!.docs, _selectedYear);
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final rec = rechargeData.firstWhere(
                              (element) => element.ymRec.month == index + 1,
                              orElse: () => Recharge(
                                ymRec: DateTime(_selectedYear, index + 1),
                                status: false,
                                addInfo: null,
                                billPay: null,
                                date: null,
                                id: '${index + 1}',
                                plan: null,
                              ),
                            );
                            return GestureDetector(
                              onLongPress: () => deleteRecharge(
                                context,
                                rec,
                                _selectedYear != customer.startDate.year ||
                                    index > 0,
                              ),
                              child: CustomerPlanList(
                                customerId: customer.id,
                                areaId: customer.areaId,
                                id: rec.id,
                                billPay: rec.billPay,
                                year: _selectedYear.toString(),
                                month: DateFormat('MMMM').format(
                                  DateTime(_selectedYear, rec.ymRec.month),
                                ),
                                billDate: rec.billPay == null
                                    ? ''
                                    : DateFormat('dd/MM/yyyy').format(
                                        rec.date ?? DateTime.now()),
                                billAmount: rec.plan ?? '',
                                status: rec.status ? 'Active' : 'Inactive',
                                addInfo: rec.addInfo,
                                unpaidBill: customer.noOfPendingBills,
                              ),
                            );
                          },
                          itemCount: 12,
                        );
                      }
                      return Container(
                        alignment: Alignment.center,
                        height: 250,
                        child: FadingText('Please wait ...'),
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.125),
                ],
              ),
            ),
            floatingActionButton: Row(
              children: <Widget>[
                const SizedBox(width: 10),
                floatingButton(
                  0,
                  () => activateButton(context),
                  'Activate',
                  Colors.green,
                ),
                const Expanded(child: SizedBox()),
                FloatingActionButton(
                  onPressed: () => modalBottomSheet(context, customer),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.edit),
                ),
                const Expanded(child: SizedBox()),
                floatingButton(
                  1,
                  deactivateButton,
                  'Deactivate',
                  Colors.red,
                ),
                const SizedBox(width: 10),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red[500],
              title: Text(op?.networkName ?? ''),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
