# 🛒 Billing App — Application de caisse (POS) & facturation

[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.1.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State%20Management-flutter__bloc-4A90E2)](https://pub.dev/packages/flutter_bloc)
[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-6E44FF)](#architecture)
[![License](https://img.shields.io/badge/Licence-non%20sp%C3%A9cifi%C3%A9e-lightgrey)](#licence)

Application mobile de point de vente (POS) et de facturation construite avec Flutter, destinée aux petits commerces. Elle permet d'encaisser rapidement via un scan de code-barres, de gérer un catalogue produits, d'imprimer des reçus sur une imprimante thermique Bluetooth, et de générer un QR code de paiement Orange Money. Les données métier (boutique, catalogue) sont synchronisées dans le cloud via Firebase, avec un compte par boutique.

## Sommaire

- [Aperçu](#aperçu)
- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Architecture](#architecture)
- [Structure du projet](#structure-du-projet)
- [Modèle de données (Firebase)](#modèle-de-données-firebase)
- [Navigation](#navigation)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration Firebase](#configuration-firebase)
- [Lancer l'application](#lancer-lapplication)
- [Build de production](#build-de-production)
- [Permissions natives](#permissions-natives)
- [Tests](#tests)
- [Internationalisation](#internationalisation)
- [Limites connues et améliorations](#limites-connues-et-améliorations)
- [Contribuer](#contribuer)
- [Licence](#licence)
- [Journal des modifications](CHANGELOG.md)

## Aperçu

<https://github.com/user-attachments/assets/f2d16454-5408-43b3-b207-cd843bbc2c9e>

L'application cible les commerces de détail au Cameroun : devise en Francs CFA (FCFA), paiement mobile via Orange Money, interface partiellement en français. Chaque commerçant crée un « compte boutique » (Firebase Auth) et retrouve ses produits et paramètres depuis n'importe quel appareil connecté à ce compte.

## Fonctionnalités

- **Authentification boutique** — inscription par e-mail/mot de passe (avec nom de boutique) ou connexion Google (Firebase Auth).
- **Scan de codes-barres en continu** — scanner caméra intégré à l'écran d'accueil (`mobile_scanner`), avec retour sonore (bip) et vibration à chaque détection, et anti-doublon de 2 secondes par code.
- **Panier & caisse** — ajout au panier par scan, ajustement des quantités, calcul du total en temps réel.
- **Paiement Orange Money** — génération d'un QR code USSD (`tel:#150*11*<numéro>*<montant>#`) à partir du numéro Orange Money renseigné dans les paramètres de la boutique.
- **Impression de reçus Bluetooth** — connexion à une imprimante thermique (`print_bluetooth_thermal`), mise en page ESC/POS avec en-tête boutique, articles, total et pied de page personnalisés ; le dernier appareil appairé est mémorisé et reconnecté automatiquement.
- **Gestion du catalogue produits** — création, modification, suppression et recherche de produits (nom ou code-barres), scan pour préremplir le code-barres, détection des doublons.
- **Fiche boutique** — nom, adresse (2 lignes), téléphone, numéro Orange Money et texte de pied de reçu, imprimés/affichés dans l'app.
- **Paramètres & imprimante** — état de connexion de l'imprimante, nouvelle recherche d'appareils, accès rapide aux réglages Bluetooth du système, déconnexion du compte.

## Stack technique

| Domaine | Choix | Package(s) |
| --- | --- | --- |
| Framework | Flutter (Dart ≥ 3.1.0) | `flutter` |
| Gestion d'état | BLoC | `flutter_bloc`, `bloc`, `equatable` |
| Injection de dépendances | Service locator | `get_it` |
| Navigation | Déclarative | `go_router` |
| Programmation fonctionnelle | `Either<Failure, T>` | `fpdart` |
| Authentification | Cloud | `firebase_auth` |
| Base de données cloud | Documents | `cloud_firestore` |
| Stockage local (réglages matériels) | Clé/valeur | `hive`, `hive_flutter` |
| Scan de codes-barres | Caméra | `mobile_scanner` |
| Impression thermique | Bluetooth | `print_bluetooth_thermal` |
| QR code de paiement | Génération | `pretty_qr_code` |
| Retour utilisateur | Son / vibration | `audioplayers`, `vibration` |
| UI | Thème & typographie | `google_fonts`, `flutter_svg` |
| Divers | Identifiants, formats, permissions | `uuid`, `intl`, `permission_handler`, `app_settings` |

> `json_annotation`, `json_serializable`, `hive_generator` et `build_runner` sont déclarés dans `pubspec.yaml` mais aucun fichier `*.g.dart` n'est actuellement généré dans le projet : ce sont des reliquats de l'architecture initiale, entièrement locale (Hive), avant la bascule vers Firestore. Ils peuvent être retirés s'ils restent inutilisés.

## Architecture

Le projet suit une **Clean Architecture organisée par fonctionnalité** (*feature-first*). Chaque module de `lib/features/` est découpé en trois couches :

```text
feature/
├── domain/            # Règles métier, indépendantes de tout framework
│   ├── entities/       # Objets métier immuables (Equatable)
│   ├── repositories/    # Contrats abstraits (interfaces)
│   └── usecases/        # Une action métier = une classe
├── data/               # Implémentation technique
│   ├── models/          # (De)sérialisation vers/depuis Firestore
│   └── repositories/     # Implémentations concrètes des contrats domain
└── presentation/       # UI et état
    ├── bloc/             # Bloc + Event + State (fichiers `part of`)
    ├── pages/            # Écrans (Scaffold)
    └── widgets/          # Composants réutilisables à la feature
```

Principes appliqués :

- **Sens de dépendance unique** : `presentation → domain ← data`. Le domaine ne connaît ni Firebase, ni Bloc, ni Flutter.
- **États et évènements immuables**, via `Equatable`, pour des comparaisons fiables et des rebuilds BLoC prévisibles.
- **Gestion d'erreur fonctionnelle** : les repositories renvoient `Either<Failure, T>` (`fpdart`) plutôt que de lever des exceptions à travers les couches (voir `lib/core/error/failure.dart`).
- **Injection de dépendances centralisée** via `get_it` (`lib/core/service_locator.dart`, instance `sl`), initialisée dans `main()` puis fournie à l'arbre de widgets via `MultiBlocProvider` dans `MyApp`.

La fonctionnalité `billing` (panier, caisse, impression) fait exception : elle n'a pas de couche `data` propre et s'appuie directement sur le use case `GetProductByBarcodeUseCase` de la fonctionnalité `product`, ainsi que sur `core/utils/printer_helper.dart` et `core/data/hive_database.dart`.

### Cycle de vie applicatif

`lib/main.dart` exécute, dans l'ordre :

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp(...)` avec **jusqu'à 3 tentatives** (backoff progressif) pour contourner une condition de course connue sur le web au démarrage (`FirebaseCoreHostApi.initializeCore`).
3. `HiveDatabase.init()` — ouverture de la box locale `settings` (réglages matériels uniquement).
4. `di.init()` — enregistrement des dépendances `get_it`.
5. `runApp(const MyApp())`.

`MyApp` fournit `AuthBloc`, `ProductBloc`, `ShopBloc`, `BillingBloc` et `PrinterBloc` à l'ensemble de l'arbre, puis délègue l'affichage à `_AuthGate`, qui écoute `AuthBloc` :

| État `AuthBloc` | Écran affiché | Effets de bord |
| --- | --- | --- |
| `AuthInitial` / `AuthLoading` | Écran de chargement | — |
| `AuthAuthenticated` | `MaterialApp.router` (app complète, via `go_router`) | Charge produits et boutique ; si un nom de boutique a été saisi à l'inscription, l'enregistre immédiatement (`UpdateShopEvent`) |
| `AuthUnauthenticated` / `AuthError` | `AuthPage` (connexion / inscription) | Vide le catalogue et la fiche boutique en mémoire (`ClearProducts`, `ClearShopEvent`) pour éviter toute fuite de données entre comptes |

## Structure du projet

```text
lib/
├── main.dart                        # Point d'entrée, init Firebase/Hive/DI, AuthGate
├── firebase_options.dart            # Configuration Firebase générée (FlutterFire CLI)
├── config/
│   └── routes/app_routes.dart       # Table de routes go_router
├── core/
│   ├── data/hive_database.dart      # Ouverture de la box Hive locale "settings"
│   ├── error/failure.dart           # Failure, CacheFailure, AuthFailure
│   ├── theme/app_theme.dart         # Thème Material 3 (police IBM Plex Sans)
│   ├── usecase/usecase.dart         # Contrat UseCase<Result, Params>
│   ├── utils/
│   │   ├── app_validators.dart      # Validateurs de formulaires
│   │   └── printer_helper.dart      # Construction ESC/POS + pilotage imprimante Bluetooth
│   ├── widgets/                     # Boutons, champs et composants partagés
│   └── service_locator.dart         # Configuration get_it
└── features/
    ├── auth/           # Connexion / inscription (email+mot de passe, Google)
    ├── billing/         # Panier, scan, caisse, paiement, impression du reçu
    ├── product/          # Catalogue produits (CRUD + recherche + scan)
    ├── settings/          # Paramètres, gestion de l'imprimante
    └── shop/               # Fiche boutique (identité, adresse, Orange Money)
```

## Modèle de données (Firebase)

**Firebase Authentication** gère l'identité (e-mail/mot de passe et Google). L'UID authentifié sert de clé pour toutes les données métier dans **Cloud Firestore** :

```text
shops/{uid}                     # Document boutique (1 par compte)
  ├─ name, addressLine1, addressLine2
  ├─ phoneNumber, upiId (n° Orange Money)
  └─ footerText (pied de reçu)

shops/{uid}/products/{productId}  # Sous-collection catalogue
  ├─ id, name, barcode
  ├─ price, stock
```

Règles de sécurité (`firestore.rules`) : un utilisateur ne peut lire/écrire que le document `shops/{uid}` et la sous-collection `products` correspondant à son propre UID :

```js
match /shops/{uid} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
  match /products/{productId} {
    allow read, write: if request.auth != null && request.auth.uid == uid;
  }
}
```

Pour accélérer le scan en caisse, `getProductByBarcode` interroge d'abord le **cache local Firestore** (`Source.cache`) avant de retomber sur le réseau si le produit n'y est pas encore.

**Hive** (`lib/core/data/hive_database.dart`) n'est utilisé que pour une box générique `settings`, purement locale à l'appareil, stockant l'adresse MAC et le nom de la dernière imprimante Bluetooth appairée (`printer_mac`, `printer_name`). Les données boutique/produits ne transitent plus par Hive.

## Navigation

Routage déclaratif avec `go_router` (`initialLocation: '/'`) :

| Route | Écran | Description |
| --- | --- | --- |
| `/` | `HomePage` | Accueil : scanner caméra + panier |
| `/scanner` | `ScannerPage` | Scan plein écran, retourne le code lu à l'appelant |
| `/checkout` | `CheckoutPage` | Récapitulatif, QR Orange Money, impression du reçu |
| `/settings` | `SettingsPage` | Paramètres : imprimante, compte |
| `/products` | `ProductListPage` | Liste / recherche du catalogue |
| `/products/add` | `AddProductPage` | Ajout d'un produit |
| `/products/edit/:id` | `EditProductPage` | Édition d'un produit (reçu via `state.extra`) |
| `/shop` | `ShopDetailsPage` | Fiche boutique |

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.1.0 (Dart ≥ 3.1.0)
- Android Studio et/ou Xcode pour les émulateurs et la compilation native
- Un projet [Firebase](https://console.firebase.google.com/) (Auth + Firestore activés)
- *Optionnel* : un appareil physique et une imprimante thermique Bluetooth compatible ESC/POS pour tester l'impression

## Installation

```bash
# 1. Cloner le dépôt
git clone <url_du_dépôt>
cd billing_app

# 2. Installer les dépendances
flutter pub get

# 3. (Optionnel) Générer le code si des annotations json_serializable/hive sont ajoutées
dart run build_runner build --delete-conflicting-outputs

# 4. Lancer l'application
flutter run
```

> **Note (Windows)** : si le chemin du projet contient un caractère accentué (ex. `Terminé`), le plugin Gradle Android peut rejeter la compilation. Le fichier `android/gradle.properties` du dépôt ajoute `android.overridePathCheck=true` pour désactiver cette vérification ; les chemins non-ASCII fonctionnent normalement en pratique.

## Configuration Firebase

L'application est déjà reliée à un projet Firebase (`amad-shop-billing-2c68c`, voir `.firebaserc` et `lib/firebase_options.dart`). Pour connecter l'app à **votre propre** projet Firebase :

1. Créer un projet sur la [console Firebase](https://console.firebase.google.com/).
2. Activer **Authentication** (fournisseurs *E-mail/Mot de passe* et *Google*) et **Cloud Firestore**.
3. Installer la CLI FlutterFire puis régénérer la configuration :

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Cette commande régénère `lib/firebase_options.dart` et les fichiers natifs (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`).

4. Déployer les règles de sécurité fournies :

   ```bash
   firebase deploy --only firestore:rules
   ```

## Lancer l'application

```bash
flutter devices          # lister les cibles disponibles
flutter run               # Android / iOS / Web selon l'appareil sélectionné
flutter run -d chrome       # forcer le web
```

Plateformes actuellement générées dans le dépôt : **Android**, **iOS**, **Web**. Les dossiers `windows/`, `linux/` et `macos/` n'ont pas encore été générés ; utilisez `flutter create . --platforms=windows,linux,macos` si un support desktop est nécessaire.

## Build de production

```bash
flutter build apk --release          # Android (.apk)
flutter build appbundle --release      # Android (Play Store, .aab)
flutter build ios --release             # iOS (nécessite macOS + Xcode)
flutter build web --release              # Web
```

⚠️ **Signature Android** : `android/app/build.gradle.kts` signe actuellement le build `release` avec la **clé de debug** (`signingConfigs.getByName("debug")`), à des fins de développement. Avant toute publication, configurer un vrai *keystore* de release et mettre à jour `signingConfig`.

## Permissions natives

Déclarées dans `android/app/src/main/AndroidManifest.xml`, requises par le scanner caméra et l'imprimante Bluetooth :

| Permission | Utilisée pour |
| --- | --- |
| `CAMERA` | Scan des codes-barres (`mobile_scanner`) |
| `BLUETOOTH`, `BLUETOOTH_ADMIN` | Compatibilité versions Android < 12 |
| `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` | Recherche/connexion imprimante (Android 12+) |
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | Requis par le scan Bluetooth classique sur certaines versions d'Android |

## Tests

```bash
flutter test
```

⚠️ Le seul test présent (`test/widget_test.dart`) est le **test de démonstration par défaut** généré par `flutter create` (compteur incrémental) : il ne correspond plus à l'application actuelle et échouera s'il est exécuté. **Aucun test unitaire ou de widget réel** ne couvre à ce jour les blocs, repositories ou écrans — c'est la principale dette qualité du projet (voir [Limites connues](#limites-connues-et-améliorations)).

## Internationalisation

Il n'existe pas de système `flutter_localizations`/`intl` formel (pas de fichiers `.arb`, pas de `l10n.yaml`, pas de `localizationsDelegates`). Les textes sont **codés en dur**, avec un mélange :

- **Français** : écran d'authentification, fiche boutique, bouton Google.
- **Anglais** : accueil, catalogue, paramètres, caisse, scanner.
- **Devise fixe : FCFA** (Franc CFA), reflétant le marché ciblé (Cameroun), affichée partout sans conversion ni configuration.

## Limites connues et améliorations

- **Couverture de tests quasi nulle** — à combler en priorité (blocs, repositories, parcours critiques : scan → panier → impression).
- **Signature Android de développement** en configuration `release` — à remplacer avant publication.
- **Textes UI non uniformisés** (FR/EN mélangés) — à migrer vers un vrai système de traduction (`flutter_localizations` + fichiers `.arb`) si plusieurs langues doivent être supportées.
- **Dépendances de génération de code inutilisées** (`json_serializable`, `hive_generator`, `build_runner`) — à retirer si aucun modèle ne les utilise, ou à exploiter si l'équipe souhaite revenir à des `TypeAdapter` Hive typés.
- **Pas de support desktop généré** (Windows/Linux/macOS).

## Contribuer

1. **Respecter les frontières de la Clean Architecture** : `domain` ne doit dépendre ni de Flutter, ni de Firebase, ni de Bloc.
2. **États et évènements immuables**, via `Equatable`, pour chaque `Bloc`.
3. **Pas d'exception brute dans le domaine** : utiliser `Either<Failure, T>` (`fpdart`) pour propager les erreurs entre couches.
4. **Un use case = une responsabilité** : éviter de mélanger plusieurs actions métier dans une seule classe.
5. Avant toute pull request : `flutter analyze` et `flutter test` doivent passer sans erreur.

## Licence

Aucune licence n'est actuellement définie pour ce dépôt (`publish_to: 'none'` dans `pubspec.yaml`, pas de fichier `LICENSE`). Ajouter un fichier `LICENSE` à la racine du projet pour clarifier les conditions de réutilisation avant toute publication ou partage externe.
