import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/product_condition_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_exclusion_entity.dart';
import '../../domain/entities/generated_week_entity.dart';
import '../../domain/entities/shifts_state_entity.dart';
import 'participant_model.dart';

/// Estado completo serializado como un solo blob JSON (respaldo local
/// offline, ver docs/06-roadmap-supabase.md). Refleja 1:1 la forma genérica
/// de `ShiftsStateEntity`: participantes, productos configurables, sus
/// condiciones y exclusiones, presencia diaria, asignaciones por
/// producto/periodo y semanas configuradas.
class ShiftsStateModel {
  final List<ParticipantModel> participants;
  final List<ProductEntity> productos;
  final Map<String, ProductConditionEntity> condiciones;
  final Map<String, Map<String, AssignmentEntity>> asignaciones;
  final Map<String, List<String>> presenciaPorDia;
  final List<ProductExclusionEntity> exclusiones;
  final Map<String, GeneratedWeekEntity> semanas;

  const ShiftsStateModel({
    this.participants = const [],
    this.productos = const [],
    this.condiciones = const {},
    this.asignaciones = const {},
    this.presenciaPorDia = const {},
    this.exclusiones = const [],
    this.semanas = const {},
  });

  factory ShiftsStateModel.fromJson(Map<String, dynamic> json) {
    return ShiftsStateModel(
      participants: (json['participants'] as List? ?? const [])
          .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      productos: (json['productos'] as List? ?? const [])
          .map((e) => _productoFromJson(e as Map<String, dynamic>))
          .toList(),
      condiciones: (json['condiciones'] as Map<String, dynamic>? ?? const {})
          .map(
            (key, value) => MapEntry(
              key,
              _condicionFromJson(key, value as Map<String, dynamic>),
            ),
          ),
      asignaciones: (json['asignaciones'] as Map<String, dynamic>? ?? const {})
          .map(
            (productoId, porPeriodo) => MapEntry(
              productoId,
              (porPeriodo as Map<String, dynamic>).map(
                (periodoId, value) => MapEntry(
                  periodoId,
                  _asignacionFromJson(value as Map<String, dynamic>),
                ),
              ),
            ),
          ),
      presenciaPorDia:
          (json['presenciaPorDia'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(
              key,
              (value as List? ?? const []).map((e) => e.toString()).toList(),
            ),
          ),
      exclusiones: (json['exclusiones'] as List? ?? const [])
          .map((e) => _exclusionFromJson(e as Map<String, dynamic>))
          .toList(),
      semanas: (json['semanas'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) =>
            MapEntry(key, _semanaFromJson(key, value as Map<String, dynamic>)),
      ),
    );
  }

  factory ShiftsStateModel.fromEntity(ShiftsStateEntity entity) {
    return ShiftsStateModel(
      participants: entity.participants.map(ParticipantModel.fromEntity).toList(),
      productos: entity.productos,
      condiciones: entity.condiciones,
      asignaciones: entity.asignaciones,
      presenciaPorDia: entity.presenciaPorDia,
      exclusiones: entity.exclusiones,
      semanas: entity.semanas,
    );
  }

  Map<String, dynamic> toJson() => {
    'participants': participants.map((p) => p.toJson()).toList(),
    'productos': productos.map(_productoToJson).toList(),
    'condiciones': condiciones.map(
      (key, value) => MapEntry(key, _condicionToJson(value)),
    ),
    'asignaciones': asignaciones.map(
      (productoId, porPeriodo) => MapEntry(
        productoId,
        porPeriodo.map((periodoId, value) => MapEntry(periodoId, _asignacionToJson(value))),
      ),
    ),
    'presenciaPorDia': presenciaPorDia,
    'exclusiones': exclusiones.map(_exclusionToJson).toList(),
    'semanas': semanas.map((key, value) => MapEntry(key, _semanaToJson(value))),
  };

  ShiftsStateEntity toEntity() => ShiftsStateEntity(
    participants: participants.map((p) => p.toEntity()).toList(),
    productos: productos,
    condiciones: condiciones,
    asignaciones: asignaciones,
    presenciaPorDia: presenciaPorDia,
    exclusiones: exclusiones,
    semanas: semanas,
  );
}

ProductEntity _productoFromJson(Map<String, dynamic> json) => ProductEntity(
  id: json['id'].toString(),
  nombre: json['nombre']?.toString() ?? '',
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _productoToJson(ProductEntity p) => {
  'id': p.id,
  'nombre': p.nombre,
  'activo': p.activo,
};

ProductConditionEntity _condicionFromJson(
  String productoId,
  Map<String, dynamic> json,
) => ProductConditionEntity(
  productoId: productoId,
  frecuencia: FrecuenciaProducto.values.byName(
    json['frecuencia']?.toString() ?? 'diario',
  ),
  minPresentes: json['minPresentes'] as int? ?? 1,
  costoCop: json['costoCop'] as int?,
  evitaRepetirPeriodoAnterior:
      json['evitaRepetirPeriodoAnterior'] as bool? ?? false,
);

Map<String, dynamic> _condicionToJson(ProductConditionEntity c) => {
  'frecuencia': c.frecuencia.name,
  'minPresentes': c.minPresentes,
  'costoCop': c.costoCop,
  'evitaRepetirPeriodoAnterior': c.evitaRepetirPeriodoAnterior,
};

AssignmentEntity _asignacionFromJson(Map<String, dynamic> json) =>
    AssignmentEntity(
      participanteId: json['participanteId']?.toString(),
      locked: json['locked'] as bool? ?? false,
      warning: json['warning']?.toString(),
    );

Map<String, dynamic> _asignacionToJson(AssignmentEntity a) => {
  'participanteId': a.participanteId,
  'locked': a.locked,
  'warning': a.warning,
};

ProductExclusionEntity _exclusionFromJson(Map<String, dynamic> json) =>
    ProductExclusionEntity(
      productoA: json['productoA'].toString(),
      productoB: json['productoB'].toString(),
      alcance: ExclusionAlcance.values.byName(
        json['alcance']?.toString() ?? 'semana',
      ),
      dureza: ExclusionDureza.values.byName(
        json['dureza']?.toString() ?? 'dura',
      ),
    );

Map<String, dynamic> _exclusionToJson(ProductExclusionEntity e) => {
  'productoA': e.productoA,
  'productoB': e.productoB,
  'alcance': e.alcance.name,
  'dureza': e.dureza.name,
};

GeneratedWeekEntity _semanaFromJson(String monday, Map<String, dynamic> json) =>
    GeneratedWeekEntity(
      monday: monday,
      friday: json['friday']?.toString() ?? monday,
      estado: EstadoSemana.values.byName(
        json['estado']?.toString() ?? 'planificada',
      ),
      participantes: (json['participantes'] as List? ?? const [])
          .map(
            (e) => _semanaParticipanteFromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _semanaToJson(GeneratedWeekEntity s) => {
  'friday': s.friday,
  'estado': s.estado.name,
  'participantes': s.participantes.map(_semanaParticipanteToJson).toList(),
};

SemanaParticipanteEntity _semanaParticipanteFromJson(Map<String, dynamic> json) =>
    SemanaParticipanteEntity(
      participanteId: json['participanteId'].toString(),
      agregadoEn: json['agregadoEn'].toString(),
      retiradoEn: json['retiradoEn']?.toString(),
    );

Map<String, dynamic> _semanaParticipanteToJson(SemanaParticipanteEntity p) => {
  'participanteId': p.participanteId,
  'agregadoEn': p.agregadoEn,
  'retiradoEn': p.retiradoEn,
};
