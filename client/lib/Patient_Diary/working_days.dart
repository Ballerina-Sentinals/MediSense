import 'package:client/App/doc_home_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Resources/assets.dart';
import '../App/app.dart';

class DocAvailabilityGenerator extends StatefulWidget {
  const DocAvailabilityGenerator({super.key});

  @override
  State<DocAvailabilityGenerator> createState() => _DocAvailabilityGenerator();
}

class _DocAvailabilityGenerator extends State<DocAvailabilityGenerator> {
  Map<String, dynamic> availability = {};
  String selectedDate = '';
  bool isAvailable = false;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchWorkingDays(String userId, String date) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/doctor-availability/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        availability = json.decode(response.body);
        isAvailable = availability['isAvailable'] ?? false;
        startTime = availability['startTime'] != null
            ? TimeOfDay(
                hour: int.parse(availability['startTime'].split(':')[0]),
                minute: int.parse(availability['startTime'].split(':')[1]))
            : null;
        endTime = availability['endTime'] != null
            ? TimeOfDay(
                hour: int.parse(availability['endTime'].split(':')[0]),
                minute: int.parse(availability['endTime'].split(':')[1]))
            : null;
        selectedDate = date;
      });
    } else {
      setState(() {
        availability = {};
        isAvailable = false;
        startTime = null;
        endTime = null;
        selectedDate = date;
      });
    }
  }

  Future<void> updateAvailability(String userId, String date) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/doctor-availability/$userId/$date'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'isAvailable': isAvailable,
        'startTime': startTime?.format(context),
        'endTime': endTime?.format(context),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update availability');
    }
  }

  Future<void> selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? startTime ?? TimeOfDay.now()
          : endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule',
            style: TextStyle(color: const Color.fromARGB(255, 193, 243, 240))),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 63, 135, 131),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.replace(context,
                oldRoute: ModalRoute.of(context)!,
                newRoute:
                    MaterialPageRoute(builder: (context) => DocHomePage()));
          },
        ),
      ),
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Image.asset(
          'lib/Resources/images/DocHomeBG.jpg',
          fit: BoxFit.cover,
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
                  fetchWorkingDays(appState.userId.toString(), formattedDate);
                },
              ),
              const SizedBox(height: 80.0),
              // if (selectedDate.isNotEmpty)

              Card(
                color: Color.fromARGB(255, 190, 235, 233).withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Availability for $selectedDate',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 18, 110, 110)),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Text('Available:'),
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (isAvailable) ...[
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Text('Start Time:'),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () => selectTime(context, true),
                              child: Text(
                                  startTime?.format(context) ?? 'Select Time'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Text('End Time:'),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () => selectTime(context, false),
                              child: Text(
                                  endTime?.format(context) ?? 'Select Time'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: () {
                          updateAvailability(
                              appState.userId.toString(), selectedDate);
                        },
                        child: Text('Save'),
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
