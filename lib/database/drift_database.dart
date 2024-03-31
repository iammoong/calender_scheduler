import 'dart:io';

import 'package:calender_scheduler/model/category_color.dart';
import 'package:calender_scheduler/model/schedule.dart';
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
class LocalDatabase extends _$LocalDatabase{
  LocalDatabase() : super(_openConnection());
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