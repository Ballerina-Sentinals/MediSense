import 'package:flutter/material.dart';
import '../Resources/assets.dart';
import 'dart:ui';

class AddReminderPage extends StatelessWidget {
  final int userId;
  final Future<void> Function(int, String, String, String) addReminder;

  const AddReminderPage({super.key, required this.userId, required this.addReminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 147, 136),
        elevation: 1.0,
        shadowColor: Colors.grey.shade400, // Set the shadow color
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Add Reminder',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
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
          AddReminderWidget(
            userId: userId,
            addReminder: addReminder,
          ),
        ],
      ),
    );
  }
}

class AddReminderWidget extends StatefulWidget {
  final int userId;
  final Future<void> Function(int, String, String, String) addReminder;

  const AddReminderWidget({super.key, required this.userId, required this.addReminder});

  @override
  _AddReminderWidgetState createState() => _AddReminderWidgetState();
}

class _AddReminderWidgetState extends State<AddReminderWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String selectedDate = '';
  TimeOfDay? selectedTime;

  Future<void> selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCalendar(
              onDaySelected: (selectedDay, focusedDay) {
                String formattedDate =
                    selectedDay.toIso8601String().split('T')[0];
                setState(() {
                  selectedDate = formattedDate;
                });
              },
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Text('Time:'),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () => selectTime(context, true),
                  child: Text(selectedTime?.format(context) ?? 'Select Time'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.addReminder(
                        widget.userId,
                        selectedDate,
                        selectedTime?.format(context) ?? '',
                        _descriptionController.text,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
