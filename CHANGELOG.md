# Journal des modifications

Tous les changements notables de ce projet sont documentés dans ce fichier.

Le format suit les principes de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et ce projet adhère au [Versionnage Sémantique](https://semver.org/lang/fr/) (`pubspec.yaml` est actuellement à la version `1.0.0+1`). Aucun tag Git ne correspond encore à une version publiée : les entrées ci-dessous sont reconstituées à partir de l'historique des commits.

## [Non publié]

### Ajouté

- Connexion et inscription par e-mail/mot de passe, ainsi que connexion via Google (Firebase Auth). (`48cb771`, `c2fee14`)
- Saisie du nom de la boutique à l'inscription, appliqué automatiquement à la fiche boutique après authentification. (`c2fee14`)
- Comptes boutique synchronisés dans le cloud (Cloud Firestore) : chaque compte dispose de son propre catalogue produits et de sa propre fiche boutique, isolés par des règles de sécurité Firestore basées sur l'UID. (`7de8a9c`)
- Retour sonore (bip) et vibration à chaque code-barres scanné avec succès, sur l'écran d'accueil comme sur le scanner plein écran. (`08b4467`, `d87f9b1`)
- Personnalisation de la boutique et paiement mobile pour le marché camerounais : devise FCFA et génération d'un QR code de paiement Orange Money à la caisse. (`d7cccbb`, `9d008f3`)

### Modifié

- Bascule du stockage principal : la fiche boutique et le catalogue produits, auparavant persistés uniquement en local via Hive, sont désormais stockés dans Cloud Firestore ; Hive ne conserve plus que les réglages matériels locaux (imprimante Bluetooth appairée). (`7de8a9c`)
- Remplacement du package `flutter_vibrate` (obsolète) par `vibration` pour le retour haptique. (`ff62530`)
- Lecture du bip de scan rendue défensive et non bloquante : un échec de lecture audio n'interrompt jamais la détection du code-barres. (`bd74ef5`)
- Simplification du constructeur de `CacheFailure` via un paramètre `super` raccourci. (`de42d2d`)

### Corrigé

- Écran blanc au chargement de la version web : affichage d'un indicateur de chargement le temps de l'initialisation de Flutter. (`f58881b`)
- Initialisation Firebase fiabilisée sur le web via une nouvelle tentative automatique (jusqu'à 3 essais, délai progressif) pour contourner une condition de course connue au démarrage. (`f58881b`)
- Bip de scan manquant sur l'écran d'accueil (il n'était présent que sur le scanner plein écran). (`d87f9b1`)

## [1.0.0] - 2026-03-03

Version initiale : application de caisse (POS) hors-ligne pour petits commerces.

### Ajouté

- Architecture Clean Architecture organisée par fonctionnalité (`product`, `billing`, `settings`, `shop`), avec `flutter_bloc` pour la gestion d'état, `get_it` pour l'injection de dépendances, `go_router` pour la navigation et `fpdart` pour la gestion fonctionnelle des erreurs. (`3fef9ba`)
- Gestion du catalogue produits : ajout, modification, suppression et recherche par nom ou code-barres. (`3fef9ba`)
- Caisse rapide par scan de codes-barres (`mobile_scanner`), panier avec calcul du total. (`3fef9ba`)
- Impression de reçus sur imprimante thermique Bluetooth (`print_bluetooth_thermal`). (`3fef9ba`)
- Fiche boutique imprimée sur les reçus. (`3fef9ba`)
- Persistance locale hors-ligne via `hive`/`hive_flutter`, sans dépendance à une connexion internet. (`3fef9ba`)
- Documentation initiale du projet (README). (`f3951cb`, `c0972da`)
