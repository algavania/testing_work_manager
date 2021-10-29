import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'simplePeriodicTask':
        SharedPreferences prefs = await SharedPreferences.getInstance();
        try {
          List<String> list = prefs.getStringList('key')!;
          list.add(DateTime.now().toString());
          print('Pressed ${list.toString()}.');
          await prefs.setStringList('key', list);
        } catch (e) {
          await prefs.setStringList('key', [DateTime.now().toString()]);
          List<String> list = prefs.getStringList('key')!;
          print('Pressed ${list.toString()}.');
        }
        break;
    }
    return Future.value(true);
  });
}

void main() {
  runApp(const MyApp());
}

void _sendSMS(String message, List<String> recipents) async {
  print('sending sms');
  String _result;
  try {
    _result = await sendSMS(message: message, recipients: recipents);
  } catch (e) {
    _result = e.toString();
  }
  print(_result);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String>? list = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Bar'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                Workmanager().initialize(
                    callbackDispatcher, // The top level function, aka callbackDispatcher
                    isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
                );
              }, child: const Text('Start Service')),
              const SizedBox(height: 5),
              ElevatedButton(
                child: const Text('Register Task'),
                onPressed: () {
                  Workmanager().registerPeriodicTask(
                    "1",
                    "simplePeriodicTask",
                    // When no frequency is provided the default 15 minutes is set.
                    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
                    frequency: const Duration(minutes: 15),
                  );
                },
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                child: const Text('Cancel Task'),
                onPressed: () async {
                  await Workmanager().cancelAll();
                },
              ),
              const SizedBox(height: 5),
              ElevatedButton(onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  list = prefs.getStringList('key');
                });
              }, child: const Text('Click to update')),
              Text(list.toString())
            ],
          ),
        ),
      ),
    );
  }
}

