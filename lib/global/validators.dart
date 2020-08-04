import 'package:validators/validators.dart' as validate;
import 'package:regexed_validator/regexed_validator.dart';

String defaultValidator(String value) {
  if (value.isEmpty) return 'This field is required !';
  if (value.length > 20) return 'value is not supported !';
  return null;
}

String emailValidator(String value) {
  if (value.isEmpty) return 'This field is required !';
  if (validate.isEmail(value)) return null;
  return 'please enter valid email !';
}

String passwordValidator(String value, bool isLogin) {
  if (value.isEmpty) return 'This field is required !';
  if (!isLogin) {
    if (validator.password(value)) return null;
    return 'must contain atleast 1 number,1 special character,\n1 capital letter and 1 small letter !';
  }
  return null;
}

String reCheckValidator(String value, String otherValue) {
  if (value.isEmpty) return 'This field is required !';
  if (value == otherValue) return null;
  return 'password did not match !';
}

String phoneValidator(String value) {
  if (value.isEmpty) return 'This field is required !';
  if (!validate.isNumeric(value)) return 'please enter valid number !';
  if (value.length != 10) return 'Please enter valid number !';
  return null;
}

String nameValidator(String value) {
  if (value.isEmpty) return 'This field is required !';
  if (validator.name(value)) return null;
  String error;
  final sub = value.split(' ');
  sub.forEach((element) {
    if (!validate.isAlphanumeric(element)) {
      error = 'Must be a combination of alphabet & number !';
    } else if (value.length > 25) {
      error = 'Name is too long !';
    }
  });
  return error;
}

String addressValidator(String value) {
  if (value.isEmpty) return 'This field is required !';
  if (value.length > 50) return 'Address is too long !';
  return null;
}