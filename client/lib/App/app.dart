import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Authentication/signup_page.dart';
import '../Authentication/login_page.dart';
import 'my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'MediSense',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 125, 167, 255)),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const MyHomePage(),
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  int userId = 0;
  String username = '';
  String name = '';
  String email = '';
  String gender = '';
  DateTime dateOfBirth = DateTime.now();
  double height = 0;
  double weight = 0;
  String allergies = '';

  String doctor_license = '';
  String description = '';

  MyAppState() {
    _loadUserData();
  }

  Future<void> initializeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt('userId');
    if (storedUserId != null) {
      userId = storedUserId;
      notifyListeners();
    }
  }

  void updateUserId(int newUserId) {
    userId = newUserId;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      updateProfileFromJson(userData);
    }
  }

  void updateProfileFromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? userId;
    username = json['username'] ?? username;
    name = json['name'] ?? name;
    email = json['email'] ?? email;
    gender = json['gender'] ?? gender;
    dateOfBirth = json['date_of_birth'] != null
        ? DateTime.parse(json['date_of_birth'])
        : dateOfBirth;
    height = json['height_cm'] != null
        ? double.parse(json['height_cm'].toString())
        : height;
    weight = json['weight_kg'] != null
        ? double.parse(json['weight_kg'].toString())
        : weight;
  }

  void updateDocProfileFromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? userId;
    username = json['username'] ?? username;
    name = json['name'] ?? name;
    email = json['email'] ?? email;
    doctor_license = json['doctor_license'] ?? doctor_license;
    description = json['description'] ?? description;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'name': name,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'height_cm': height,
      'weight_kg': weight,
    };
  }

  // Setters for each field that call notifyListeners()
  set setUsername(String value) {
    username = value;
    notifyListeners();
  }

  set setName(String value) {
    name = value;
    notifyListeners();
  }

  set setEmail(String value) {
    email = value;
    notifyListeners();
  }

  set setGender(String value) {
    gender = value;
    notifyListeners();
  }

  set setDateOfBirth(DateTime value) {
    dateOfBirth = value;
    notifyListeners();
  }

  set setHeight(double value) {
    height = value;
    notifyListeners();
  }

  set setWeight(double value) {
    weight = value;
    notifyListeners();
  }

  set setAllergies(String value) {
    allergies = value;
    notifyListeners();
  }

  void resetState() {
    // Reset all relevant state variables
    userId = 0;
    username = '';
    name = '';
    email = '';
    gender = '';
    dateOfBirth = DateTime.now();
    height = 0;
    weight = 0;
    // Reset other variables as needed
    notifyListeners();
  }

  void changeProfilePicture() {
    // Implement logic to change the profile picture
  }

  void updateUserName(String newName) {
    name = newName;
    notifyListeners();
  }
}
