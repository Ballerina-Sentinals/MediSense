import 'package:client/Authentication/doc_first_time_login_page.dart';
import 'package:client/Authentication/pharm_first_time_login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../App/app.dart';
import 'login_page.dart';
import 'first_time_login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/signup_'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': nameController.text,
          'email': emailController.text,
          'role': roleController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];
        print(user);
        print(user);
        if (user != null && user['id'] != null) {
          // Store user data in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(user));

          // Update the app state
          final appState = Provider.of<MyAppState>(context, listen: false);
          appState.updateProfileFromJson(user);
          appState.updateUserId(user['id']);
          print('User ID: ${user['id']}');
          print('Role: ${user['role']}');

          // Navigate to FirstTimeLoginPage
          if (user['role'] == 'patient') {
            print(roleController.text);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FirstTimeLoginPage(userId: user['id'].toString()),
              ),
            );
          } else if (user['role'] == 'doctor') {
            print(roleController.text);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DocFirstTimeLoginPage(userId: user['id'].toString()),
              ),
            );
          } else if (user['role'] == 'pharmacy') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PharmFirstTimeLoginPage(userId: user['id'].toString()),
              ),
            );
          } else {
            throw Exception('Invalid role');
          }
        } else {
          throw Exception('User ID is null');
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          errorMessage = responseData['error'] ?? 'Error registering user';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 217, 240, 255),
        title: const Text(
          'MediSense',
          style: TextStyle(
            color: Color.fromARGB(255, 36, 114, 113),
            fontFamily: 'Montserrat', // Change to your desired font family
            fontSize: 24, // Change to your desired font size
            fontWeight: FontWeight.bold, // Change to your desired font weight
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
            child: SingleChildScrollView(
          child: Card(
            color: const Color.fromARGB(255, 217, 240, 248).withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipOval(
                        child: Image.asset(
                          'lib/Resources/images/logo.png',
                          fit: BoxFit.cover,
                          height: 100,
                          width: 78,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 217, 247, 255)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 217, 247, 255)
                                .withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 217, 247, 255)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 217, 247, 255)
                                .withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 217, 247, 255)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 217, 247, 255)
                                .withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        dropdownColor: const Color.fromARGB(255, 217, 240,
                            255), // Background color of the dropdown menu

                        items: ['Patient', 'Doctor', 'Pharmacy']
                            .map((String role) {
                          IconData icon;
                          switch (role) {
                            case 'Patient':
                              icon = Icons.sick;
                              break;
                            case 'Doctor':
                              icon = MdiIcons.stethoscope;
                              break;
                            case 'Pharmacy':
                              icon = Icons.medical_services;
                              break;
                            default:
                              icon = Icons.help;
                          }
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Row(
                              children: [
                                Icon(icon,
                                    color: Color.fromARGB(
                                        255, 69, 127, 145)), // Icon color
                                const SizedBox(
                                    width: 8), // Space between icon and text
                                Text(
                                  role,
                                  style: const TextStyle(
                                    color: Color.fromARGB(
                                        255, 69, 127, 145), // Text color
                                    fontSize: 16, // Text size
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          print('Role: $newValue');
                          roleController.text = newValue!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 217, 247, 255)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 217, 247, 255)
                                .withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: signUp,
                        child: const Text('Sign Up'),
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                      child: const Text('Back to Login'),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ))
      ]),
    );
  }
}
