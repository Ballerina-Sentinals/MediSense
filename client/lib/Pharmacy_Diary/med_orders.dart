import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/assets.dart';
import '../App/app.dart';

class PillOrderGenerator extends StatefulWidget {
  const PillOrderGenerator({super.key});

  @override
  State<PillOrderGenerator> createState() => _PillOrderGeneratorState();
}

class _PillOrderGeneratorState extends State<PillOrderGenerator> {
  Map<String, dynamic> pill_orders = {};
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchCalorieDiary(String userId, String date) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/pill-diary/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        pill_orders = json.decode(response.body);
        print('Pill Diary is $pill_orders');
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
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              CustomCalendar(
                onDaySelected: (selectedDay, focusedDay) {
                  String formattedDate =
                      selectedDay.toIso8601String().split('T')[0];
                  print(
                      'appState.userId.toString() is ${appState.userId.toString()}');
                  print('formatted Date is $formattedDate');

                  fetchCalorieDiary(appState.userId.toString(), formattedDate);
                },
              ),
              const SizedBox(height: 60.0),
              CustomExpandingWidgetVer3(
                  listTitle: 'accepted',
                  units: 'pills',
                  pairList: _getItemList('accepted')),
              const SizedBox(
                height: 20,
              ),
              CustomExpandingWidgetVer3(
                  listTitle: 'pending',
                  units: 'pills',
                  pairList: _getItemList('pending')),
              const SizedBox(
                height: 20,
              ),
              CustomExpandingWidgetVer3(
                  listTitle: 'declined',
                  units: 'pills',
                  pairList: _getItemList('declined')),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Set<Map<String, double>> _getItemList(String state) {
    if (pill_orders.isEmpty || !pill_orders.containsKey(state)) {
      return {};
    } else if (pill_orders[state].isEmpty) {
      return {
        {"Pill orders $state": 0.0}
      };
    } else {
      var itemList = pill_orders[state].map<Map<String, double>>((item) {
        var itemName = item['pill_name'] as String? ?? 'Unknown';
        var itemNumStr = item['amount'].toString();
        var itemNum = double.tryParse(itemNumStr) ?? 0.0;
        print('Item: $itemName, Calories: $itemNum'); // Debug print

        return {itemName: itemNum};
      }).toSet();

      print('Item list for $state: $itemList');
      return itemList;
    }
  }
}
