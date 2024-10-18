import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../App/app.dart';
import '../App/doc_home_page.dart';

class DocFirstTimeLoginPage extends StatefulWidget {
  final String userId;

  const DocFirstTimeLoginPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _DocFirstTimeLoginPage createState() => _DocFirstTimeLoginPage();
}

class _DocFirstTimeLoginPage extends State<DocFirstTimeLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _profileData = {
    'nic': null,
    'doctor_license': null,
    'description': '',
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
                    _buildTextField('nic', 'NIC'),
                    _buildTextField('doctor_license', 'Doctor License'),
                    _buildTextField('description', 'Description'),
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
        final response = await http.put(
          Uri.parse('http://10.0.2.2:8080/doctor_registation/${widget.userId}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(_profileData),
        );

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
            await prefs.setInt('userId', int.parse(widget.userId));
          }

          var appState = context.read<MyAppState>();
          appState.updateDocProfileFromJson(profileData);
          appState.updateUserId(int.parse(widget.userId));

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DocHomePage()));
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
