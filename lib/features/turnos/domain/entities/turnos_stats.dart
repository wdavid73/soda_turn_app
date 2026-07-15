import '../../../../core/constants/app_constants.dart';

/// Conteos históricos por persona: días de gaseosa y semanas de vasos.
class TurnosStats {
  final Map<String, int> gaseosaCount;
  final Map<String, int> vasosCount;

  const TurnosStats({this.gaseosaCount = const {}, this.vasosCount = const {}});

  int gaseosaOf(String id) => gaseosaCount[id] ?? 0;

  int vasosOf(String id) => vasosCount[id] ?? 0;

  int totalOf(String id) => gaseosaOf(id) + vasosOf(id);

  /// Gasto aproximado de una persona (solo gaseosa, regla 9).
  int gastoCopOf(String id) => gaseosaOf(id) * AppConstants.costGaseosaCop;

  int get totalGaseosaDays => gaseosaCount.values.fold(0, (sum, v) => sum + v);

  int get totalVasosWeeks => vasosCount.values.fold(0, (sum, v) => sum + v);

  int get totalGastoCop => totalGaseosaDays * AppConstants.costGaseosaCop;
}
