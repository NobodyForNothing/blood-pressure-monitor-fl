
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Instance of a medicine intake.
@Deprecated('use health_data_store')
class OldMedicineIntake implements Comparable<Object> {
  /// Create a intake from a String created by [serialize].
  ///
  /// [availableMeds] must contain the
  factory OldMedicineIntake.deserialize(
    String string,
    List<Medicine> availableMeds,
  ) {
    final elements = string.split('\x00');
    final storedMedicine = availableMeds
        .where((e) => e.id == int.parse(elements[0]));
    if (kDebugMode && storedMedicine.isEmpty) {
      throw ArgumentError('Medicine of intake $string not found.');
    }
    return OldMedicineIntake(
      medicine: storedMedicine.firstOrNull ?? Medicine(
        int.parse(elements[0]),
        designation: 'DELETED MEDICINE',
        color: Colors.red,
        defaultDosis: null,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(elements[1])),
      dosis: double.parse(elements[2]),
    );
  }

  /// Create a instance of a medicine intake.
  const OldMedicineIntake({
    required this.medicine,
    required this.dosis,
    required this.timestamp,
  });

  /// Serialize the object to a deserializable string.
  ///
  /// The string consists of the id of the medicine, the unix timestamp and the
  /// dosis. These values are seperated by a null byte
  /*String serialize() =>
      '${medicine.id}\x00${timestamp.millisecondsSinceEpoch}\x00$dosis';*/

  /// Kind of medicine taken.
  final Medicine medicine;

  /// Amount in mg of medicine taken.
  final double dosis;

  /// Time when the medicine was taken.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OldMedicineIntake &&
          runtimeType == other.runtimeType &&
          medicine == other.medicine &&
          dosis == other.dosis &&
          timestamp == other.timestamp;

  @override
  int get hashCode => medicine.hashCode ^ dosis.hashCode ^ timestamp.hashCode;

  @override
  int compareTo(Object other) {
    assert(other is OldMedicineIntake);
    if (other is! OldMedicineIntake) return 0;

    final timeCompare = timestamp.compareTo(other.timestamp);
    if (timeCompare != 0) return timeCompare;

    return dosis.compareTo(other.dosis);
  }

  @override
  String toString() => 'MedicineIntake{medicine: $medicine, dosis: $dosis, timestamp: $timestamp}';
}
