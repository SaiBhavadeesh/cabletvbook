import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cableTvBook/helpers/image_getter.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class DatabaseService {
  static Future<void> getuserData() async {
    final user = firebaseUser;
    if (user == null) return;
    final firestoreInstance =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      DocumentSnapshot document = await firestoreInstance.get();
      if (document.exists && document.data() != null) {
        operatorDetails =
            Operator.fromMap(document.data() as Map<String, dynamic>);
      }
      // Also refresh areas
      final areaSnap =
          await firestoreInstance.collection('areas').get();
      areas = areaSnap.docs
          .map((d) => AreaData.fromMap(d.data()))
          .toList();
    } on PlatformException catch (error) {
      Fluttertoast.showToast(msg: error.message ?? 'Error getting user data');
    } catch (_) {
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> addNewCustomer(
    BuildContext context, {
    required Customer customer,
    File? file,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      String? url;
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');

      final firestoreInstance = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc();

      if (file != null) {
        url = await ImageGetter.convertFileToBase64(file);
      }

      final isCustomerActive = customer.currentStatus == 'Active';
      final areaRef = FirebaseFirestore.instance
          .collection('users/${op.id}/areas')
          .doc(customer.areaId);

      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        firestoreInstance,
        customer.toJson()
          ..['id'] = firestoreInstance.id
          ..['piUrl'] = url,
      );

      batch.update(areaRef, {
        'ta': FieldValue.increment(1),
        if (isCustomerActive) 'aa': FieldValue.increment(1) else 'iaa': FieldValue.increment(1),
      });

      await batch.commit();
      await getuserData();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            BottomTabsScreen.routeName, (route) => false);
        Fluttertoast.showToast(msg: 'Customer successfully added!');
      }
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Error adding customer');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> updateCustomerData(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String customerId,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId)
          .update(data);
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully updated!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> updateCustomerPicture(
    BuildContext context, {
    required File file,
    required String customerId,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final base64Image = await ImageGetter.convertFileToBase64(file);
      await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId)
          .update({'piUrl': base64Image});
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Profile picture updated!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update picture failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: picture upload failed!');
    }
  }

  static Future<void> uploadProfilePicture(
    BuildContext context, {
    required File file,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final base64Image = await ImageGetter.convertFileToBase64(file);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(op.id)
          .update({'pil': base64Image});
      await getuserData();
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Profile picture updated!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Picture upload failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: picture upload failed!');
    }
  }

  static Future<void> updateData(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(op.id)
          .update(data);
      await getuserData();
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully updated!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> addArea(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = firebaseUser;
      if (user == null) throw Exception('User not logged in');
      final firestoreInstance = FirebaseFirestore.instance
          .collection('users/${user.uid}/areas')
          .doc();
      await firestoreInstance.set(data..['id'] = firestoreInstance.id);
      await getuserData();
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'New area created successfully!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Add area failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> deleteArea(BuildContext context, String areaId) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');

      final areaRef = FirebaseFirestore.instance
          .collection('users/${op.id}/areas')
          .doc(areaId);

      final customerQuery = await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .where('areaId', isEqualTo: areaId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      batch.delete(areaRef);
      for (final doc in customerQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await getuserData();

      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Area successfully deleted!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Delete area failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> updateArea(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = firebaseUser;
      if (user == null) throw Exception('User not logged in');
      await FirebaseFirestore.instance
          .collection('users/${user.uid}/areas')
          .doc(data['id'])
          .update(data);
      await getuserData();
      if (context.mounted) Navigator.pop(context);
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update area failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> rechargeCustomer(
    BuildContext context, {
    required String customerId,
    required String areaId,
    required double plan,
    required String status,
    required int term,
    required bool billPay,
    required int unPaidNo,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId);
      final docs = await ref.collection('recharges').orderBy('ymRec').get();
      Recharge? recent;
      int monthCode = DateTime.now().month;
      int rechargeYear = DateTime.now().year;
      if (docs.docs.isNotEmpty) {
        recent = Recharge.fromMap(docs.docs.last.data());
        if (recent.ymRec.year > rechargeYear) {
          rechargeYear = recent.ymRec.year;
          monthCode = recent.ymRec.month + 1;
        } else if (recent.ymRec.year == rechargeYear &&
            recent.ymRec.month >= monthCode) {
          monthCode = recent.ymRec.month + 1;
        }
      }

      final batch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < term; i++) {
        if (monthCode > 12) {
          monthCode = 1;
          rechargeYear += 1;
        }
        final rechargeRef = ref.collection('recharges').doc();
        final activeRecharge = Recharge(
          id: rechargeRef.id,
          status: true,
          addInfo: null,
          date: null,
          ymRec: DateTime(rechargeYear, monthCode),
          billPay: billPay,
          plan: plan.toString(),
        ).toJson()
          ..['date'] = FieldValue.serverTimestamp();

        batch.set(rechargeRef, activeRecharge);

        // Update monthly aggregated collection report atomically
        final planVal = plan.toDouble();
        final reportRef = FirebaseFirestore.instance
            .collection('users/${op.id}/reports')
            .doc('${rechargeYear}_$monthCode');
        batch.set(
          reportRef,
          {
            'year': rechargeYear,
            'month': monthCode,
            'totalBilled': FieldValue.increment(planVal),
            'billedCount': FieldValue.increment(1),
            if (billPay) 'totalPaid': FieldValue.increment(planVal),
            if (billPay) 'paidCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        monthCode += 1;
      }

      batch.update(ref, {
        'curSts': 'Active',
        'runYear': rechargeYear,
        'expMon': monthCode - 1,
        'noOfPenBil': billPay ? unPaidNo : unPaidNo + term,
      });

      if (status != 'Active') {
        final areaRef = FirebaseFirestore.instance
            .collection('users/${op.id}/areas')
            .doc(areaId);
        batch.update(areaRef, {
          'aa': FieldValue.increment(1),
          'iaa': FieldValue.increment(-1),
        });
      }

      await batch.commit();
      await getuserData();

      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Activation successful!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Activation failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> deactivateCustomer(
    BuildContext context, {
    required String customerId,
    required String areaId,
    required String year,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId);
      final docs = await ref.collection('recharges').orderBy('ymRec').get();
      if (docs.docs.isEmpty) {
        if (context.mounted) Navigator.pop(context);
        Fluttertoast.showToast(msg: 'No recharges found');
        return;
      }
      final recent = Recharge.fromMap(docs.docs.last.data());
      final now = DateTime.now();
      if (recent.ymRec.year == now.year && recent.ymRec.month <= now.month) {
        final areaRef = FirebaseFirestore.instance
            .collection('users/${op.id}/areas')
            .doc(areaId);

        final batch = FirebaseFirestore.instance.batch();
        batch.update(ref.collection('recharges').doc(recent.id), {
          'addInfo': 'DC: ${DateFormat('dd, MMMM / yyyy').format(DateTime.now())}'
        });
        batch.update(ref, {'curSts': 'Inactive'});
        batch.update(areaRef, {
          'aa': FieldValue.increment(-1),
          'iaa': FieldValue.increment(1),
        });

        await batch.commit();
        await getuserData();

        if (context.mounted) Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Deactivation successful!');
      } else {
        if (context.mounted) Navigator.pop(context);
        Fluttertoast.showToast(
            msg:
                'Deactivation not possible!\nPlease delete the future recharges');
      }
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Deactivation failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<void> billPaid(
    BuildContext context, {
    required String customerId,
    required String year,
    required String rechargeId,
    required int unpaidBillno,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers');

      final recRef =
          ref.doc(customerId).collection('recharges').doc(rechargeId);
      final recSnap = await recRef.get();

      final batch = FirebaseFirestore.instance.batch();
      batch.update(ref.doc(customerId), {'noOfPenBil': FieldValue.increment(-1)});
      batch.update(recRef, {'billPay': true});

      if (recSnap.exists && recSnap.data() != null) {
        final recData = recSnap.data()!;
        final planVal =
            double.tryParse(recData['plan']?.toString() ?? '0') ?? 0.0;
        final recDate =
            (recData['ymRec'] as Timestamp?)?.toDate() ?? DateTime.now();
        final reportRef = FirebaseFirestore.instance
            .collection('users/${op.id}/reports')
            .doc('${recDate.year}_${recDate.month}');
        batch.set(
          reportRef,
          {
            'year': recDate.year,
            'month': recDate.month,
            'totalPaid': FieldValue.increment(planVal),
            'paidCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      if (context.mounted) Navigator.pop(context);
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Bill payment failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }

  static Future<bool> deleteRecharge(
    BuildContext context, {
    required String customerId,
    required String areaId,
    required Recharge recharge,
    required int unPaidNo,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    int updateYear = DateTime.now().year;
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      String status = 'Inactive';
      int month = 0;
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers');

      await ref
          .doc(customerId)
          .collection('recharges')
          .doc(recharge.id)
          .delete();

      // Decrement monthly report rollup
      final planVal = double.tryParse(recharge.plan ?? '0') ?? 0.0;
      final reportRef = FirebaseFirestore.instance
          .collection('users/${op.id}/reports')
          .doc('${recharge.ymRec.year}_${recharge.ymRec.month}');
      await reportRef.set(
        {
          'totalBilled': FieldValue.increment(-planVal),
          'billedCount': FieldValue.increment(-1),
          if (recharge.billPay == true) 'totalPaid': FieldValue.increment(-planVal),
          if (recharge.billPay == true) 'paidCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (recharge.billPay != null && !recharge.billPay!) {
        await ref.doc(customerId).update({'noOfPenBil': FieldValue.increment(-1)});
      }
      final docs = await ref
          .doc(customerId)
          .collection('recharges')
          .orderBy('ymRec')
          .get();
      if (docs.docs.isNotEmpty) {
        final recent = Recharge.fromMap(docs.docs.last.data());
        updateYear = recent.ymRec.year;
        status = recent.status ? 'Active' : 'Inactive';
        month = recent.ymRec.month;
      }
      await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId)
          .update({'runYear': updateYear, 'curSts': status, 'expMon': month});

      if (status == 'Inactive') {
        final areaRef = FirebaseFirestore.instance
            .collection('users/${op.id}/areas')
            .doc(areaId);
        await areaRef.update({
          'aa': FieldValue.increment(-1),
          'iaa': FieldValue.increment(1),
        });
        await getuserData();
      }
      if (context.mounted) Navigator.pop(context);
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Delete recharge failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
    return recharge.ymRec.year != updateYear;
  }

  static Future<void> deleteCustomer(
    BuildContext context, {
    required String areaId,
    required String customerId,
    required bool isActive,
    required int totalCount,
    required int otherCount,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final custInst = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId);
      final areaInst = FirebaseFirestore.instance
          .collection('users/${op.id}/areas')
          .doc(areaId);
      final key = isActive ? 'aa' : 'iaa';

      final batch = FirebaseFirestore.instance.batch();
      batch.delete(custInst);
      batch.update(areaInst, {
        'ta': FieldValue.increment(-1),
        key: FieldValue.increment(-1),
      });

      await batch.commit();
      await getuserData();

      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Customer successfully deleted!');
    } on PlatformException catch (error) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Delete customer failed');
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR: something went wrong!');
    }
  }
}
