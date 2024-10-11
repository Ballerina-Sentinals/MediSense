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
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      // color: const Color.fromRGBO(200, 230, 201, 0.5),
                      color: Color.fromRGBO(255, 255, 255, 0.5),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    // color: Colors.green.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("test text"),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // my meals container
                  Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'My Meals',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("test text"),
                        ],
                      )),
                  const SizedBox(height: 16.0),
                  // my stats container
                  Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'My Stats',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("test text"),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
