abstract interface class WhatsAppInvoiceService {
  Future<void> share(String message);
}

final class WhatsAppInvoiceShareException implements Exception {
  const WhatsAppInvoiceShareException([this.cause]);

  final Object? cause;
}
