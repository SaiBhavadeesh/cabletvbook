import 'package:validators/validators.dart' as validate;

String? defaultValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required !';
  if (value.length > 20) return 'value is not supported !';
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required !';
  if (validate.isEmail(value.trim())) return null;
  return 'please enter valid email !';
}

String? passwordValidator(String? value, bool isLogin) {
  if (value == null || value.isEmpty) return 'This field is required !';
  if (!isLogin) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(value);
    if (value.length >= 6 && hasUpper && hasLower && hasDigit && hasSpecial) {
      return null;
    }
    return 'must contain atleast 1 number, 1 special character,\n1 capital letter and 1 small letter !';
  }
  return null;
}

String? reCheckValidator(String? value, String? otherValue) {
  if (value == null || value.isEmpty) return 'This field is required !';
  if (value == otherValue) return null;
  return "passwords did not match !";
}

String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required !';
  final trimmed = value.trim();
  if (!validate.isNumeric(trimmed) || trimmed.length != 10) {
    return 'please enter valid number !';
  }
  return null;
}

String? nameValidator(String? value, {int maxLength = 30}) {
  if (value == null || value.trim().isEmpty) return 'This field is required !';
  final trimmed = value.trim();
  if (trimmed.length > maxLength) return 'name is too long !';
  final nameRegex = RegExp(r'^[a-zA-Z0-9 ]+$');
  if (!nameRegex.hasMatch(trimmed)) {
    return 'must be a combination of alphabet & number !';
  }
  return null;
}

String? addressValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required !';
  if (value.trim().length > 50) return 'address is too long !';
  return null;
}

String? planValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required !';
  final trimmed = value.trim();
  if (!validate.isNumeric(trimmed)) return 'not a valid number !';
  final parsed = double.tryParse(trimmed);
  if (parsed == null) return 'not a valid number !';
  if (trimmed.length > 5) return 'amount is too high!';
  return null;
}
