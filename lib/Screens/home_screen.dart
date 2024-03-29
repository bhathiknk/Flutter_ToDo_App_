import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/Screens/calander_screen.dart';
import 'package:flutter_todo_app/Screens/history_screen.dart';
import 'package:flutter_todo_app/Screens/memofiles_screen.dart';
import 'package:flutter_todo_app/Screens/memopad_screen.dart';
import 'package:flutter_todo_app/Screens/timetable_screen.dart';
import 'package:flutter_todo_app/Screens/todo_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../user/login_page.dart';

class HomePage extends StatelessWidget {
  Future<String> getUsername(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/users/username/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        final String username = data['username'];
        return username;
      } catch (e) {
        print('Error decoding response. Response body: ${response.body}');
        return 'Unknown';
      }
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      return 'Unknown';
    }
  }

  Future<Map<String, dynamic>> getWeatherData() async {
    final String apiKey = 'b2bbc7b07ebc93d7aabc7e4c6c107a0b';
    final String cityName = 'Colombo';
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> weatherData = json.decode(response.body);
        return weatherData;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load weather data');
    }
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      // Show a snackbar when user logs out and comes back to login page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have been successfully logged out! Come back again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  List<String> imgList = [
    'ToDo',
    'Calander',
    'Memo Pad',
    'Memo Files',
    'Time Table',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            decoration: BoxDecoration(
              color: Color(0xFF674AEF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.dashboard,
                      size: 30,
                      color: Colors.white,
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                color: Colors.black54,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                              ),
                              InkWell(
                                onTap: () => _logout(context),
                                child: Text('Log Out'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                FutureBuilder<int>(
                  future: getUserId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final int userId = snapshot.data ?? -1;
                      return FutureBuilder<String>(
                        future: getUsername(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final String username = snapshot.data ?? 'Unknown';
                            return Text(
                              'Hi, $username',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                wordSpacing: 2,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: getWeatherData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error loading weather data');
                      } else {
                        final weatherData = snapshot.data;
                        final time = DateFormat.Hm().format(DateTime.now());

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Weather: ${weatherData?['main']?['temp'] ?? 'N/A'}°C',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            LiveTimeDisplay(),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: GridView.builder(
              itemCount: imgList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                (MediaQuery.of(context).size.height - 50 - 25) / (4 * 240),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    switch (index) {
                      case 0:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TodoScreen()));
                        break;
                      case 1:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CalanderScreen()));
                        break;
                      case 2:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MemoPadScreen()));
                        break;
                      case 3:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MemoFilesScreen()));
                        break;
                      case 4:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeTableScreen()));
                        break;
                      case 5:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryScreen()));
                        break;
                      default:
                        break;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF5F3FF),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(06),
                          child: Image.asset(
                            "images/${imgList[index]}.png",
                            width: 100,
                            height: 100,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          imgList[index],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Objectives add here",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LiveTimeDisplay extends StatefulWidget {
  @override
  _LiveTimeDisplayState createState() => _LiveTimeDisplayState();
}

class _LiveTimeDisplayState extends State<LiveTimeDisplay> {
  late String currentTime;
  late String animationAsset;

  @override
  void initState() {
    super.initState();

    // Initialize the time
    updateTime();

    //Initialize the animation assets
    animationAsset="";

    // Update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      updateTime();
    });
  }

  void updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat.Hm().format(DateTime.now());
    setState(() {
      currentTime = formattedTime;

      //Determine animation asset based on time of day
      if(now.hour >= 6 && now.hour < 12){
        //Morning
        animationAsset = 'images/Morning.json';
      }

      //Evening
      else if(now.hour >= 12 && now.hour < 18){
        animationAsset = 'images/Evening.json';
      }
      //Night
      else{
        animationAsset = 'images/Night.json';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Time: $currentTime',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        Container(
          height: 70,
          width: 70,
          child: animationAsset.isNotEmpty
              ? Lottie.asset(
            animationAsset,
            fit: BoxFit.cover,
          )
              : SizedBox(), // If animationAsset is empty, display an empty SizedBox
        ),
      ],
    );
  }
}