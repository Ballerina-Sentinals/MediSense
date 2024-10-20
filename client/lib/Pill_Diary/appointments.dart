import 'package:flutter/material.dart';

class AppointmentsPageGenerator extends StatefulWidget {
  const AppointmentsPageGenerator({super.key});

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsPageGenerator> {
  final _formKey = GlobalKey<FormState>();
  String _date = '';
  String _location = '';
  List<String> _doctors = [];

  void _fetchDoctors() {
    // Mock fetching doctors based on date and location
    setState(() {
      _doctors = ['Dr. Smith', 'Dr. Johnson', 'Dr. Williams'];
    });
  }

  void _navigateToAppointment(String doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentPage(doctor: doctor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 147, 136),
        elevation: 1.0,
        shadowColor: Colors.grey.shade400,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text('DocLocator',
            style: TextStyle(color: Color.fromARGB(255, 194, 238, 238))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date'),
                onSaved: (value) {
                  _date = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (value) {
                  _location = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _fetchDoctors();
                  }
                },
                child: const Text('Search'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_doctors[index]),
                      onTap: () => _navigateToAppointment(_doctors[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentPage extends StatelessWidget {
  final String doctor;

  const AppointmentPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment with $doctor'),
      ),
      body: Center(
        child: Text('Set up your appointment with $doctor here.'),
      ),
    );
  }
}
