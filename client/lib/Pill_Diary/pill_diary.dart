import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/assets.dart';
import '../App/app.dart';

class PillDiaryGenerator extends StatefulWidget {
  const PillDiaryGenerator({super.key});

  @override
  State<PillDiaryGenerator> createState() => _PillDiaryGeneratorState();
}

class _PillDiaryGeneratorState extends State<PillDiaryGenerator> {
  Map<String, dynamic> pills = {};
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchCalorieDiary(String userId, String date) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/pill-diary/$userId/$date'));

    if (response.statusCode == 200) {
      setState(() {
        pills = json.decode(response.body);
        print('Pill Diary is $pills');
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
                  print('formatted Date is ${formattedDate}');

                  fetchCalorieDiary(appState.userId.toString(), formattedDate);
                },
              ),
              const SizedBox(height: 60.0),
              CustomExpandingWidgetVer3(
                  listTitle: 'morning',
                  units: 'pills',
                  pairList: _getItemList('morning')),
              const SizedBox(
                height: 20,
              ),
              CustomExpandingWidgetVer3(
                  listTitle: 'noon',
                  units: 'pills',
                  pairList: _getItemList('noon')),
              const SizedBox(
                height: 20,
              ),
              CustomExpandingWidgetVer3(
                  listTitle: 'night',
                  units: 'pills',
                  pairList: _getItemList('night')),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Set<Map<String, double>> _getItemList(String mealType) {
    if (pills.isEmpty || !pills.containsKey(mealType)) {
      return {};
    } else if (pills[mealType].isEmpty) {
      return {
        {"Meal Plan not selected for $mealType": 0.0}
      };
    } else {
      var itemList = pills[mealType].map<Map<String, double>>((item) {
        var itemName = item['name'] as String? ?? 'Unknown';
        var itemCaloriesStr = item['total_calories'].toString();
        var itemCalories = double.tryParse(itemCaloriesStr) ?? 0.0;
        print('Item: $itemName, Calories: $itemCalories'); // Debug print

        return {itemName: itemCalories};
      }).toSet();

      print('Item list for $mealType: $itemList');
      return itemList;
    }
  }
}
