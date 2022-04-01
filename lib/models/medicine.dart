// ignore_for_file: constant_identifier_names

class Medicine {
  final List<dynamic> notificationIDs;
  final String medicineName;
  final int dosage;
  final String medicineType;
  final int interval;
  final String startTime;

  Medicine({
    required this.notificationIDs,
    required this.medicineName,
    required this.dosage,
    required this.medicineType,
    required this.startTime,
    required this.interval,
  });

  String get getName => medicineName;
  int get getDosage => dosage;
  String get getType => medicineType;
  int get getInterval => interval;
  String get getStartTime => startTime;
  List<dynamic> get getIDs => notificationIDs;

  Map<String, dynamic> toJson() {
    return {
      "ids": notificationIDs,
      "name": medicineName,
      "dosage": dosage,
      "type": medicineType,
      "interval": interval,
      "start": startTime,
    };
  }

  factory Medicine.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Medicine(
      notificationIDs: parsedJson['ids'],
      medicineName: parsedJson['name'],
      dosage: parsedJson['dosage'],
      medicineType: parsedJson['type'],
      interval: parsedJson['interval'],
      startTime: parsedJson['start'],
    );
  }
}

enum MedicineType {
  Bottle,
  Pill,
  Syringe,
  Tablet,
  None,
}
