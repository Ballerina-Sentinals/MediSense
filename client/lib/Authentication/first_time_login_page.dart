import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../App/app.dart';

class FirstTimeLoginPage extends StatefulWidget {
  final String userId;

  const FirstTimeLoginPage({super.key, required this.userId});

  @override
  _FirstTimeLoginPageState createState() => _FirstTimeLoginPageState();
}

class _FirstTimeLoginPageState extends State<FirstTimeLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _profileData = {
    'gender': null,
    'dob': null,
    'nic': null,
    'emergency_contact': null,
    'height': null,
    'weight': null,
    'allergies': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 217, 240, 255),
        title: const Text(
          'MediSense',
          style: TextStyle(
            color: Color.fromARGB(255, 36, 114, 113),
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(fit: StackFit.expand, children: <Widget>[
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
        Center(
          child: Card.outlined(
            color: const Color.fromARGB(255, 201, 234, 245).withOpacity(0.7),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDropdownField(
                        'gender', 'Gender', ['male', 'female', 'other']),
                    _buildDateField('dob', 'Date of Birth'),
                    _buildTextField('nic', 'NIC'),
                    _buildTextField('emergency_contact', 'Emergency Contact'),
                    _buildNumberField('height', 'Height (cm)'),
                    _buildNumberField('weight', 'Weight (kg)'),
                    _buildTextField('allergies', 'Allergies'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text('Skip'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text("Return to Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDropdownField(String key, String label, List<String> items) {
    return DropdownButtonFormField<String>(
      value: _profileData[key],
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(
            value: null, child: Text('Please select')),
        ...items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }),
      ],
      onChanged: (String? newValue) {
        setState(() => _profileData[key] = newValue);
      },
      validator: (value) => value == null ? 'Please select a value' : null,
    );
  }

  Widget _buildDateField(String key, String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _profileData[key] = picked.toIso8601String());
        }
      },
      controller: TextEditingController(
        text: _profileData[key] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(_profileData[key]))
            : '',
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a date' : null,
    );
  }

  Widget _buildNumberField(String key, String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      initialValue: _profileData[key]?.toString() ?? '',
      onChanged: (value) {
        setState(() {
          _profileData[key] = value.isEmpty ? null : double.tryParse(value);
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter a value' : null,
    );
  }

  Widget _buildTextField(String key, String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: _profileData[key] as String?,
      onChanged: (value) {
        setState(() {
          _profileData[key] = value;
        });
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        // Convert date to the required format
        if (_profileData['dob'] != null) {
          _profileData['dob'] = DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(_profileData['dob']));
        }

        final response = await http.put(
          Uri.parse(
              'http://10.0.2.2:8080/patient_registation/${widget.userId}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(_profileData),
        );
        print("called patient_registration");

        if (response.statusCode == 200) {
          final profileData = json.decode(response.body);
          print('Profile Data: $profileData');

          // Update SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final userJson = prefs.getString('user');
          if (userJson != null) {
            final userData = jsonDecode(userJson);
            userData.addAll(profileData);
            await prefs.setString('user', jsonEncode(userData));

            // Update userId in SharedPreferences
            await prefs.setInt('userId', int.parse(widget.userId));
          }

          var appState = context.read<MyAppState>();
          appState.updateProfileFromJson(profileData);
          appState.updateUserId(int.parse(widget.userId));

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      } catch (e) {
        print('Error: $e'); // Log the error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }
}
