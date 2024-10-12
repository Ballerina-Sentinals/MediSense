// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../App/app.dart';

import 'dart:ui';

class HomePageGenerator extends StatefulWidget {
  const HomePageGenerator({super.key});

  @override
  State<HomePageGenerator> createState() => _HomePageGeneratorState();
}

class _HomePageGeneratorState extends State<HomePageGenerator> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Image.asset(
          'assets/bg.png',
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
                  Text("implement the home page here"),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
