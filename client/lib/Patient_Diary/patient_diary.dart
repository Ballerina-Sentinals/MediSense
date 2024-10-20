import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/assets.dart';
import '../App/app.dart';

class PatientDiaryGenerator extends StatefulWidget {
  const PatientDiaryGenerator({super.key});

  @override
  State<PatientDiaryGenerator> createState() => _PatientDiaryGeneratorState();
}

class _PatientDiaryGeneratorState extends State<PatientDiaryGenerator> {
  Map<String, dynamic> appointments = {};
  Map<dynamic, dynamic> patients = {};
  //final date = DateTime.now().toString().substring(0, 10);
  String date = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchPatients(String userId, String date) async {
    print('fetchPatients function called with userId: $userId and date: $date');
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8080/doc_appoinment/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> patientsList = json.decode(response.body);
        patients.clear();
        print(patientsList);
        print("//////////////////////////////////////////////");
        for (var patient in patientsList) {
          patients[patient['name']] = {
            'number': patient['number'],
            'status': patient['status'],
            'appointment_id': patient['appointment_id'],
          };
        }

        print('Patients are $patients');
        print("//////////////////////////////////////////////");
      });
    } else {
      throw Exception('Failed to load patients');
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Image.asset(
          'lib/Resources/images/DocHomeBG.jpg',
          fit: BoxFit.cover,
          // height: 120,
        ),
        // BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //   child: Container(
        //     color: Colors.white.withOpacity(0.5),
        //   ),
        // ),
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

                  fetchPatients(appState.userId.toString(), formattedDate);
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
                          'Patient List for $date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: const Color.fromARGB(255, 36, 114, 113),
                          ),
                        ),
                      ),
                      patients.isNotEmpty
                          ? Flexible(
                              child: ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemCount: patients.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  String patientName =
                                      patients.keys.elementAt(index);
                                  Map<String, dynamic> patientDetails =
                                      patients[patientName];
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
                                        patientName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Number: ${patientDetails['number']}, Status: ${patientDetails['status']}',
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
