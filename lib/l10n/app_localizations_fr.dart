// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application de facturation';

  @override
  String get settings => 'Paramètres';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get displayName => 'Nom affiché';

  @override
  String get displayNameHint => 'Ton nom ou le nom de ta boutique';

  @override
  String get save => 'Enregistrer';

  @override
  String get preferences => 'Préférences';

  @override
  String get preferenceSaveFailed =>
      'Impossible d’enregistrer cette préférence.';

  @override
  String get language => 'Langue';

  @override
  String get deviceDefault => 'Langue de l’appareil';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get management => 'Gestion';

  @override
  String get products => 'Produits';

  @override
  String get manageStockAndBarcodes => 'Gérer le stock et les codes-barres';

  @override
  String get shopDetails => 'Informations de la boutique';

  @override
  String get editBusinessInfoAndAddress =>
      'Modifier les informations et l’adresse';

  @override
  String get hardware => 'Matériel';

  @override
  String get printDevice => 'Imprimante';

  @override
  String get printerConnected => 'Imprimante connectée';

  @override
  String get noPrinterConnected => 'Aucune imprimante connectée';

  @override
  String get connected => 'Connectée';

  @override
  String get connectedToPrinter => 'Connexion à l’imprimante réussie';

  @override
  String get bluetoothPairingInstructions =>
      'Pour connecter un appareil, touche l’icône Paramètres, associe-le dans les réglages Bluetooth du téléphone, puis reviens et touche Actualiser.';

  @override
  String get account => 'Compte';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get signOutAccount => 'Se déconnecter du compte de cette boutique';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get profileUpdateFailed => 'Le profil n’a pas pu être mis à jour.';

  @override
  String get chooseProfileImage => 'Choisir une photo de profil';

  @override
  String get profileImageHelp =>
      'Choisis une photo sur ton appareil. Elle sera redimensionnée automatiquement.';

  @override
  String get invalidImage => 'Cette image ne peut pas être lue.';

  @override
  String get imageTooLarge =>
      'Cette image est trop volumineuse. Choisis-en une autre.';

  @override
  String get nameRequired => 'Saisis un nom';

  @override
  String get editProfileSubtitle => 'Modifie ton nom et ta photo de profil';

  @override
  String get saving => 'Enregistrement…';

  @override
  String get remove => 'Supprimer';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createShopAccountSubtitle => 'Crée le compte de ta boutique';

  @override
  String get signInShopSubtitle => 'Connecte-toi à ta boutique';

  @override
  String get shopName => 'Nom de la boutique';

  @override
  String get shopNameHint => 'Ma Boutique';

  @override
  String get shopNameRequired => 'Le nom de la boutique est requis';

  @override
  String get email => 'E-mail';

  @override
  String get emailExample => 'nara@example.com';

  @override
  String get password => 'Mot de passe';

  @override
  String get newPasswordHint => 'Majuscule, minuscule, chiffre et symbole (6+)';

  @override
  String get passwordHint => '6 caractères minimum';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get forgotPasswordQuestion => 'Mot de passe oublié ?';

  @override
  String get createAccountButton => 'Créer le compte';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get alreadyHaveAccount => 'Tu as déjà un compte ? Se connecter';

  @override
  String get noAccountCreate => 'Pas encore de compte ? En créer un';

  @override
  String get emailRequired => 'Saisis une adresse e-mail';

  @override
  String get emailInvalid => 'Saisis une adresse e-mail valide';

  @override
  String get passwordRequired => 'Saisis un mot de passe';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String passwordMissingRequirements(String requirements) {
    return 'Il manque : $requirements';
  }

  @override
  String get sixCharactersMinimum => '6 caractères minimum';

  @override
  String get oneLowercaseLetter => 'une minuscule';

  @override
  String get oneUppercaseLetter => 'une majuscule';

  @override
  String get oneNumber => 'un chiffre';

  @override
  String get oneSpecialCharacter => 'un caractère spécial';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordDescription =>
      'Nous allons t’envoyer un lien pour le réinitialiser.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get emailSent => 'E-mail envoyé';

  @override
  String resetEmailSent(String email) {
    return 'Vérifie ta boîte de réception ($email) et suis le lien pour choisir un nouveau mot de passe.';
  }

  @override
  String get close => 'Fermer';

  @override
  String get emailVerified => 'E-mail vérifié !';

  @override
  String get openingShop => 'Ouverture de ta boutique…';

  @override
  String get verifyEmail => 'Vérifie ton e-mail';

  @override
  String get verificationLinkSent =>
      'Nous venons de t’envoyer un lien de vérification.';

  @override
  String verificationLinkSentTo(String email) {
    return 'Nous avons envoyé un lien de vérification à $email. Ouvre-le : cet écran se débloquera automatiquement.';
  }

  @override
  String get notVerifiedYet =>
      'Pas encore vérifié — ouvre d’abord le lien reçu par e-mail.';

  @override
  String get clickedVerificationLink => 'J’ai ouvert le lien';

  @override
  String resendEmailCountdown(int seconds) {
    return 'Renvoyer l’e-mail (${seconds}s)';
  }

  @override
  String get resendEmail => 'Renvoyer l’e-mail';

  @override
  String get cameraOffTitle => 'La caméra est désactivée';

  @override
  String get cameraOffBody =>
      'Active la caméra pour scanner automatiquement les codes-barres et les articles.';

  @override
  String get turnOnCamera => 'Activer la caméra';

  @override
  String get customizeShopTitle => 'Personnalise ta boutique !';

  @override
  String get customizeShopBody =>
      'Ajoute l’adresse et le téléphone de ta boutique pour qu’ils apparaissent sur tes reçus.';

  @override
  String get dontShowAgain => 'Ne plus afficher';

  @override
  String get edit => 'Modifier';

  @override
  String get scannedItems => 'Articles scannés';

  @override
  String itemsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles au total',
      one: '1 article au total',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String get totalPrice => 'Prix total';

  @override
  String get emptyList => 'La liste est vide';

  @override
  String get emptyListBody =>
      'Les articles apparaîtront ici à mesure que tu les scanneras avec la caméra.';

  @override
  String barcodeNotFound(String barcode) {
    return 'Aucun produit ne correspond au code-barres $barcode.';
  }

  @override
  String productAlreadyInCart(String name) {
    return '$name est déjà dans le panier.';
  }

  @override
  String get scanBarcode => 'Scanner un code-barres';

  @override
  String get scannerTitle => 'Scanner un code-barres';

  @override
  String get alignBarcode => 'Aligne le code-barres dans le cadre';

  @override
  String get checkout => 'Paiement';

  @override
  String get checkoutTitle => 'Paiement';

  @override
  String get printedSuccessfully => 'Impression réussie';

  @override
  String get productName => 'Nom du produit';

  @override
  String get price => 'Prix';

  @override
  String get total => 'Total';

  @override
  String get scanToPayOrangeMoney => 'Scanner pour payer (Orange Money)';

  @override
  String get grandTotal => 'Total général';

  @override
  String get shopDetailsNotLoaded =>
      'Les informations de la boutique ne sont pas chargées';

  @override
  String get printReceipt => 'Imprimer le reçu';

  @override
  String get orderSummary => 'Récapitulatif de la commande';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get completeSale => 'Terminer la vente';

  @override
  String get saleCompleted => 'Vente terminée';

  @override
  String get productManagement => 'Gestion des produits';

  @override
  String get searchProducts => 'Rechercher des produits';

  @override
  String get scanOrEnterBarcode => 'Scanner ou saisir un code-barres';

  @override
  String get barcodeRequired => 'Saisis un code-barres';

  @override
  String get tapScannerIcon => 'Touche l’icône pour ouvrir le scanner';

  @override
  String get openScannerHint => 'Touche l’icône pour ouvrir le scanner';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String errorMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get noProducts => 'Aucun produit. Ajoutes-en un !';

  @override
  String get noSearchResults => 'Aucun produit ne correspond à ta recherche.';

  @override
  String get noMatchingProducts =>
      'Aucun produit ne correspond à ta recherche.';

  @override
  String get addFirstProduct => 'Ajouter ton premier produit';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get barcode => 'Code-barres';

  @override
  String get productNameHint => 'Ex. : riz basmati';

  @override
  String get exampleProductName => 'Ex. : riz basmati';

  @override
  String get productNameRequired => 'Saisis le nom du produit';

  @override
  String get stock => 'Stock';

  @override
  String get invalidPrice => 'Saisis un prix valide';

  @override
  String get invalidStock => 'Saisis une quantité en stock valide';

  @override
  String get requiredField => 'Champ requis';

  @override
  String get priceRequired => 'Saisis un prix';

  @override
  String get priceInvalidNumber => 'Saisis un nombre valide';

  @override
  String get priceCannotBeNegative => 'Le prix ne peut pas être négatif';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteProductTitle => 'Supprimer le produit';

  @override
  String deleteProductBody(String name) {
    return 'Veux-tu vraiment supprimer $name ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String productAlreadyExists(String barcode) {
    return 'Un produit avec le code-barres « $barcode » existe déjà.';
  }

  @override
  String productBarcodeExists(String barcode) {
    return 'Un produit avec le code-barres « $barcode » existe déjà.';
  }

  @override
  String get productAdded => 'Produit ajouté';

  @override
  String get productUpdated => 'Produit mis à jour';

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get generalInformation => 'Informations générales';

  @override
  String get receiptDetailsDescription =>
      'Ces informations apparaîtront sur les reçus numériques et imprimés.';

  @override
  String get addressLine1 => 'Adresse, ligne 1';

  @override
  String get addressLine1Hint => 'Ex. : rue principale, Douala';

  @override
  String get addressLine2Optional => 'Adresse, ligne 2 (facultatif)';

  @override
  String get addressLine2Hint => 'Ex. : Akwa';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneNumberHint => '+237 6 00 00 00 00';

  @override
  String get orangeMoneyNumber => 'Numéro Orange Money';

  @override
  String get orangeMoneyNumberHint => '6 00 00 00 00';

  @override
  String get receiptFooterText => 'Texte de bas de reçu';

  @override
  String maxCharacters(int count) {
    return '$count caractères maximum';
  }

  @override
  String get receiptFooterHint => 'Merci et à bientôt !';

  @override
  String get saveDetails => 'Enregistrer les informations';

  @override
  String get shopDetailsSaved => 'Informations de la boutique enregistrées !';

  @override
  String get profileLoadFailed => 'Impossible de charger ton profil.';

  @override
  String get startupLoadError =>
      'Impossible de charger l\'application. Vérifie ta connexion internet et réessaie.';

  @override
  String get retry => 'Réessayer';

  @override
  String get invoiceTitle => 'Facture';

  @override
  String get invoiceDate => 'Date';

  @override
  String get invoiceAddress => 'Adresse';

  @override
  String get sendInvoiceWhatsApp => 'Envoyer la facture par WhatsApp';

  @override
  String get openingWhatsApp => 'Ouverture de WhatsApp…';

  @override
  String get whatsAppShareFailed =>
      'Impossible d’ouvrir WhatsApp. Vérifie qu’il est installé puis réessaie.';

  @override
  String get emptyInvoiceCannotShare =>
      'Ajoute au moins un article avant de partager la facture.';

  @override
  String get clientWhatsAppNumber => 'Numéro WhatsApp du client';

  @override
  String get clientWhatsAppNumberHint => '+237 6 99 00 00 00';

  @override
  String get clientWhatsAppNumberHelp =>
      'Le numéro sert uniquement à ouvrir la conversation et ne sera pas enregistré.';

  @override
  String get clientPhoneNumberRequired => 'Saisis le numéro du client.';

  @override
  String get invalidWhatsAppNumber =>
      'Saisis un numéro valide avec son indicatif pays.';

  @override
  String get continueToWhatsApp => 'Continuer vers WhatsApp';
}
