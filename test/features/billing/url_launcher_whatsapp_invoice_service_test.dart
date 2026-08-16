import 'package:billing_app/features/billing/data/services/url_launcher_whatsapp_invoice_service.dart';
import 'package:billing_app/features/billing/domain/services/whatsapp_invoice_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens an encoded HTTPS wa.me link with the original message', () async {
    Uri? launchedUri;
    final service = UrlLauncherWhatsAppInvoiceService(
      launcher: (uri) async {
        launchedUri = uri;
        return true;
      },
    );
    const message = 'Facture café & savon\nTotal : 3 500 FCFA';

    await service.share(message);

    expect(launchedUri?.scheme, 'https');
    expect(launchedUri?.host, 'wa.me');
    expect(launchedUri?.queryParameters['text'], message);
  });

  test('turns a false launcher result into a typed failure', () async {
    final service = UrlLauncherWhatsAppInvoiceService(
      launcher: (_) async => false,
    );

    await expectLater(
      service.share('invoice'),
      throwsA(isA<WhatsAppInvoiceShareException>()),
    );
  });

  test('wraps launcher exceptions in a typed failure', () async {
    final service = UrlLauncherWhatsAppInvoiceService(
      launcher: (_) async => throw StateError('browser rejected the popup'),
    );

    await expectLater(
      service.share('invoice'),
      throwsA(isA<WhatsAppInvoiceShareException>()),
    );
  });
}
