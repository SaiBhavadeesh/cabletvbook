import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/payment_gateway/razor_pay_screen.dart';

AuthCredential? _phoneCredential;
UserCredential? _authResult;
String? _phoneVerificationId;

class Authentication {
  static Future<void> signinWithEmailAndPassword(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      _authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = _authResult?.user;
      await DatabaseService.getuserData();
      final op = operatorDetails;
      final user = firebaseUser;
      if (op != null && op.isSubscribed) {
        await DatabaseService.getuserData();
        Navigator.of(context).pushNamedAndRemoveUntil(
            BottomTabsScreen.routeName, (route) => false);
      } else if (user != null && user.phoneNumber == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            RegisterScreen.routeName, (route) => false);
      } else {
        await DatabaseService.getuserData();
        Navigator.of(context).pushNamedAndRemoveUntil(
            RazorPayScreen.routeName, (route) => false);
      }
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? 'Auth error');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? 'Platform error');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> signinWithGoogle(BuildContext context) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final GoogleSignIn googleSignin = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleAccount = await googleSignin.signIn();
      if (googleAccount == null) {
        Navigator.pop(context);
        return;
      }
      final GoogleSignInAuthentication googleAuthentication =
          await googleAccount.authentication;
      final AuthCredential googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken,
      );
      _authResult =
          await FirebaseAuth.instance.signInWithCredential(googleCredential);
      firebaseUser = _authResult?.user;
      isGoogleUser = true;
      googleSignin.signOut();

      final user = firebaseUser;
      if (user != null && user.phoneNumber == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RegisterScreen.routeName,
          (route) => false,
          arguments: {'email': user.email, 'password': null},
        );
      } else {
        await DatabaseService.getuserData();
        if (operatorDetails != null && operatorDetails!.isSubscribed) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              BottomTabsScreen.routeName, (route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              RazorPayScreen.routeName, (route) => false);
        }
      }
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? 'Auth error');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? 'Platform error');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> verifyPhoneNumberAndRegister({
    required BuildContext context,
    required String phoneNumber,
    required String email,
    required String? password,
  }) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 49),
        verificationCompleted: (phoneAuthCredential) async {
          try {
            DefaultDialogBox.loadingDialog(context);
            _phoneCredential = phoneAuthCredential;
            if (isGoogleUser) {
              final current = FirebaseAuth.instance.currentUser;
              if (current != null) {
                _authResult =
                    await current.linkWithCredential(_phoneCredential!);
              }
            } else {
              _authResult = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password ?? '');
              _authResult =
                  await _authResult?.user?.linkWithCredential(_phoneCredential!);
            }
            firebaseUser = _authResult?.user;
            final user = firebaseUser;
            final op = operatorDetails;
            if (user != null && op != null) {
              op.id = user.uid;
              final firestoreInstance = FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid);
              await firestoreInstance.set(op.toJson());
              if (areas.isNotEmpty) {
                final areaInstance =
                    firestoreInstance.collection('areas').doc();
                await areaInstance
                    .set(areas.first.toJson()..['id'] = areaInstance.id);
              }
              await DatabaseService.getuserData();
            }
            Navigator.of(context).pushNamedAndRemoveUntil(
                RazorPayScreen.routeName, (route) => false);
          } on PlatformException catch (error) {
            Navigator.pop(context);
            DefaultDialogBox.errorDialog(context, content: error.message ?? '');
            try {
              await _authResult?.user?.delete();
            } catch (_) {}
          } catch (error) {
            Navigator.pop(context);
            DefaultDialogBox.errorDialog(context);
            try {
              await _authResult?.user?.delete();
            } catch (_) {}
          }
        },
        verificationFailed: (error) async {
          Navigator.pop(context);
          DefaultDialogBox.errorDialog(context, content: error.message ?? '');
        },
        codeSent: (verificationId, [forceResendingToken]) {
          _phoneVerificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      try {
        await _authResult?.user?.delete();
      } catch (_) {}
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      try {
        await _authResult?.user?.delete();
      } catch (_) {}
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      try {
        await _authResult?.user?.delete();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      } catch (_) {}
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> verifyOTPAndRegister({
    required BuildContext context,
    required String otp,
    required String email,
    required String? password,
  }) async {
    try {
      DefaultDialogBox.loadingDialog(context);
      _phoneCredential = PhoneAuthProvider.credential(
          verificationId: _phoneVerificationId ?? '', smsCode: otp);
      if (isGoogleUser) {
        final current = FirebaseAuth.instance.currentUser;
        if (current != null) {
          _authResult =
              await current.linkWithCredential(_phoneCredential!);
        }
      } else {
        _authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password ?? '');
        _authResult =
            await _authResult?.user?.linkWithCredential(_phoneCredential!);
      }
      firebaseUser = _authResult?.user;
      final user = firebaseUser;
      final op = operatorDetails;
      if (user != null && op != null) {
        op.id = user.uid;
        final firestoreInstance =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await firestoreInstance.set(op.toJson());
        if (areas.isNotEmpty) {
          final areaInstance = firestoreInstance.collection('areas').doc();
          await areaInstance
              .set(areas.first.toJson()..['id'] = areaInstance.id);
        }
        await DatabaseService.getuserData();
      }
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RazorPayScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code != 'invalid-verification-code') {
        try {
          await _authResult?.user?.delete();
        } catch (_) {}
        Navigator.of(context)
            .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      }
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      try {
        await _authResult?.user?.delete();
      } catch (_) {}
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (error) {
      Navigator.pop(context);
      try {
        await _authResult?.user?.delete();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      } catch (_) {}
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> signout(BuildContext context) async {
    try {
      DefaultDialogBox.loadingDialog(context);
      await FirebaseAuth.instance.signOut();
      firebaseUser = null;
      isGoogleUser = false;
      operatorDetails = null;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changePassword(
    BuildContext context, {
    required String password,
  }) async {
    Navigator.pop(context);
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'password': password});
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login') {
        await DefaultDialogBox.errorDialog(
          context,
          title: error.message ?? 'Requires recent login',
          content: 'Do you want to proceed with this action?',
          function: () => signout(context),
        );
      }
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changeEmailAddress(
    BuildContext context, {
    required String email,
  }) async {
    Navigator.pop(context);
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(email);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'email': email});
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login') {
        await DefaultDialogBox.errorDialog(
          context,
          title: error.message ?? 'Requires recent login',
          content: 'Do you want to proceed with this action?',
          function: () => signout(context),
        );
      }
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changePhoneNumber(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          DefaultDialogBox.loadingDialog(context);
          await user.updatePhoneNumber(phoneAuthCredential);
          firebaseUser = FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'phoneNumber': firebaseUser?.phoneNumber});
          Navigator.pop(context);
          Navigator.pop(context);
        },
        verificationFailed: (error) {
          Navigator.pop(context);
          DefaultDialogBox.errorDialog(context, content: error.message ?? '');
        },
        codeSent: (verificationId, [forceResendingToken]) {
          _phoneVerificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login') {
        await DefaultDialogBox.errorDialog(
          context,
          title: error.message ?? 'Requires recent login',
          content: 'Do you want to proceed with this action?',
          function: () => signout(context),
        );
      }
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changeNumberWithOtp(
    BuildContext context, {
    required String otp,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      _phoneCredential = PhoneAuthProvider.credential(
          verificationId: _phoneVerificationId ?? '', smsCode: otp);
      await user.updatePhoneNumber(_phoneCredential as PhoneAuthCredential);
      firebaseUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'phoneNumber': firebaseUser?.phoneNumber});
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login') {
        await DefaultDialogBox.errorDialog(
          context,
          title: error.message ?? 'Requires recent login',
          content: 'Do you want to proceed with this action?',
          function: () => signout(context),
        );
      }
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> sendEmailVerificationMail(BuildContext context) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
      Navigator.pop(context);
      await DefaultDialogBox.errorDialog(
        context,
        title: 'Email successfully sent !',
        content:
            'Please check your mail, and click on the link provided to verify and restart the app !',
      );
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message ?? '');
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }
}
