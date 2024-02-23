import 'package:flutter/material.dart';
import 'package:flutter_todo_app/Screens/home_screen.dart';
import 'package:flutter_todo_app/Screens/welcome_screen.dart';
import 'package:flutter_todo_app/user/login_page.dart';
import 'package:flutter_todo_app/user/register_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),// defaukt master branch page - WelcomeScreen()
    );
  }
}