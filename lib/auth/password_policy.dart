enum PasswordStrength { weak, fair, strong }

abstract final class PasswordPolicy {
  static const minLength = 10;

  static String? validate(String? value) {
    final password = value ?? '';
    if (password.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'أضيفي حرفًا إنجليزيًا واحدًا على الأقل.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'أضيفي رقمًا واحدًا على الأقل.';
    }
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(password)) {
      return 'أضيفي رمزًا واحدًا على الأقل مثل ! أو @ أو #.';
    }
    return null;
  }

  static String? validateConfirmation({
    required String? confirmation,
    required String password,
  }) {
    if ((confirmation ?? '').isEmpty) return 'أكدي كلمة المرور.';
    if (confirmation != password) return 'كلمتا المرور غير متطابقتين.';
    return null;
  }

  static PasswordStrength strength(String password) {
    if (validate(password) != null) return PasswordStrength.weak;

    var score = 0;
    if (password.length >= 12) score++;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9\s]').allMatches(password).length >= 2) score++;

    return score >= 2 ? PasswordStrength.strong : PasswordStrength.fair;
  }
}
