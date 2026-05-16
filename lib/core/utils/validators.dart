import '../constants/app_strings.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return AppStrings.emailRequired;
    final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!re.hasMatch(value)) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return AppStrings.nameRequired;
    return null;
  }

  static String? Function(String?) confirmPassword(String? pass) {
    return (String? value) {
      if (value != pass) return AppStrings.passwordsMismatch;
      return null;
    };
  }
}
