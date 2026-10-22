import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/services/authentication.dart';

class VerifyPhonePopup extends StatelessWidget {
  final bool isUpdate;
  final String? phoneNumber;
  final String? password;

  const VerifyPhonePopup({
    super.key,
    this.isUpdate = false,
    this.phoneNumber,
    this.password,
  });
  static String otp = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Scaffold(
        backgroundColor: Colors.black.withAlpha(178),
        body: Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.03,
                  ),
                  child: const Text(
                    'Confirm verification code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: size.width * .8,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      autoDismissKeyboard: true,
                      pinTheme: PinTheme(
                        inactiveColor: Colors.black26,
                        borderWidth: 1.5,
                        shape: PinCodeFieldShape.circle,
                        fieldWidth: size.width * 0.125,
                        fieldHeight: size.width * 0.125,
                      ),
                      onChanged: (str) => otp = str,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.03,
                    horizontal: size.width * 0.025,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ResendTimerWidget(isUpdate: isUpdate, phoneNumber: phoneNumber),
                      Expanded(
                        child: defaultbutton(
                          context: context,
                          function: () async => isUpdate
                              ? await Authentication.changeNumberWithOtp(context,
                                  otp: otp)
                              : await Authentication.verifyOTPAndRegister(
                                  context: context,
                                  otp: otp,
                                  email: operatorDetails?.email ?? '',
                                  password: password),
                          title: 'Done',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResendTimerWidget extends StatefulWidget {
  final bool isUpdate;
  final String? phoneNumber;

  const ResendTimerWidget({super.key, this.isUpdate = false, this.phoneNumber});

  @override
  _ResendTimerWidgetState createState() => _ResendTimerWidgetState();
}

class _ResendTimerWidgetState extends State<ResendTimerWidget> {
  String _remainingTime = '00 : 60';
  bool _isRequested = true;
  Timer? _timer;
  Timer? _countTimer;

  void alterButton() {
    setState(() {
      _isRequested = !_isRequested;
      if (_isRequested) {
        setTimerWidget();
        setBackButton();
      }
    });
  }

  void setTimerWidget() {
    int time = 59;
    setState(() {
      _remainingTime = '00 : 60';
    });
    _countTimer?.cancel();
    _countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time >= 0) {
        if (mounted) {
          setState(() {
            _remainingTime =
                '00 : ${time < 10 ? '0$time' : time}';
            time = time - 1;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void setBackButton() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 60), () {
      alterButton();
      _countTimer?.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    setTimerWidget();
    setBackButton();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isRequested
        ? Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _remainingTime,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )
        : Expanded(
            child: TextButton(
              onPressed: () async {
                final phone = widget.phoneNumber;
                if (widget.isUpdate && phone != null) {
                  await Authentication.changePhoneNumber(context,
                      phoneNumber: phone);
                } else {
                  final op = operatorDetails;
                  if (op != null) {
                    await Authentication.verifyPhoneNumberAndRegister(
                      context: context,
                      phoneNumber: op.phoneNumber,
                      email: op.email,
                      password: null,
                    );
                  }
                }
                alterButton();
              },
              child: Text(
                'Re-send',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
  }
}
