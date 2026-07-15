import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Fuente local del estado serializado (JSON crudo).
abstract class TurnosLocalDatasource {
  Future<String?> read();

  Future<void> write(String raw);
}

class TurnosLocalDatasourceImpl implements TurnosLocalDatasource {
  final SharedPreferences prefs;

  const TurnosLocalDatasourceImpl(this.prefs);

  @override
  Future<String?> read() async => prefs.getString(AppConstants.storageKey);

  @override
  Future<void> write(String raw) async {
    await prefs.setString(AppConstants.storageKey, raw);
  }
}
