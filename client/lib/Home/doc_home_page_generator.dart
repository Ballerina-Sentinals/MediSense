// import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui';
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
  Map<String, dynamic> patients = {};
  final date = DateTime.now().toString().substring(0, 10);
  Set<String> selectedPatients = Set<String>();

  Future<void> fetchPatients(String userId, String date) async {
    print('fetchPatients function called with userId: $userId and date: $date');
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/patient-diary/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        patients = json.decode(response.body);
        print('Patients are $patients');
        print("//////////////////////////////////////////////");
      });
    } else {
      throw Exception('Failed to load patients');
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
      // appBar: AppBar(
      //   title: Text('Patient Diary'),
      // ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'lib/Resources/images/001_blueCapsules.jpg',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: const Color.fromARGB(255, 176, 230, 247)
                  .withOpacity(0.6), // Set opacity to 0.6
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Make the card shorter
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: Text(
                        'Patients for today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36.0,
                        ),
                      ),
                    ),
                  ),
                  patients.isNotEmpty
                      ? Flexible(
                          child: ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemCount: patients.length,
                            itemBuilder: (context, index) {
                              String patientName =
                                  patients.keys.elementAt(index);
                              Map<String, dynamic> patientDetails =
                                  patients[patientName];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 5.0),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(15.0),
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
                                        selectedPatients.contains(patientName)
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: selectedPatients
                                                .contains(patientName)
                                            ? Colors.green
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        if (selectedPatients
                                            .contains(patientName)) {
                                          selectedPatients.remove(patientName);
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
                              fontSize: 24.0,
                              color: const Color.fromARGB(255, 255, 132, 95),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
