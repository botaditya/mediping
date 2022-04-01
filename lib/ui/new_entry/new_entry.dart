import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mediping/bloc/global_bloc.dart';
import 'package:mediping/models/errors.dart';
import 'package:mediping/models/medicine.dart';
import 'package:mediping/ui/homepage/homepage.dart';
import 'package:mediping/ui/new_entry/new_entry_bloc.dart';
import 'package:mediping/ui/success_screen/success_screen.dart';
import 'package:mediping/utils/time_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NewEntry extends StatefulWidget {
  const NewEntry({Key? key}) : super(key: key);

  @override
  _NewEntryState createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NewEntryBloc _newEntryBloc;

  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dosageController.dispose();
    _newEntryBloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    _newEntryBloc = NewEntryBloc();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    initializeNotifications();
    initializeErrorListen();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        title: const Text(
          "Add New Mediping",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        elevation: 0.0,
      ),
      body: Provider<NewEntryBloc>.value(
        value: _newEntryBloc,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText: "Medicine Name",
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  )),
              controller: nameController,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: "Dosage in mg",
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  )),
              controller: dosageController,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 15,
            ),

            const PanelTitle(
              title: "Medicine Type",
              isRequired: false,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: StreamBuilder<MedicineType>(
                stream: _newEntryBloc.selectedMedicineType,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MedicineTypeColumn(
                          type: MedicineType.Bottle,
                          name: "Bottle",
                          iconValue: 0xe900,
                          isSelected: snapshot.data == MedicineType.Bottle
                              ? true
                              : false),
                      MedicineTypeColumn(
                          type: MedicineType.Pill,
                          name: "Pill",
                          iconValue: 0xe901,
                          isSelected: snapshot.data == MedicineType.Pill
                              ? true
                              : false),
                      MedicineTypeColumn(
                          type: MedicineType.Syringe,
                          name: "Syringe",
                          iconValue: 0xe902,
                          isSelected: snapshot.data == MedicineType.Syringe
                              ? true
                              : false),
                      MedicineTypeColumn(
                          type: MedicineType.Tablet,
                          name: "Tablet",
                          iconValue: 0xe903,
                          isSelected: snapshot.data == MedicineType.Tablet
                              ? true
                              : false),
                    ],
                  );
                },
              ),
            ),
            const PanelTitle(
              title: "Interval Selection",
              isRequired: true,
            ),
            //ScheduleCheckBoxes(),
            const IntervalSelection(),
            const PanelTitle(
              title: "Starting Time",
              isRequired: true,
            ),
            const SelectTime(),
            const SizedBox(
              height: 35,
            ),
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 4),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ))),
                  onPressed: () {
                    String medicineName = "";
                    int dosage = 0;
                    //--------------------Error Checking------------------------
                    //Had to do error checking in UI
                    //Due to unoptimized BLoC value-grabbing architecture
                    if (nameController.text == "") {
                      _newEntryBloc.submitError(EntryError.NameNull);
                      return;
                    }
                    if (nameController.text != "") {
                      medicineName = nameController.text;
                    }
                    if (dosageController.text == "") {
                      dosage = 0;
                    }
                    if (dosageController.text != "") {
                      dosage = int.parse(dosageController.text);
                    }
                    for (var medicine in _globalBloc.medicineList$.value) {
                      if (medicineName == medicine.medicineName) {
                        _newEntryBloc.submitError(EntryError.NameDuplicate);
                        return;
                      }
                    }
                    if (_newEntryBloc.selectedInterval$.value == 0) {
                      _newEntryBloc.submitError(EntryError.Interval);
                      return;
                    }
                    if (_newEntryBloc.selectedTimeOfDay$.value == "None") {
                      _newEntryBloc.submitError(EntryError.StartTime);
                      return;
                    }
                    //---------------------------------------------------------
                    String medicineType = _newEntryBloc
                        .selectedMedicineType.value
                        .toString()
                        .substring(13);
                    int interval = _newEntryBloc.selectedInterval$.value;
                    String startTime = _newEntryBloc.selectedTimeOfDay$.value;

                    List<int> intIDs =
                        makeIDs(24 / _newEntryBloc.selectedInterval$.value);
                    List<String> notificationIDs = intIDs
                        .map((i) => i.toString())
                        .toList(); //for Shared preference

                    Medicine newEntryMedicine = Medicine(
                      notificationIDs: notificationIDs,
                      medicineName: medicineName,
                      dosage: dosage,
                      medicineType: medicineType,
                      interval: interval,
                      startTime: startTime,
                    );

                    _globalBloc.updateMedicineList(newEntryMedicine);
                    scheduleNotification(newEntryMedicine);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const SuccessScreen();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
/*             Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height * 0.08,
                right: MediaQuery.of(context).size.height * 0.08,
              ),
              child: SizedBox(
                width: 250,
                height: 70,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(const StadiumBorder()),
                  ),
                  onPressed: () {
                    String medicineName = "";
                    int dosage = 0;
                    //--------------------Error Checking------------------------
                    //Had to do error checking in UI
                    //Due to unoptimized BLoC value-grabbing architecture
                    if (nameController.text == "") {
                      _newEntryBloc.submitError(EntryError.NameNull);
                      return;
                    }
                    if (nameController.text != "") {
                      medicineName = nameController.text;
                    }
                    if (dosageController.text == "") {
                      dosage = 0;
                    }
                    if (dosageController.text != "") {
                      dosage = int.parse(dosageController.text);
                    }
                    for (var medicine in _globalBloc.medicineList$.value) {
                      if (medicineName == medicine.medicineName) {
                        _newEntryBloc.submitError(EntryError.NameDuplicate);
                        return;
                      }
                    }
                    if (_newEntryBloc.selectedInterval$.value == 0) {
                      _newEntryBloc.submitError(EntryError.Interval);
                      return;
                    }
                    if (_newEntryBloc.selectedTimeOfDay$.value == "None") {
                      _newEntryBloc.submitError(EntryError.StartTime);
                      return;
                    }
                    //---------------------------------------------------------
                    String medicineType = _newEntryBloc
                        .selectedMedicineType.value
                        .toString()
                        .substring(13);
                    int interval = _newEntryBloc.selectedInterval$.value;
                    String startTime = _newEntryBloc.selectedTimeOfDay$.value;

                    List<int> intIDs =
                        makeIDs(24 / _newEntryBloc.selectedInterval$.value);
                    List<String> notificationIDs = intIDs
                        .map((i) => i.toString())
                        .toList(); //for Shared preference

                    Medicine newEntryMedicine = Medicine(
                      notificationIDs: notificationIDs,
                      medicineName: medicineName,
                      dosage: dosage,
                      medicineType: medicineType,
                      interval: interval,
                      startTime: startTime,
                    );

                    _globalBloc.updateMedicineList(newEntryMedicine);
                    scheduleNotification(newEntryMedicine);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const SuccessScreen();
                        },
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
 */
          ],
        ),
      ),
    );
  }

  void initializeErrorListen() {
    _newEntryBloc.errorState$.listen(
      (EntryError error) {
        switch (error) {
          case EntryError.NameNull:
            displayError("Please enter the medicine's name");
            break;
          case EntryError.NameDuplicate:
            displayError("Medicine name already exists");
            break;
          case EntryError.Dosage:
            displayError("Please enter the dosage required");
            break;
          case EntryError.Interval:
            displayError("Please select the reminder's interval");
            break;
          case EntryError.StartTime:
            displayError("Please select the reminder's starting time");
            break;
          default:
        }
      },
    );
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(error),
      duration: const Duration(milliseconds: 2000),
    ));
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String? payload) async {
    if (payload!.isNotEmpty) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> scheduleNotification(Medicine medicine) async {
    var hour = int.parse(medicine.startTime[0] + medicine.startTime[1]);
    var ogValue = hour;
    var minute = int.parse(medicine.startTime[2] + medicine.startTime[3]);
    tz.initializeTimeZones();

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      channelDescription: 'repeatDailyAtTime description',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notificationsound'),
      ledColor: Colors.blue,
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    for (int i = 0; i < (24 / medicine.interval).floor(); i++) {
      if ((hour + (medicine.interval * i) > 23)) {
        hour = hour + (medicine.interval * i) - 24;
      } else {
        hour = hour + (medicine.interval * i);
      }
      var dateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, hour, minute, 0);
      await flutterLocalNotificationsPlugin.zonedSchedule(
          int.parse(medicine.notificationIDs[i]),
          'Mediminder: ${medicine.medicineName}',
          medicine.medicineType.toString() != MedicineType.None.toString()
              ? 'It is time to take your ${medicine.medicineType.toLowerCase()}, according to schedule'
              : 'It is time to take your medicine, according to schedule',
          tz.TZDateTime.from(dateTime, tz.local),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time);
      hour = ogValue;
    }
    //await flutterLocalNotificationsPlugin.cancelAll();
  }
}

class IntervalSelection extends StatefulWidget {
  const IntervalSelection({Key? key}) : super(key: key);

  @override
  _IntervalSelectionState createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  final _intervals = [
    6,
    8,
    12,
    24,
  ];
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    final NewEntryBloc _newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Remind me every  ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            DropdownButton<int>(
              iconEnabledColor: Colors.blue,
              underline: Container(),
              hint: _selected == 0
                  ? const Text(
                      "Select an Interval (hrs)",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    )
                  : null,
              elevation: 4,
              value: _selected == 0 ? null : _selected,
              items: _intervals.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  _selected = newVal!;
                  _newEntryBloc.updateInterval(newVal);
                });
              },
            ),
            /*           Text(
              _selected == 1 ? " hour" : " hours",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ), */
          ],
        ),
      ),
    );
  }
}

class SelectTime extends StatefulWidget {
  const SelectTime({Key? key}) : super(key: key);

  @override
  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final NewEntryBloc _newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;
        _newEntryBloc.updateTime(convertTime(_time.hour.toString()) +
            convertTime(_time.minute.toString()));
      });
    }
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 4),
        child: OutlinedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              foregroundColor: MaterialStateProperty.all(Colors.blue),
              side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                final Color color = states.contains(MaterialState.pressed)
                    ? Colors.blue
                    : Colors.grey;
                return BorderSide(color: color, width: 2);
              }),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ))),
          onPressed: () {
            _selectTime(context);
          },
          child: Center(
            child: Text(
              _clicked == false
                  ? "Pick Time"
                  : "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())} ${_time.period.toString().replaceAll("DayPeriod.", "").toUpperCase()}",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MedicineTypeColumn extends StatelessWidget {
  final MedicineType type;
  final String name;
  final int iconValue;
  final bool isSelected;

  const MedicineTypeColumn(
      {Key? key,
      required this.type,
      required this.name,
      required this.iconValue,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NewEntryBloc _newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);
    return GestureDetector(
      onTap: () {
        _newEntryBloc.updateSelectedMedicine(type);
      },
      child: Column(
        children: <Widget>[
          Container(
            width: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Colors.blue : Colors.white,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Icon(
                  IconData(iconValue, fontFamily: "Ic"),
                  size: 75,
                  color: isSelected ? Colors.white : Colors.blue,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  final String title;
  final bool isRequired;
  const PanelTitle({
    Key? key,
    required this.title,
    required this.isRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text.rich(
        TextSpan(children: <TextSpan>[
          TextSpan(
            text: title,
            style: const TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: isRequired ? " *" : "",
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ]),
      ),
    );
  }
}
