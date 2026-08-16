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

    await service.share(
      recipientPhoneNumber: '+237 699 00 11 22',
      message: message,
    );

    expect(launchedUri?.scheme, 'https');
    expect(launchedUri?.host, 'wa.me');
    expect(launchedUri?.path, '/237699001122');
    expect(launchedUri?.queryParameters['text'], message);
  });

  test('turns a false launcher result into a typed failure', () async {
    final service = UrlLauncherWhatsAppInvoiceService(
      launcher: (_) async => false,
    );

    await expectLater(
      service.share(recipientPhoneNumber: '699001122', message: 'invoice'),
      throwsA(isA<WhatsAppInvoiceShareException>()),
    );
  });

  test('wraps launcher exceptions in a typed failure', () async {
    final service = UrlLauncherWhatsAppInvoiceService(
      launcher: (_) async => throw StateError('browser rejected the popup'),
    );

    await expectLater(
      service.share(recipientPhoneNumber: '699001122', message: 'invoice'),
      throwsA(isA<WhatsAppInvoiceShareException>()),
    );
  });

  test('normalizes local and international customer numbers', () {
    expect(normalizeWhatsAppPhoneNumber('6 99 00 11 22'), '237699001122');
    expect(normalizeWhatsAppPhoneNumber('+237 699 00 11 22'), '237699001122');
    expect(normalizeWhatsAppPhoneNumber('00237 699 00 11 22'), '237699001122');
    expect(normalizeWhatsAppPhoneNumber('+33 6 12 34 56 78'), '33612345678');
    expect(normalizeWhatsAppPhoneNumber('123'), isNull);
    expect(normalizeWhatsAppPhoneNumber('client 699001122'), isNull);
  });
}
