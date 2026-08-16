import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing App'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name or shop name'**
  String get displayNameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @preferenceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this preference.'**
  String get preferenceSaveFailed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @deviceDefault.
  ///
  /// In en, this message translates to:
  /// **'Device default'**
  String get deviceDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @manageStockAndBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Manage stock and barcodes'**
  String get manageStockAndBarcodes;

  /// No description provided for @shopDetails.
  ///
  /// In en, this message translates to:
  /// **'Shop details'**
  String get shopDetails;

  /// No description provided for @editBusinessInfoAndAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit business info and address'**
  String get editBusinessInfoAndAddress;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get hardware;

  /// No description provided for @printDevice.
  ///
  /// In en, this message translates to:
  /// **'Print device'**
  String get printDevice;

  /// No description provided for @printerConnected.
  ///
  /// In en, this message translates to:
  /// **'Printer connected'**
  String get printerConnected;

  /// No description provided for @noPrinterConnected.
  ///
  /// In en, this message translates to:
  /// **'No printer connected'**
  String get noPrinterConnected;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connectedToPrinter.
  ///
  /// In en, this message translates to:
  /// **'Connected to printer'**
  String get connectedToPrinter;

  /// No description provided for @bluetoothPairingInstructions.
  ///
  /// In en, this message translates to:
  /// **'To connect a new device, tap the Settings gear to pair it in your phone\'s Bluetooth settings, then return and tap Refresh.'**
  String get bluetoothPairingInstructions;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @signOutAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this shop account'**
  String get signOutAccount;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'The profile could not be updated.'**
  String get profileUpdateFailed;

  /// No description provided for @chooseProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile image'**
  String get chooseProfileImage;

  /// No description provided for @profileImageHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose any photo from your device. It will be resized automatically.'**
  String get profileImageHelp;

  /// No description provided for @invalidImage.
  ///
  /// In en, this message translates to:
  /// **'This image could not be read.'**
  String get invalidImage;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This image is too large. Choose another one.'**
  String get imageTooLarge;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameRequired;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your name and profile photo'**
  String get editProfileSubtitle;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createShopAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your shop account'**
  String get createShopAccountSubtitle;

  /// No description provided for @signInShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your shop'**
  String get signInShopSubtitle;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopName;

  /// No description provided for @shopNameHint.
  ///
  /// In en, this message translates to:
  /// **'My Shop'**
  String get shopNameHint;

  /// No description provided for @shopNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Shop name is required'**
  String get shopNameRequired;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'nara@example.com'**
  String get emailExample;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Uppercase, lowercase, number and symbol (6+)'**
  String get newPasswordHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccountCreate.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Create one'**
  String get noAccountCreate;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMissingRequirements.
  ///
  /// In en, this message translates to:
  /// **'Missing: {requirements}'**
  String passwordMissingRequirements(String requirements);

  /// No description provided for @sixCharactersMinimum.
  ///
  /// In en, this message translates to:
  /// **'at least 6 characters'**
  String get sixCharactersMinimum;

  /// No description provided for @oneLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'one lowercase letter'**
  String get oneLowercaseLetter;

  /// No description provided for @oneUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'one uppercase letter'**
  String get oneUppercaseLetter;

  /// No description provided for @oneNumber.
  ///
  /// In en, this message translates to:
  /// **'one number'**
  String get oneNumber;

  /// No description provided for @oneSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'one special character'**
  String get oneSpecialCharacter;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a link to reset it.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get emailSent;

  /// No description provided for @checkSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'If you can’t find the email, check your Spam or Junk folder.'**
  String get checkSpamFolder;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox ({email}) and follow the link to choose a new password.'**
  String resetEmailSent(String email);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified!'**
  String get emailVerified;

  /// No description provided for @openingShop.
  ///
  /// In en, this message translates to:
  /// **'Opening your shop…'**
  String get openingShop;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmail;

  /// No description provided for @verificationLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We just sent you a verification link.'**
  String get verificationLinkSent;

  /// No description provided for @verificationLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Open it; this screen will unlock automatically.'**
  String verificationLinkSentTo(String email);

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet — open the link received by email first.'**
  String get notVerifiedYet;

  /// No description provided for @clickedVerificationLink.
  ///
  /// In en, this message translates to:
  /// **'I\'ve opened the link'**
  String get clickedVerificationLink;

  /// No description provided for @resendEmailCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend email ({seconds}s)'**
  String resendEmailCountdown(int seconds);

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @cameraOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera is turned off'**
  String get cameraOffTitle;

  /// No description provided for @cameraOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on your camera to start scanning barcodes and items automatically.'**
  String get cameraOffBody;

  /// No description provided for @turnOnCamera.
  ///
  /// In en, this message translates to:
  /// **'Turn on camera'**
  String get turnOnCamera;

  /// No description provided for @customizeShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your shop!'**
  String get customizeShopTitle;

  /// No description provided for @customizeShopBody.
  ///
  /// In en, this message translates to:
  /// **'Add your shop\'s address and phone number so they appear on your receipts.'**
  String get customizeShopBody;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @scannedItems.
  ///
  /// In en, this message translates to:
  /// **'Scanned items'**
  String get scannedItems;

  /// No description provided for @itemsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item total} other{{count} items total}}'**
  String itemsTotal(int count);

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPrice;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'List is empty'**
  String get emptyList;

  /// No description provided for @emptyListBody.
  ///
  /// In en, this message translates to:
  /// **'Scanned items will appear here as you scan them with the camera above.'**
  String get emptyListBody;

  /// No description provided for @barcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No product found for barcode {barcode}.'**
  String barcodeNotFound(String barcode);

  /// No description provided for @productAlreadyInCart.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in the cart.'**
  String productAlreadyInCart(String name);

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scannerTitle;

  /// No description provided for @alignBarcode.
  ///
  /// In en, this message translates to:
  /// **'Align the barcode inside the frame'**
  String get alignBarcode;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @printedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Printed successfully'**
  String get printedSuccessfully;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @scanToPayOrangeMoney.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay (Orange Money)'**
  String get scanToPayOrangeMoney;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get grandTotal;

  /// No description provided for @shopDetailsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Shop details are not loaded'**
  String get shopDetailsNotLoaded;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print receipt'**
  String get printReceipt;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete sale'**
  String get completeSale;

  /// No description provided for @saleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sale completed'**
  String get saleCompleted;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product management'**
  String get productManagement;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @scanOrEnterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter a barcode'**
  String get scanOrEnterBarcode;

  /// No description provided for @barcodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a barcode'**
  String get barcodeRequired;

  /// No description provided for @tapScannerIcon.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to open the camera scanner'**
  String get tapScannerIcon;

  /// No description provided for @openScannerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to open the camera scanner'**
  String get openScannerHint;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found. Add one!'**
  String get noProducts;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get noSearchResults;

  /// No description provided for @noMatchingProducts.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get noMatchingProducts;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get addFirstProduct;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Basmati rice'**
  String get productNameHint;

  /// No description provided for @exampleProductName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Basmati rice'**
  String get exampleProductName;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get productNameRequired;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalidPrice;

  /// No description provided for @invalidStock.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid stock quantity'**
  String get invalidStock;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get priceRequired;

  /// No description provided for @priceInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get priceInvalidNumber;

  /// No description provided for @priceCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be negative'**
  String get priceCannotBeNegative;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteProductBody(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @productAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A product with barcode “{barcode}” already exists.'**
  String productAlreadyExists(String barcode);

  /// No description provided for @productBarcodeExists.
  ///
  /// In en, this message translates to:
  /// **'A product with barcode “{barcode}” already exists.'**
  String productBarcodeExists(String barcode);

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product added'**
  String get productAdded;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get productUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @generalInformation.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get generalInformation;

  /// No description provided for @receiptDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'These details will appear on your digital and printed receipts.'**
  String get receiptDetailsDescription;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get addressLine1;

  /// No description provided for @addressLine1Hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Street, Douala'**
  String get addressLine1Hint;

  /// No description provided for @addressLine2Optional.
  ///
  /// In en, this message translates to:
  /// **'Address line 2 (optional)'**
  String get addressLine2Optional;

  /// No description provided for @addressLine2Hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Akwa'**
  String get addressLine2Hint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+237 6 00 00 00 00'**
  String get phoneNumberHint;

  /// No description provided for @orangeMoneyNumber.
  ///
  /// In en, this message translates to:
  /// **'Orange Money number'**
  String get orangeMoneyNumber;

  /// No description provided for @orangeMoneyNumberHint.
  ///
  /// In en, this message translates to:
  /// **'6 00 00 00 00'**
  String get orangeMoneyNumberHint;

  /// No description provided for @receiptFooterText.
  ///
  /// In en, this message translates to:
  /// **'Receipt footer text'**
  String get receiptFooterText;

  /// No description provided for @maxCharacters.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} characters'**
  String maxCharacters(int count);

  /// No description provided for @receiptFooterHint.
  ///
  /// In en, this message translates to:
  /// **'Thank you. See you again!'**
  String get receiptFooterHint;

  /// No description provided for @saveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save details'**
  String get saveDetails;

  /// No description provided for @shopDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Shop details saved!'**
  String get shopDetailsSaved;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile.'**
  String get profileLoadFailed;

  /// No description provided for @startupLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the app. Check your internet connection and try again.'**
  String get startupLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTitle;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get invoiceDate;

  /// No description provided for @invoiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get invoiceAddress;

  /// No description provided for @sendInvoiceWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send invoice via WhatsApp'**
  String get sendInvoiceWhatsApp;

  /// No description provided for @openingWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Opening WhatsApp…'**
  String get openingWhatsApp;

  /// No description provided for @whatsAppShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp. Check that it is installed and try again.'**
  String get whatsAppShareFailed;

  /// No description provided for @emptyInvoiceCannotShare.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item before sharing the invoice.'**
  String get emptyInvoiceCannotShare;

  /// No description provided for @clientWhatsAppNumber.
  ///
  /// In en, this message translates to:
  /// **'Customer WhatsApp number'**
  String get clientWhatsAppNumber;

  /// No description provided for @clientWhatsAppNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+237 6 99 00 00 00'**
  String get clientWhatsAppNumberHint;

  /// No description provided for @clientWhatsAppNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'The number is used only to open the conversation and will not be saved.'**
  String get clientWhatsAppNumberHelp;

  /// No description provided for @clientPhoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer\'s number.'**
  String get clientPhoneNumberRequired;

  /// No description provided for @invalidWhatsAppNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number with its country code.'**
  String get invalidWhatsAppNumber;

  /// No description provided for @continueToWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to WhatsApp'**
  String get continueToWhatsApp;

  /// No description provided for @checkingAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Checking your access…'**
  String get checkingAccountAccess;

  /// No description provided for @shopPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop awaiting approval'**
  String get shopPendingTitle;

  /// No description provided for @shopPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your email is verified. An administrator must now approve your shop before it becomes active.'**
  String get shopPendingMessage;

  /// No description provided for @shopPendingHelp.
  ///
  /// In en, this message translates to:
  /// **'You can complete the shop details while you wait.'**
  String get shopPendingHelp;

  /// No description provided for @completeShopProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete shop details'**
  String get completeShopProfile;

  /// No description provided for @shopSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop temporarily disabled'**
  String get shopSuspendedTitle;

  /// No description provided for @shopSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'This shop is temporarily disabled. Thank you for your understanding.'**
  String get shopSuspendedMessage;

  /// No description provided for @shopRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop request rejected'**
  String get shopRejectedTitle;

  /// No description provided for @shopRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'The request could not be approved. See the reason below.'**
  String get shopRejectedMessage;

  /// No description provided for @statusReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get statusReason;

  /// No description provided for @shopAccessLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to check the shop status.'**
  String get shopAccessLoadFailed;

  /// No description provided for @adminAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'This account no longer has access to administration.'**
  String get adminAccessDenied;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get adminDashboard;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage requests, shops, and their products'**
  String get adminDashboardSubtitle;

  /// No description provided for @pendingShops.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingShops;

  /// No description provided for @activeShops.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeShops;

  /// No description provided for @suspendedShops.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspendedShops;

  /// No description provided for @rejectedShops.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedShops;

  /// No description provided for @allShops.
  ///
  /// In en, this message translates to:
  /// **'All shops'**
  String get allShops;

  /// No description provided for @noShopsFound.
  ///
  /// In en, this message translates to:
  /// **'No shops found.'**
  String get noShopsFound;

  /// No description provided for @shopOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get shopOwner;

  /// No description provided for @shopStatus.
  ///
  /// In en, this message translates to:
  /// **'Shop status'**
  String get shopStatus;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @approveShop.
  ///
  /// In en, this message translates to:
  /// **'Activate shop'**
  String get approveShop;

  /// No description provided for @suspendShop.
  ///
  /// In en, this message translates to:
  /// **'Suspend shop'**
  String get suspendShop;

  /// No description provided for @reactivateShop.
  ///
  /// In en, this message translates to:
  /// **'Reactivate shop'**
  String get reactivateShop;

  /// No description provided for @rejectShop.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get rejectShop;

  /// No description provided for @administrativeReason.
  ///
  /// In en, this message translates to:
  /// **'Administrative reason'**
  String get administrativeReason;

  /// No description provided for @administrativeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the reason for this decision'**
  String get administrativeReasonHint;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required.'**
  String get reasonRequired;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @shopStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shop status updated.'**
  String get shopStatusUpdated;

  /// No description provided for @adminActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The administrative action failed. Try again.'**
  String get adminActionFailed;

  /// No description provided for @viewShopDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewShopDetails;

  /// No description provided for @registeredProducts.
  ///
  /// In en, this message translates to:
  /// **'Registered products'**
  String get registeredProducts;

  /// No description provided for @copyProducts.
  ///
  /// In en, this message translates to:
  /// **'Copy products'**
  String get copyProducts;

  /// No description provided for @destinationShop.
  ///
  /// In en, this message translates to:
  /// **'Destination shop'**
  String get destinationShop;

  /// No description provided for @selectProducts.
  ///
  /// In en, this message translates to:
  /// **'Select products'**
  String get selectProducts;

  /// No description provided for @copySelectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Copy selection'**
  String get copySelectedProducts;

  /// No description provided for @copyStockNotice.
  ///
  /// In en, this message translates to:
  /// **'Copied products will start with a stock of 0.'**
  String get copyStockNotice;

  /// No description provided for @noOtherShopAvailable.
  ///
  /// In en, this message translates to:
  /// **'No other shop is available.'**
  String get noOtherShopAvailable;

  /// No description provided for @productCopyCompleted.
  ///
  /// In en, this message translates to:
  /// **'{copied} product(s) copied, {skipped} skipped.'**
  String productCopyCompleted(int copied, int skipped);

  /// No description provided for @productCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to copy the products.'**
  String get productCopyFailed;

  /// No description provided for @adminAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get adminAuditLog;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
