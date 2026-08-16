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

Uri buildWhatsAppInvoiceUri(String message) {
  return Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
}

final class UrlLauncherWhatsAppInvoiceService
    implements WhatsAppInvoiceService {
  UrlLauncherWhatsAppInvoiceService({WhatsAppUrlLauncher? launcher})
    : _launcher = launcher ?? _launchExternally;

  final WhatsAppUrlLauncher _launcher;

  @override
  Future<void> share(String message) async {
    try {
      final didLaunch = await _launcher(buildWhatsAppInvoiceUri(message));
      if (!didLaunch) throw const WhatsAppInvoiceShareException();
    } on WhatsAppInvoiceShareException {
      rethrow;
    } catch (error) {
      throw WhatsAppInvoiceShareException(error);
    }
  }
}
