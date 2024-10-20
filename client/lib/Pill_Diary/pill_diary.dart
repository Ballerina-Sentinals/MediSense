import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/assets.dart';
import '../App/app.dart';

class PillDiaryGenerator extends StatefulWidget {
  const PillDiaryGenerator({super.key});

  @override
  State<PillDiaryGenerator> createState() => _PillDiaryGeneratorState();
}

class _PillDiaryGeneratorState extends State<PillDiaryGenerator> {
  Map<String, dynamic> pills = {};
  Map<int, dynamic> reminders = {};

  String date = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchReminders(String userId, String date) async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8080/view_reminder/$userId/$date'));

      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> reminderList = [];
          reminders.clear();
          reminderList = json.decode(response.body);
          print('Reminders are $reminderList');
          print("//////////////////////////////////////////////");

          for (var reminder in reminderList) {
            reminders[reminder['reminder_id']] = {
              'date': reminder['date'],
              'time': reminder['time'],
              'description': reminder['description'],
            };
          }
        });
      } else {
        print('Failed to load pill diary: ${response.statusCode}');
        throw Exception('Failed to load pill diary');
      }
    } catch (e) {
      print('Error fetching reminders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Image.asset(
          'lib/Resources/images/001_blueCapsules.jpg',
          fit: BoxFit.cover,
          // height: 120,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              CustomCalendar(
                onDaySelected: (selectedDay, focusedDay) {
                  String formattedDate =
                      selectedDay.toIso8601String().split('T')[0];
                  print(
                      'appState.userId.toString() is ${appState.userId.toString()}');
                  print('formatted Date is $formattedDate');
                  date = formattedDate;
                  fetchReminders(appState.userId.toString(), formattedDate);
                },
              ),
              const SizedBox(height: 60.0),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  color:
                      const Color.fromARGB(255, 176, 230, 247).withOpacity(0.6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Reminder List for $date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: const Color.fromARGB(255, 36, 114, 113),
                          ),
                        ),
                      ),
                      reminders.isNotEmpty
                          ? Flexible(
                              child: ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemCount: reminders.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  int reminderId =
                                      reminders.keys.elementAt(index);
                                  Map<String, dynamic> reminderDetails =
                                      reminders[reminderId];
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 5.0),
                                    padding: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        reminderDetails['date'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Time: ${reminderDetails['time']}, Description: ${reminderDetails['description']}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'No patients for $date',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color:
                                      const Color.fromARGB(255, 255, 132, 95),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
