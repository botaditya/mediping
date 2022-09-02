import 'package:flutter/material.dart';
import 'package:mediping/bloc/global_bloc.dart';
import 'package:mediping/models/medicine.dart';
import 'package:mediping/ui/medicine_details/medicine_details.dart';
import 'package:mediping/ui/new_entry/new_entry.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.5,
        title: const Text(
          "Mediping",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        children: const <Widget>[TopContainer(), Divider(), BottomContainer()],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewEntry(),
            ),
          );
        },
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    var reminderCount = globalBloc.medipingCount.toString();
    return Card(
        child: ListTile(
            minVerticalPadding: 25,
            title: const Text(
              "Mediping added",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            trailing: Container(
              height: 75,
              width: 75,
              decoration: const BoxDecoration(
                  color: Color(0xCFCFCFCF),
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Center(
                child: Text(reminderCount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 25,
                      color: Color.fromARGB(255, 37, 37, 37),
                    )),
              ),
            )));
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return StreamBuilder<List<Medicine>>(
      stream: _globalBloc.medicineList$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.data!.isEmpty) {
          return Container(
            color: const Color(0xFFF6F8FC),
            child: const Center(
              child: Text(
                "Press + to add a Mediminder",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFFC9C9C9),
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        } else {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return MedicineCard(snapshot.data![index]);
              });
        }
      },
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  MedicineCard(this.medicine, {Key? key}) : super(key: key);

  late Icon medicineIcon;

  void makeIcon(double size) {
    if (medicine.medicineType == "Bottle") {
      medicineIcon = Icon(
        const IconData(0xe900, fontFamily: "Ic"),
        color: Colors.blue,
        size: size,
      );
    } else if (medicine.medicineType == "Pill") {
      medicineIcon = Icon(
        const IconData(0xe901, fontFamily: "Ic"),
        color: Colors.blue,
        size: size,
      );
    } else if (medicine.medicineType == "Syringe") {
      medicineIcon = Icon(
        const IconData(0xe902, fontFamily: "Ic"),
        color: Colors.blue,
        size: size,
      );
    } else if (medicine.medicineType == "Tablet") {
      medicineIcon = Icon(
        const IconData(0xe903, fontFamily: "Ic"),
        color: Colors.blue,
        size: size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    makeIcon(32);
    return Card(
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: medicineIcon,
        ),
        style: ListTileStyle.list,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        horizontalTitleGap: 8,
        title: Text(
          medicine.medicineName,
          style: const TextStyle(
              fontSize: 22, color: Colors.blue, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          medicine.medicineType,
          style: const TextStyle(
              fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 32.0,
          semanticLabel: "View medicine reminder",
        ),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Opacity(
                          opacity: animation.value,
                          child: MedicineDetails(medicine));
                    });
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
      ),
    );
  }
}
