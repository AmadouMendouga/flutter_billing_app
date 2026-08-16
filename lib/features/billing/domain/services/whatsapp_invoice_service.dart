abstract interface class WhatsAppInvoiceService {
  Future<void> share({
    required String recipientPhoneNumber,
    required String message,
  });
}

final class WhatsAppInvoiceShareException implements Exception {
  const WhatsAppInvoiceShareException([this.cause]);

  final Object? cause;
}

String? normalizeWhatsAppPhoneNumber(
  String input, {
  String defaultCountryCode = '237',
}) {
  final raw = input.trim();
  if (raw.isEmpty) return null;
  if (!RegExp(r'^\+?[0-9\s().-]+$').hasMatch(raw)) return null;

  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  final hasInternationalPrefix = raw.startsWith('+') || digits.startsWith('00');
  if (digits.startsWith('00')) digits = digits.substring(2);

  if (!hasInternationalPrefix &&
      !digits.startsWith(defaultCountryCode) &&
      digits.length == 9 &&
      digits.startsWith('6')) {
    digits = '$defaultCountryCode$digits';
  }

  if (!RegExp(r'^[1-9][0-9]{7,14}$').hasMatch(digits)) return null;
  return digits;
}
