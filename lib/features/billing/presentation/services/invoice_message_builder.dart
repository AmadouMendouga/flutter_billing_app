import '../../../../l10n/app_localizations.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../domain/entities/cart_item.dart';

final class InvoiceMessageBuilder {
  const InvoiceMessageBuilder();

  String build({
    required AppLocalizations localizations,
    required Shop shop,
    required List<CartItem> items,
    required DateTime issuedAt,
  }) {
    final message = StringBuffer();
    final shopName = shop.name.trim();
    final address = [
      shop.addressLine1.trim(),
      shop.addressLine2.trim(),
    ].where((line) => line.isNotEmpty).join(', ');

    message.writeln(
      '*${shopName.isEmpty ? localizations.appTitle : shopName}*',
    );
    message.writeln('🧾 *${localizations.invoiceTitle.toUpperCase()}*');
    message.writeln(
      '📅 ${localizations.invoiceDate}: ${_formatDateTime(issuedAt)}',
    );
    if (address.isNotEmpty) {
      message.writeln('📍 ${localizations.invoiceAddress}: $address');
    }
    if (shop.phoneNumber.trim().isNotEmpty) {
      message.writeln(
        '📞 ${localizations.phoneNumber}: ${shop.phoneNumber.trim()}',
      );
    }

    message.writeln();
    for (final item in items) {
      message.writeln(
        '• ${item.quantity} × ${item.product.name.trim()} '
        '@ ${_formatMoney(item.product.price)} = ${_formatMoney(item.total)}',
      );
    }

    final total = items.fold<double>(0, (sum, item) => sum + item.total);
    message
      ..writeln()
      ..writeln(
        '*${localizations.total.toUpperCase()}: ${_formatMoney(total)}*',
      )
      ..writeln()
      ..write(
        shop.footerText.trim().isEmpty
            ? localizations.receiptFooterHint
            : shop.footerText.trim(),
      );

    return message.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/'
        '${dateTime.year} ${twoDigits(dateTime.hour)}:'
        '${twoDigits(dateTime.minute)}';
  }

  String _formatMoney(double amount) => '${amount.toStringAsFixed(0)} FCFA';
}
