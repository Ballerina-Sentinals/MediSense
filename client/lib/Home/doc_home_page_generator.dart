import 'package:client/Patient_Diary/working_days.dart';
import 'package:client/Resources/assets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../App/app.dart';
import 'package:provider/provider.dart';

class DocHomePageGenerator extends StatefulWidget {
  const DocHomePageGenerator({super.key});

  @override
  State<DocHomePageGenerator> createState() => _DocHomePageGeneratorState();
}

class _DocHomePageGeneratorState extends State<DocHomePageGenerator> {
  Map<dynamic, dynamic> patients = {};
  final date = DateTime.now().toString().substring(0, 10);
  Set<String> selectedPatients = <String>{};

  Future<void> fetchPatients(String userId, String date) async {
    print('fetchPatients function called with userId: $userId and date: $date');
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/doc_appoinment_booked/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> patientsList = json.decode(response.body);
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

  Future<void> updateAppointmentStatus(int appointmentId) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/appoinment_done/$appointmentId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Appointment status updated successfully');
    } else {
      throw Exception('Failed to update appointment status');
    }
  }

  @override
  void initState() {
    super.initState();
    var appState = context.read<MyAppState>();
    fetchPatients(appState.userId.toString(), date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'lib/Resources/images/DocHomeBG.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 60),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Welcome to MediSense ${context.read<MyAppState>().name}',
                      style: TextStyle(
                        color: Color.fromARGB(255, 36, 114, 113),
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  ImageCard(text_: "", image: "lib/Resources/images/doc1.jpg"),
                  DateCard(
                    date: DateTime.now(),
                    color: const Color.fromARGB(
                        255, 23, 113, 104), // Customize the color here
                  ),
                ],
              ),
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
                          'Patients for today',
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
                                      trailing: IconButton(
                                        icon: Icon(
                                            selectedPatients
                                                    .contains(patientName)
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: selectedPatients
                                                    .contains(patientName)
                                                ? Colors.green
                                                : Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            updateAppointmentStatus(
                                                patientDetails[
                                                    'appointment_id']);
                                            if (selectedPatients
                                                .contains(patientName)) {
                                              selectedPatients
                                                  .remove(patientName);
                                            } else {
                                              selectedPatients.add(patientName);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'No patients for today',
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
              const SizedBox(height: 40),
              CustomElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const DocAvailabilityGenerator()),
                    (Route<dynamic> route) => false,
                  );
                },
                buttonText: "Set working days",
                image: 'lib/Resources/images/docwork2.jpg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
