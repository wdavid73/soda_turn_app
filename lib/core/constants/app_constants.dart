/// Constantes de negocio y almacenamiento de SodaTurn.
class AppConstants {
  AppConstants._();

  /// Costo aproximado de la gaseosa por día asignado (COP).
  static const int costGaseosaCop = 7000;

  /// Mínimo de presentes para asignar la gaseosa de un día (regla 1).
  static const int minPresentes = 4;

  /// Clave de almacenamiento local, compatible con el respaldo de la web v2.
  static const String storageKey = 'almuerzo-turnos-v2';
}
