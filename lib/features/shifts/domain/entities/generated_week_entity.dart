/// Estado de una semana configurada. Deriva de comparar la fecha de hoy
/// contra `monday`/`friday` (ver `WeekStateService`); nunca se genera nada
/// hacia el futuro.
enum EstadoSemana {
  /// Hoy es anterior al lunes: se puede configurar (rango + participantes)
  /// pero "Generar" no hace nada todavía.
  planificada,

  /// Lunes ≤ hoy ≤ último día generable de la semana: "Generar" calcula
  /// los días generables pendientes hasta hoy (nunca futuros).
  enCurso,

  /// Hoy ya pasó el último día generable: solo edición manual (regla 8);
  /// dispara la materialización del histórico.
  completada,
}

/// Participante configurado para una semana concreta. Puede unirse o
/// retirarse durante la semana; los rangos acotan su ventana de
/// elegibilidad para el balance semanal (ver regla 5b).
class SemanaParticipanteEntity {
  final String participanteId;

  /// Fecha ISO desde la que participa en esta semana.
  final String agregadoEn;

  /// Fecha ISO desde la que deja de participar (null = sigue activo).
  final String? retiradoEn;

  const SemanaParticipanteEntity({
    required this.participanteId,
    required this.agregadoEn,
    this.retiradoEn,
  });

  /// `true` si esta persona cuenta como participante de la semana en
  /// [fechaIso] (ya se unió y aún no se ha retirado).
  bool elegibleEn(String fechaIso) {
    if (fechaIso.compareTo(agregadoEn) < 0) return false;
    if (retiradoEn != null && fechaIso.compareTo(retiradoEn!) >= 0) {
      return false;
    }
    return true;
  }

  SemanaParticipanteEntity copyWith({
    String? participanteId,
    String? agregadoEn,
    Object? retiradoEn = _unset,
  }) {
    return SemanaParticipanteEntity(
      participanteId: participanteId ?? this.participanteId,
      agregadoEn: agregadoEn ?? this.agregadoEn,
      retiradoEn: identical(retiradoEn, _unset)
          ? this.retiradoEn
          : retiradoEn as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanaParticipanteEntity &&
          other.participanteId == participanteId &&
          other.agregadoEn == agregadoEn &&
          other.retiradoEn == retiradoEn;

  @override
  int get hashCode => Object.hash(participanteId, agregadoEn, retiradoEn);
}

const Object _unset = Object();

/// Semana configurada: rango de fechas, estado y quiénes participan.
class GeneratedWeekEntity {
  /// Lunes ISO de la semana (clave natural).
  final String monday;

  /// Viernes ISO de la semana (rango calendario; el último día *generable*
  /// puede ser antes si el viernes es festivo).
  final String friday;

  final EstadoSemana estado;
  final List<SemanaParticipanteEntity> participantes;

  const GeneratedWeekEntity({
    required this.monday,
    required this.friday,
    this.estado = EstadoSemana.planificada,
    this.participantes = const [],
  });

  /// Ids elegibles en [fechaIso] (ya se unieron y no se han retirado).
  List<String> participantesElegiblesEn(String fechaIso) => [
    for (final p in participantes)
      if (p.elegibleEn(fechaIso)) p.participanteId,
  ];

  GeneratedWeekEntity copyWith({
    String? monday,
    String? friday,
    EstadoSemana? estado,
    List<SemanaParticipanteEntity>? participantes,
  }) {
    return GeneratedWeekEntity(
      monday: monday ?? this.monday,
      friday: friday ?? this.friday,
      estado: estado ?? this.estado,
      participantes: participantes ?? this.participantes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedWeekEntity &&
          other.monday == monday &&
          other.friday == friday &&
          other.estado == estado &&
          _listEquals(other.participantes, participantes);

  @override
  int get hashCode =>
      Object.hash(monday, friday, estado, Object.hashAll(participantes));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
