import 'package:flutter/material.dart';
import 'package:client/Pill_Diary/add_reminder.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Resources/assets.dart';
import '../../App/app.dart'; // Import the working_days.dart file
import 'package:client/App/doc_home_page.dart';

class HomePageGenerator extends StatefulWidget {
  const HomePageGenerator({super.key});

  @override
  State<HomePageGenerator> createState() => _HomePageGeneratorState();
}

class _HomePageGeneratorState extends State<HomePageGenerator> {
  Map<String, dynamic> app = {};
  Map<int, dynamic> appointments = {};
  final date = DateTime.now().toString().substring(0, 10);
  final int userId = MyAppState().userId;

  @override
  void initState() {
    super.initState();
    fetchAppointments(userId.toString(), date);
  }

  Future<void> fetchAppointments(String userId, String date) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8080/view_appointments/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> appointmentList = json.decode(response.body);
        appointments.clear();
        print(appointmentList);
        print("//////////////////////////////////////////////");
        for (var appointment in appointmentList) {
          appointments[appointment['appointment_id']] = {
            'date': appointment['date'],
            'doctor': appointment['doc_name'],
            'number': appointment['number']
          };
        }
        print('Appointments are $appointments');
      });
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<void> addReminder(
      int userId, String date, String time, String description) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/add_reminder'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'date': date,
        'time': time,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      print('Reminder added successfully');
    } else {
      throw Exception('Failed to add reminder');
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
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
        Column(children: [
          Row(
            children: [
              const SizedBox(width: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Welcome ${context.read<MyAppState>().name}',
                  softWrap: true,
                  style: TextStyle(
                    color: Color.fromARGB(255, 36, 114, 113),
                    fontFamily: 'Montserrat',
                    fontSize: 28,
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
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 165, 210, 233)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Title(
                                color: Colors.black,
                                child: Center(
                                    child: Text('Appointments for Today',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Color.fromARGB(135, 7, 65, 60),
                                          fontWeight: FontWeight.bold,
                                        )))),
                            const SizedBox(height: 16.0),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: appointments.length,
                              itemBuilder: (context, index) {
                                int appointmentId =
                                    appointments.keys.elementAt(index);
                                Map<String, dynamic> appointmentDetails =
                                    appointments[appointmentId];

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
                                      leading: Icon(Icons.medical_services),
                                      title: Text(
                                          "Doctor: ${appointmentDetails['doctor']}"),
                                      subtitle: Text(
                                          "Appointment number: ${appointmentDetails['number'].toString()}"),
                                    ));
                              },
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                          onPressed: () {
                            fetchAppointments(appState.userId.toString(), date);
                          },
                          label: Text("Show Appointments"),
                          icon: Icon(Icons.refresh)),
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReminderPage(
                                  userId: appState.userId,
                                  addReminder: addReminder,
                                ),
                              ),
                            );
                          },
                          label: Text("Add Reminder"),
                          icon: Icon(Icons.add_alarm)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ],
    ));
  }
}



// class AddReminderWidget extends StatefulWidget {
//   final String userId;
//   final Future<void> Function(String, String, String, String) addReminder;

//   AddReminderWidget({required this.userId, required this.addReminder});

//   @override
//   _AddReminderWidgetState createState() => _AddReminderWidgetState();
// }

// class _AddReminderWidgetState extends State<AddReminderWidget> {
//   final _formKey = GlobalKey<FormState>();
//   final _descriptionController = TextEditingController();
//   String selectedDate = '';
//   TimeOfDay? selectedTime;

//   Future<void> selectTime(BuildContext context, bool isStartTime) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Add Reminder'),
//       content: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomCalendar(
//               onDaySelected: (selectedDay, focusedDay) {
//                 String formattedDate =
//                     selectedDay.toIso8601String().split('T')[0];
//                 setState(() {
//                   selectedDate = formattedDate;
//                 });
//               },
//             ),
//             const SizedBox(height: 20.0),
//             Row(
//               children: [
//                 Text('Time:'),
//                 const SizedBox(width: 10.0),
//                 ElevatedButton(
//                   onPressed: () => selectTime(context, true),
//                   child: Text(selectedTime?.format(context) ?? 'Select Time'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             TextFormField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: 'Description'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a description';
//                 }
//                 return null;
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               widget.addReminder(
//                 widget.userId,
//                 selectedDate,
//                 selectedTime?.format(context) ?? '',
//                 _descriptionController.text,
//               );
//               Navigator.of(context).pop();
//             }
//           },
//           child: Text('Add'),
//         ),
//       ],
//     );
//   }
//}
