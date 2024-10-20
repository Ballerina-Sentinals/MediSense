// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../App/app.dart';

class PharmHomePageGenerator extends StatefulWidget {
  const PharmHomePageGenerator({super.key});

  @override
  State<PharmHomePageGenerator> createState() =>
      _PharmDocHomePageGeneratorState();
}

class _PharmDocHomePageGeneratorState extends State<PharmHomePageGenerator> {
  Map<String, dynamic> pills = {};
  final date = DateTime.now().toString().substring(0, 10);

  Future<void> fetchPills(String userId, String date) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/pill-diary/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        pills = json.decode(response.body);
        print('Pills are $pills');
        print("//////////////////////////////////////////////");
      });
    } else {
      throw Exception('Failed to load pill diary');
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: <Widget>[
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
        SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hello, ${appState.name}!',
                    style: const TextStyle(fontSize: 24, color: Colors.black54),
                  ),
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
                                child: Text('Orders',
                                    style: const TextStyle(
                                        fontSize: 24, color: Colors.black54)))),
                        const SizedBox(height: 16.0),
                        Text(
                          'Your next appointment is on 12th August 2021',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black54),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                      onPressed: () {
                        fetchPills(appState.userId.toString(), date);
                      },
                      label: Text("Add Pills"),
                      icon: Icon(Icons.add)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
