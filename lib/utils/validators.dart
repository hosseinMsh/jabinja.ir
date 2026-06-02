class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ایمیل را وارد کنید';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'ایمیل معتبر نیست';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور را وارد کنید';
    }
    if (value.length < 6) {
      return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'نام را وارد کنید';
    }
    if (value.length < 2) {
      return 'نام باید حداقل ۲ کاراکتر باشد';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تکرار رمز عبور را وارد کنید';
    }
    if (value != password) {
      return 'رمز عبور مطابقت ندارد';
    }
    return null;
  }
}
