import 'package:flutter/material.dart';
import 'package:mediping/bloc/global_bloc.dart';
import 'package:mediping/ui/homepage/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MedipingApp());
}

class MedipingApp extends StatefulWidget {
  const MedipingApp({Key? key}) : super(key: key);

  @override
  _MedipingAppState createState() => _MedipingAppState();
}

class _MedipingAppState extends State<MedipingApp> {
  late GlobalBloc globalBloc;

  @override
  void initState() {
    globalBloc = GlobalBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>.value(
      value: globalBloc,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
