import 'dart:io';

import 'package:calender_scheduler/model/category_color.dart';
import 'package:calender_scheduler/model/schedule.dart';
import 'package:calender_scheduler/model/schedule_with_color.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// private 값까지 불러올 수 있다.
part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)
// 상속에 _$만 만들면 데이터베이스를 만들어서 사용할 수 있음.
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  // Id로 스케줄러 조회
  Future<Schedule> getScheduleById(int id) =>
      (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle();

  // 스케줄러 생성
  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  // 색깔 insert
  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);
  
  // 색깔 가져오기
  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();
  
  // 스케줄러 업데이트 쿼리
  Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  // 스케줄 삭제 쿼리
  Future<int> removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  // join문을 활용하여 색깔과 스케줄 내용들을 리스트로 가지고 온다
  Stream<List<ScheduleWithColor>> watchSchedule(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);

    query.where(schedules.date.equals(date));

    query.orderBy([
      OrderingTerm.asc(schedules.startTime),
    ]);

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduleWithColor(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
              )
              .toList(),
        );

    //return (select(schedules)..where((tbl) => tbl.date.equals(date))).watch();
  }

  /*final query = select(schedules);
    query.where((tbl) => tbl.date.equals(date));
    return query.watch();*/

  // 데이터베이스 설정한 상태 버전
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, 'db.sqlite'),
    );
    return NativeDatabase(file);
  });
}
