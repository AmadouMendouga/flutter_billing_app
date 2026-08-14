class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? otpCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Entre le code reçu par email';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Le code doit contenir 6 chiffres';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }
}
