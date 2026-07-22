import 'assignment_entity.dart';
import 'product_condition_entity.dart';
import 'participant_entity.dart';
import 'product_entity.dart';
import 'product_exclusion_entity.dart';
import 'generated_week_entity.dart';

/// Agregado raíz del dominio: participantes, productos configurables (con
/// sus condiciones y exclusiones), presencia diaria, asignaciones por
/// producto/periodo y semanas configuradas. Reemplaza el modelo v1 con
/// gaseosa/vasos hardcodeados por uno genérico: cualquier producto nuevo es
/// una fila de datos, no un caso especial en código.
class ShiftsStateEntity {
  final List<ParticipantEntity> participants;
  final List<ProductEntity> productos;

  /// Condición de cada producto; clave: `productoId`.
  final Map<String, ProductConditionEntity> condiciones;

  /// Asignaciones por producto y periodo. Clave externa: `productoId`.
  /// Clave interna: fecha ISO (productos diarios) o lunes ISO (semanales).
  final Map<String, Map<String, AssignmentEntity>> asignaciones;

  /// Presencia diaria, independiente del producto. Clave: fecha ISO.
  final Map<String, List<String>> presenciaPorDia;

  final List<ProductExclusionEntity> exclusiones;

  /// Semanas configuradas; clave: lunes ISO.
  final Map<String, GeneratedWeekEntity> semanas;

  const ShiftsStateEntity({
    this.participants = const [],
    this.productos = const [],
    this.condiciones = const {},
    this.asignaciones = const {},
    this.presenciaPorDia = const {},
    this.exclusiones = const [],
    this.semanas = const {},
  });

  /// Estado inicial cuando no hay nada guardado: los 8 participantes del
  /// grupo y los dos productos por defecto (gaseosa diaria, vasos
  /// semanales) que reproducen el comportamiento del MVP.
  factory ShiftsStateEntity.seed() {
    return ShiftsStateEntity(
      participants: const [
        ParticipantEntity(id: 'brayan-diaz', name: 'Brayan Díaz'),
        ParticipantEntity(id: 'brayan-valderrama', name: 'Brayan Valderrama'),
        ParticipantEntity(id: 'hector', name: 'Héctor'),
        ParticipantEntity(id: 'wilson', name: 'Wilson'),
        ParticipantEntity(id: 'pedro', name: 'Pedro'),
        ParticipantEntity(id: 'sebastian', name: 'Sebastián'),
        ParticipantEntity(id: 'walter', name: 'Walter'),
        ParticipantEntity(id: 'natalia', name: 'Natalia'),
      ],
      productos: seedProductos,
      condiciones: seedCondiciones,
      exclusiones: seedExclusiones,
    );
  }

  /// Productos por defecto: gaseosa (diaria) y vasos (semanal única), los
  /// mismos dos que el MVP tenía hardcodeados.
  static const List<ProductEntity> seedProductos = [
    ProductEntity(id: 'gaseosa', nombre: 'Gaseosa'),
    ProductEntity(id: 'vasos', nombre: 'Vasos'),
  ];

  static const Map<String, ProductConditionEntity> seedCondiciones = {
    'gaseosa': ProductConditionEntity(
      productoId: 'gaseosa',
      frecuencia: FrecuenciaProducto.diario,
      minPresentes: 4,
      costoCop: 7000,
      evitaRepetirPeriodoAnterior: true,
    ),
    'vasos': ProductConditionEntity(
      productoId: 'vasos',
      frecuencia: FrecuenciaProducto.semanalUnico,
      evitaRepetirPeriodoAnterior: true,
    ),
  };

  static const List<ProductExclusionEntity> seedExclusiones = [
    ProductExclusionEntity(productoA: 'gaseosa', productoB: 'vasos'),
  ];

  List<ParticipantEntity> get activeParticipants =>
      participants.where((p) => p.active).toList();

  List<String> get activeIds =>
      participants.where((p) => p.active).map((p) => p.id).toList();

  ParticipantEntity? participantById(String? id) {
    if (id == null) return null;
    for (final p in participants) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Nombre visible de un id (o el id si la persona fue eliminada).
  String nameOf(String? id) => participantById(id)?.name ?? (id ?? '—');

  ProductConditionEntity? condicionDe(String productoId) =>
      condiciones[productoId];

  AssignmentEntity? asignacionDe(String productoId, String periodoId) =>
      asignaciones[productoId]?[periodoId];

  GeneratedWeekEntity? semanaDe(String mondayIso) => semanas[mondayIso];

  List<String> presentesEn(String fechaIso) =>
      presenciaPorDia[fechaIso] ?? const [];

  ShiftsStateEntity copyWith({
    List<ParticipantEntity>? participants,
    List<ProductEntity>? productos,
    Map<String, ProductConditionEntity>? condiciones,
    Map<String, Map<String, AssignmentEntity>>? asignaciones,
    Map<String, List<String>>? presenciaPorDia,
    List<ProductExclusionEntity>? exclusiones,
    Map<String, GeneratedWeekEntity>? semanas,
  }) {
    return ShiftsStateEntity(
      participants: participants ?? this.participants,
      productos: productos ?? this.productos,
      condiciones: condiciones ?? this.condiciones,
      asignaciones: asignaciones ?? this.asignaciones,
      presenciaPorDia: presenciaPorDia ?? this.presenciaPorDia,
      exclusiones: exclusiones ?? this.exclusiones,
      semanas: semanas ?? this.semanas,
    );
  }
}
