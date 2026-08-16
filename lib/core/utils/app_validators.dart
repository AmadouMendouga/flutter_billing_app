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

  /// Firebase's password policy on this project (enforced server-side)
  /// rejects passwords missing any of these, beyond the 6-character
  /// minimum — validate the same rules client-side so sign-up doesn't
  /// silently fail against a hint that only mentions the length.
  static String? signUpPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    final missing = <String>[];
    if (value.length < 6) missing.add('6 caractères min.');
    if (!RegExp(r'[a-z]').hasMatch(value)) missing.add('une minuscule');
    if (!RegExp(r'[A-Z]').hasMatch(value)) missing.add('une majuscule');
    if (!RegExp(r'[0-9]').hasMatch(value)) missing.add('un chiffre');
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
      missing.add('un caractère spécial');
    }
    if (missing.isEmpty) return null;
    return 'Il manque : ${missing.join(', ')}';
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
