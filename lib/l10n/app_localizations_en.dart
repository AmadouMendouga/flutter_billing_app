// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Billing App';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHint => 'Your name or shop name';

  @override
  String get save => 'Save';

  @override
  String get preferences => 'Preferences';

  @override
  String get preferenceSaveFailed => 'Could not save this preference.';

  @override
  String get language => 'Language';

  @override
  String get deviceDefault => 'Device default';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get management => 'Management';

  @override
  String get products => 'Products';

  @override
  String get manageStockAndBarcodes => 'Manage stock and barcodes';

  @override
  String get shopDetails => 'Shop details';

  @override
  String get editBusinessInfoAndAddress => 'Edit business info and address';

  @override
  String get hardware => 'Hardware';

  @override
  String get printDevice => 'Print device';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get noPrinterConnected => 'No printer connected';

  @override
  String get connected => 'Connected';

  @override
  String get connectedToPrinter => 'Connected to printer';

  @override
  String get bluetoothPairingInstructions =>
      'To connect a new device, tap the Settings gear to pair it in your phone\'s Bluetooth settings, then return and tap Refresh.';

  @override
  String get account => 'Account';

  @override
  String get logOut => 'Log out';

  @override
  String get signOutAccount => 'Sign out of this shop account';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileUpdateFailed => 'The profile could not be updated.';

  @override
  String get chooseProfileImage => 'Choose a profile image';

  @override
  String get profileImageHelp =>
      'Choose any photo from your device. It will be resized automatically.';

  @override
  String get invalidImage => 'This image could not be read.';

  @override
  String get imageTooLarge => 'This image is too large. Choose another one.';

  @override
  String get nameRequired => 'Please enter a name';

  @override
  String get editProfileSubtitle => 'Update your name and profile photo';

  @override
  String get saving => 'Saving…';

  @override
  String get remove => 'Remove';

  @override
  String get createAccount => 'Create an account';

  @override
  String get signIn => 'Sign in';

  @override
  String get createShopAccountSubtitle => 'Create your shop account';

  @override
  String get signInShopSubtitle => 'Sign in to your shop';

  @override
  String get shopName => 'Shop name';

  @override
  String get shopNameHint => 'My Shop';

  @override
  String get shopNameRequired => 'Shop name is required';

  @override
  String get email => 'Email';

  @override
  String get emailExample => 'nara@example.com';

  @override
  String get password => 'Password';

  @override
  String get newPasswordHint => 'Uppercase, lowercase, number and symbol (6+)';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get signInButton => 'Sign in';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccountCreate => 'No account yet? Create one';

  @override
  String get emailRequired => 'Please enter an email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String passwordMissingRequirements(String requirements) {
    return 'Missing: $requirements';
  }

  @override
  String get sixCharactersMinimum => 'at least 6 characters';

  @override
  String get oneLowercaseLetter => 'one lowercase letter';

  @override
  String get oneUppercaseLetter => 'one uppercase letter';

  @override
  String get oneNumber => 'one number';

  @override
  String get oneSpecialCharacter => 'one special character';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordDescription => 'We\'ll send you a link to reset it.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get emailSent => 'Email sent';

  @override
  String resetEmailSent(String email) {
    return 'Check your inbox ($email) and follow the link to choose a new password.';
  }

  @override
  String get close => 'Close';

  @override
  String get emailVerified => 'Email verified!';

  @override
  String get openingShop => 'Opening your shop…';

  @override
  String get verifyEmail => 'Verify your email';

  @override
  String get verificationLinkSent => 'We just sent you a verification link.';

  @override
  String verificationLinkSentTo(String email) {
    return 'We sent a verification link to $email. Open it; this screen will unlock automatically.';
  }

  @override
  String get notVerifiedYet =>
      'Not verified yet — open the link received by email first.';

  @override
  String get clickedVerificationLink => 'I\'ve opened the link';

  @override
  String resendEmailCountdown(int seconds) {
    return 'Resend email (${seconds}s)';
  }

  @override
  String get resendEmail => 'Resend email';

  @override
  String get cameraOffTitle => 'Camera is turned off';

  @override
  String get cameraOffBody =>
      'Turn on your camera to start scanning barcodes and items automatically.';

  @override
  String get turnOnCamera => 'Turn on camera';

  @override
  String get customizeShopTitle => 'Customize your shop!';

  @override
  String get customizeShopBody =>
      'Add your shop\'s address and phone number so they appear on your receipts.';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get edit => 'Edit';

  @override
  String get scannedItems => 'Scanned items';

  @override
  String itemsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items total',
      one: '1 item total',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get totalPrice => 'Total price';

  @override
  String get emptyList => 'List is empty';

  @override
  String get emptyListBody =>
      'Scanned items will appear here as you scan them with the camera above.';

  @override
  String barcodeNotFound(String barcode) {
    return 'No product found for barcode $barcode.';
  }

  @override
  String productAlreadyInCart(String name) {
    return '$name is already in the cart.';
  }

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scannerTitle => 'Scan barcode';

  @override
  String get alignBarcode => 'Align the barcode inside the frame';

  @override
  String get checkout => 'Checkout';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get printedSuccessfully => 'Printed successfully';

  @override
  String get productName => 'Product name';

  @override
  String get price => 'Price';

  @override
  String get total => 'Total';

  @override
  String get scanToPayOrangeMoney => 'Scan to pay (Orange Money)';

  @override
  String get grandTotal => 'Grand total';

  @override
  String get shopDetailsNotLoaded => 'Shop details are not loaded';

  @override
  String get printReceipt => 'Print receipt';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get completeSale => 'Complete sale';

  @override
  String get saleCompleted => 'Sale completed';

  @override
  String get productManagement => 'Product management';

  @override
  String get searchProducts => 'Search products';

  @override
  String get scanOrEnterBarcode => 'Scan or enter a barcode';

  @override
  String get barcodeRequired => 'Please enter a barcode';

  @override
  String get tapScannerIcon => 'Tap the icon to open the camera scanner';

  @override
  String get openScannerHint => 'Tap the icon to open the camera scanner';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get noProducts => 'No products found. Add one!';

  @override
  String get noSearchResults => 'No products match your search.';

  @override
  String get noMatchingProducts => 'No products match your search.';

  @override
  String get addFirstProduct => 'Add your first product';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get barcode => 'Barcode';

  @override
  String get productNameHint => 'e.g. Basmati rice';

  @override
  String get exampleProductName => 'e.g. Basmati rice';

  @override
  String get productNameRequired => 'Please enter a product name';

  @override
  String get stock => 'Stock';

  @override
  String get invalidPrice => 'Please enter a valid price';

  @override
  String get invalidStock => 'Please enter a valid stock quantity';

  @override
  String get requiredField => 'Required';

  @override
  String get priceRequired => 'Please enter a price';

  @override
  String get priceInvalidNumber => 'Please enter a valid number';

  @override
  String get priceCannotBeNegative => 'Price cannot be negative';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get delete => 'Delete';

  @override
  String get deleteProductTitle => 'Delete product';

  @override
  String deleteProductBody(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String productAlreadyExists(String barcode) {
    return 'A product with barcode “$barcode” already exists.';
  }

  @override
  String productBarcodeExists(String barcode) {
    return 'A product with barcode “$barcode” already exists.';
  }

  @override
  String get productAdded => 'Product added';

  @override
  String get productUpdated => 'Product updated';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get generalInformation => 'General information';

  @override
  String get receiptDetailsDescription =>
      'These details will appear on your digital and printed receipts.';

  @override
  String get addressLine1 => 'Address line 1';

  @override
  String get addressLine1Hint => 'e.g. Main Street, Douala';

  @override
  String get addressLine2Optional => 'Address line 2 (optional)';

  @override
  String get addressLine2Hint => 'e.g. Akwa';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberHint => '+237 6 00 00 00 00';

  @override
  String get orangeMoneyNumber => 'Orange Money number';

  @override
  String get orangeMoneyNumberHint => '6 00 00 00 00';

  @override
  String get receiptFooterText => 'Receipt footer text';

  @override
  String maxCharacters(int count) {
    return 'Maximum $count characters';
  }

  @override
  String get receiptFooterHint => 'Thank you. See you again!';

  @override
  String get saveDetails => 'Save details';

  @override
  String get shopDetailsSaved => 'Shop details saved!';

  @override
  String get profileLoadFailed => 'Unable to load your profile.';

  @override
  String get startupLoadError =>
      'Unable to load the app. Check your internet connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get invoiceTitle => 'Invoice';

  @override
  String get invoiceDate => 'Date';

  @override
  String get invoiceAddress => 'Address';

  @override
  String get sendInvoiceWhatsApp => 'Send invoice via WhatsApp';

  @override
  String get openingWhatsApp => 'Opening WhatsApp…';

  @override
  String get whatsAppShareFailed =>
      'Unable to open WhatsApp. Check that it is installed and try again.';

  @override
  String get emptyInvoiceCannotShare =>
      'Add at least one item before sharing the invoice.';

  @override
  String get clientWhatsAppNumber => 'Customer WhatsApp number';

  @override
  String get clientWhatsAppNumberHint => '+237 6 99 00 00 00';

  @override
  String get clientWhatsAppNumberHelp =>
      'The number is used only to open the conversation and will not be saved.';

  @override
  String get clientPhoneNumberRequired => 'Enter the customer\'s number.';

  @override
  String get invalidWhatsAppNumber =>
      'Enter a valid number with its country code.';

  @override
  String get continueToWhatsApp => 'Continue to WhatsApp';
}
