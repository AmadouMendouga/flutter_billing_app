import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/presentation/services/invoice_message_builder.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/l10n/app_localizations_en.dart';
import 'package:billing_app/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = InvoiceMessageBuilder();
  const items = [
    CartItem(
      product: Product(
        id: 'soap',
        name: 'Savon doux',
        barcode: '100',
        price: 1500,
      ),
      quantity: 2,
    ),
    CartItem(
      product: Product(id: 'water', name: 'Eau', barcode: '200', price: 500),
    ),
  ];

  test('builds a complete French WhatsApp invoice', () {
    final message = builder.build(
      localizations: AppLocalizationsFr(),
      shop: const Shop(
        name: 'Ma Boutique',
        addressLine1: 'Akwa',
        addressLine2: 'Douala',
        phoneNumber: '+237 600 000 000',
        upiId: 'must-not-be-shared',
        footerText: 'Merci pour votre achat.',
      ),
      items: items,
      issuedAt: DateTime(2026, 8, 16, 3, 18),
    );

    expect(message, contains('*Ma Boutique*'));
    expect(message, contains('*FACTURE*'));
    expect(message, contains('16/08/2026 03:18'));
    expect(message, contains('Adresse: Akwa, Douala'));
    expect(message, contains('Numéro de téléphone: +237 600 000 000'));
    expect(message, contains('2 × Savon doux @ 1500 FCFA = 3000 FCFA'));
    expect(message, contains('*TOTAL: 3500 FCFA*'));
    expect(message, endsWith('Merci pour votre achat.'));
    expect(message, isNot(contains('must-not-be-shared')));
  });

  test('uses English labels and omits empty optional shop details', () {
    final message = builder.build(
      localizations: AppLocalizationsEn(),
      shop: const Shop(name: 'Corner Shop'),
      items: items.take(1).toList(),
      issuedAt: DateTime(2026, 8, 16, 15, 4),
    );

    expect(message, contains('*INVOICE*'));
    expect(message, contains('Date: 16/08/2026 15:04'));
    expect(message, isNot(contains('Address:')));
    expect(message, isNot(contains('Phone number:')));
    expect(message, contains('*TOTAL: 3000 FCFA*'));
    expect(message, endsWith('Thank you. See you again!'));
  });
}
