import 'dart:ui';

import 'package:ava_app/header.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String getCurrentTime() {
    final now = DateTime.now();

    if (now.hour >= 5 && now.hour < 11) {
      return "morning";
    } else if (now.hour >= 11 && now.hour < 17) {
      return "afternoon";
    } else if (now.hour >= 17 && now.hour < 23) {
      return "evening";
    } else {
      return "night";
    }
  }

  double temp = 32;
  double humidity = 70.2;

  @override
  Widget build(BuildContext context) {
    String time = getCurrentTime();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/$time.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 75, right: 20),
          child: Column(children: [
            Header(
              humidity: humidity,
              temp: temp,
              time: time,
            ),
            const SizedBox(height: 40)
          ]),
        ),
      ),
    );
  }
}
