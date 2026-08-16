import 'package:url_launcher/url_launcher.dart';

import '../../domain/services/whatsapp_invoice_service.dart';

typedef WhatsAppUrlLauncher = Future<bool> Function(Uri uri);

Future<bool> _launchExternally(Uri uri) {
  return launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
}

Uri buildWhatsAppInvoiceUri({
  required String recipientPhoneNumber,
  required String message,
}) {
  return Uri.parse(
    'https://wa.me/$recipientPhoneNumber?text=${Uri.encodeComponent(message)}',
  );
}

final class UrlLauncherWhatsAppInvoiceService
    implements WhatsAppInvoiceService {
  UrlLauncherWhatsAppInvoiceService({WhatsAppUrlLauncher? launcher})
    : _launcher = launcher ?? _launchExternally;

  final WhatsAppUrlLauncher _launcher;

  @override
  Future<void> share({
    required String recipientPhoneNumber,
    required String message,
  }) async {
    final normalizedPhoneNumber = normalizeWhatsAppPhoneNumber(
      recipientPhoneNumber,
    );
    if (normalizedPhoneNumber == null) {
      throw const WhatsAppInvoiceShareException();
    }
    try {
      final didLaunch = await _launcher(
        buildWhatsAppInvoiceUri(
          recipientPhoneNumber: normalizedPhoneNumber,
          message: message,
        ),
      );
      if (!didLaunch) throw const WhatsAppInvoiceShareException();
    } on WhatsAppInvoiceShareException {
      rethrow;
    } catch (error) {
      throw WhatsAppInvoiceShareException(error);
    }
  }
}
