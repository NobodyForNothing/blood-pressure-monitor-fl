import 'package:health_data_store/health_data_store.dart';
import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:health_data_store/src/repositories/repository.dart';
import 'package:sqflite_common/sqflite.dart';

/// Repository for [BloodPressureRecord]s.
/// 
/// Provides high level access on [BloodPressureRecord]s saved in a 
/// [DatabaseManager] managed database. Allows to store and query records.
class BloodPressureRepository extends Repository<BloodPressureRecord> {
  /// Create [BloodPressureRecord] repository.
  BloodPressureRepository(this._db);

  /// The [DatabaseManager] managed database
  final Database _db;
  
  @override
  Future<void> add(BloodPressureRecord record) async{
    assert(record.sys != null || record.dia != null || record.pul != null,
     "Adding records that don't contain values(sys,dia,pul) can't be accessed"
     'and should therefore not be added to the repository.');
    final timeSec = record.time.secondsSinceEpoch;
    await _db.transaction((txn) async {
      final entryID = await DBHelper.getEntryID(
        txn,
        timeSec,
        ['Systolic', 'Diastolic', 'Pulse'],
      );
      if (record.sys != null) {
        await txn.insert('Systolic', {
          'entryID': entryID,
          'sys': record.sys,
        });
      }
      if (record.dia != null) {
        await txn.insert('Diastolic', {
          'entryID': entryID,
          'dia': record.dia,
        });
      }
      if (record.pul != null) {
        await txn.insert('Pulse', {
          'entryID': entryID,
          'pul': record.pul,
        });
      }
    });
  }

  @override
  Future<List<BloodPressureRecord>> get(DateRange range) async {
    final results = await _db.rawQuery(
      'SELECT timestampUnixS, sys, dia, pul '
        'FROM Timestamps AS t '
        'LEFT JOIN Systolic AS s ON t.entryID = s.entryID '
        'LEFT JOIN Diastolic AS d ON t.entryID = d.entryID '
        'LEFT JOIN Pulse AS p ON t.entryID = p.entryID '
      'WHERE timestampUnixS BETWEEN ? AND ?',
      [range.startStamp, range.endStamp]
    );
    final records = <BloodPressureRecord>[];
    for (final r in results) {
      final timeS = r['timestampUnixS'] as int;
      final newRec = BloodPressureRecord(
        time: DateTimeS.fromSecondsSinceEpoch(timeS),
        sys: r['sys'] as int?,
        dia: r['dia'] as int?,
        pul: r['pul'] as int?,
      );
      if (newRec.sys !=null || newRec.dia != null || newRec.pul != null) {
        records.add(newRec);
      }
    }

    return records;
  }

  @override
  Future<void> remove(BloodPressureRecord value) async {
    await _db.transaction((txn) async {
      String query = 'SELECT t.entryID FROM Timestamps AS t ';
      if (value.sys != null)
        query += 'LEFT JOIN Systolic AS s ON t.entryID = s.entryID ';
      if (value.dia != null)
        query += 'LEFT JOIN Diastolic AS d ON t.entryID = d.entryID ';
      if (value.pul != null)
        query += 'LEFT JOIN Pulse AS p ON t.entryID = p.entryID ';
      query += 'WHERE timestampUnixS = ? ';
      if (value.sys != null)
        query += 'AND sys = ? ';
      if (value.dia != null)
        query += 'AND dia = ? ';
      if (value.pul != null)
        query += 'AND pul = ? ';

      final entryResult = await txn.rawQuery(query, [
        value.time.secondsSinceEpoch,
        if (value.sys != null)
          value.sys,
        if (value.dia != null)
          value.dia,
        if (value.pul != null)
          value.pul,
      ]);
      if (entryResult.isEmpty) return;
      final entryID = entryResult.first['entryID'];
      if (value.sys != null)
        await txn.delete('Systolic', where: 'entryID = ?', whereArgs:[entryID]);
      if (value.dia != null)
        await txn.delete('Diastolic', where:'entryID = ?', whereArgs:[entryID]);
      if (value.pul != null)
        await txn.delete('Pulse', where: 'entryID = ?', whereArgs: [entryID]);
    });
    // TODO: implement central cleanup of unused timestamp entries (by no table)
  }

}