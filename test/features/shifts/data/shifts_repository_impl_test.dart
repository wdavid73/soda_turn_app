import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/core/errors/failures.dart';
import 'package:turn_soda/features/shifts/data/datasources/shifts_local_datasource.dart';
import 'package:turn_soda/features/shifts/data/repositories/shifts_repository_impl.dart';
import 'package:turn_soda/features/shifts/domain/entities/shifts_state_entity.dart';

class FakeDatasource implements ShiftsLocalDatasource {
  String? stored;

  FakeDatasource([this.stored]);

  @override
  Future<String?> read() async => stored;

  @override
  Future<void> write(String raw) async => stored = raw;
}

void main() {
  test('load sin datos devuelve Right(null)', () async {
    final repo = ShiftsRepositoryImpl(FakeDatasource());
    final result = await repo.load();
    expect(result.isRight(), isTrue);
    result.fold((l) => fail('no debería fallar'), (r) => expect(r, isNull));
  });

  test('save y load recuperan el mismo estado', () async {
    final datasource = FakeDatasource();
    final repo = ShiftsRepositoryImpl(datasource);
    final state = ShiftsStateEntity.seed();

    final saved = await repo.save(state);
    expect(saved.isRight(), isTrue);

    final loaded = await repo.load();
    loaded.fold(
      (l) => fail('no debería fallar'),
      (r) => expect(r!.participants, state.participants),
    );
  });

  test('JSON corrupto devuelve CacheFailure', () async {
    final repo = ShiftsRepositoryImpl(FakeDatasource('esto no es json {'));
    final result = await repo.load();
    expect(result.isLeft(), isTrue);
    result.fold(
      (l) => expect(l, isA<CacheFailure>()),
      (r) => fail('debería fallar'),
    );
  });
}
