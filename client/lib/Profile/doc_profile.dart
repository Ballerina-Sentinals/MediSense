import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../App/app.dart';
import 'dart:ui';

class ProfilePageGenerator extends StatefulWidget {
  const ProfilePageGenerator({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageGenerator> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    var appState = context.read<MyAppState>();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/doctor_profile/${appState.userId}'),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final profileData = json.decode(response.body);
      appState.updateProfileFromJson(profileData);
      print(profileData);

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      print(userJson);

      print(userJson);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        userData.addAll(profileData);
        await prefs.setString('user', jsonEncode(userData));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user profile')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      var appState = context.read<MyAppState>();
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/user-profile/${appState.userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(appState.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('My Profile')),
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Image.asset(
          'lib/Resources/images/001_blueCapsules.jpg',
          fit: BoxFit.cover,
          // height: 120,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: const Color.fromARGB(255, 182, 221, 241).withOpacity(0.6),
          ),
        ),
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profilePicture(),
                _usernameShow(),
                _name(),
                _email(),
                _sex(),
                _dateOfBirth(),
                _height(),
                _weight(),
                _allergies(),
                const SizedBox(height: 40),
                Center(child: _isEditing ? null : _deleteUserButton()),
              ],
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleEditMode,
        child: Icon(_isEditing ? Icons.save : Icons.edit),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _saveProfile();
      }
      _isEditing = !_isEditing;
    });
  }

  Widget _profilePicture() {
    return const CircleAvatar(
      radius: 50,
      child: Icon(Icons.person, size: 50),
    );
  }

  Widget _usernameShow() {
    var appState = context.watch<MyAppState>();
    return ListTile(
      title: const Text('Username'),
      subtitle: Text(appState.username),
    );
  }

  Widget _name() {
    var appState = context.watch<MyAppState>();
    return TextFormField(
      enabled: _isEditing,
      initialValue: appState.name,
      decoration: const InputDecoration(labelText: 'Name'),
      onChanged: (value) => appState.name = value,
    );
  }

  Widget _email() {
    var appState = context.watch<MyAppState>();
    return TextFormField(
      enabled: _isEditing,
      initialValue: appState.email,
      decoration: const InputDecoration(labelText: 'Email'),
      onChanged: (value) => appState.email = value,
    );
  }

  Widget _sex() {
    var appState = context.watch<MyAppState>();
    return DropdownButtonFormField<String>(
      value: appState.gender.isNotEmpty ? appState.gender : null,
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
      ],
      onChanged: _isEditing ? (value) => appState.gender = value! : null,
      decoration: InputDecoration(
        labelText: 'Gender',
        enabled: _isEditing,
      ),
    );
  }

  Widget _dateOfBirth() {
    var appState = context.watch<MyAppState>();
    return TextFormField(
      enabled: _isEditing,
      controller: TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(appState.dateOfBirth),
      ),
      decoration: const InputDecoration(labelText: 'Date of Birth'),
      onTap: _isEditing
          ? () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: appState.dateOfBirth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                appState.dateOfBirth = pickedDate;
              }
            }
          : null,
    );
  }

  Widget _height() {
    var appState = context.watch<MyAppState>();
    return TextFormField(
      enabled: _isEditing,
      initialValue: appState.height.toString(),
      decoration: const InputDecoration(labelText: 'Height (cm)'),
      keyboardType: TextInputType.number,
      onChanged: (value) =>
          appState.height = double.tryParse(value) ?? appState.height,
    );
  }

  Widget _weight() {
    var appState = context.watch<MyAppState>();
    return TextFormField(
      enabled: _isEditing,
      initialValue: appState.weight.toString(),
      decoration: const InputDecoration(labelText: 'Weight (kg)'),
      keyboardType: TextInputType.number,
      onChanged: (value) =>
          appState.weight = double.tryParse(value) ?? appState.weight,
    );
  }

  Widget _allergies() {
    var appState = context.watch<MyAppState>();
    return TextFormField(
      enabled: _isEditing,
      initialValue: appState.allergies,
      decoration: const InputDecoration(labelText: 'Allergies'),
      onChanged: (value) => appState.allergies = value,
    );
  }

  Widget _deleteUserButton() {
    return ElevatedButton(
      onPressed: _showDeleteConfirmation,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('Delete User'),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    var appState = context.read<MyAppState>();
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/user/${appState.userId}'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
      // Navigate to login page or clear app state
      Navigator.of(context).pushReplacementNamed('/login'); // Adjust as needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
    }
  }
}
