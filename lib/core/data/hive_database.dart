import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Generic box for simple device-local key-value data (e.g. paired
    // Bluetooth printer). Shop/product data now lives in Firestore.
    await Hive.openBox(settingsBoxName);
  }

  static Box get settingsBox => Hive.box(settingsBoxName);
}
