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
        // Print the response body for debugging
        print('Error decoding response. Response body: ${response.body}');
        return 'Unknown';
      }
    } else {
      // Print the error status code and response body for debugging
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      return 'Unknown';
    }
  }





  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1; // Return -1 if user ID is not available
  }

  //creating static data in lists
  List catNames = [
    "Categories",
    'Classes',
    'Free Courses',
    'Bookstore',
    'Live Courses',
    'LeaderBoard',
  ];

  List<Color> catColors = [
    Color(0xFFFFCF2F),
    Color(0xFF6FE08D),
    Color(0xFF61BDFD),
    Color(0xFFFC7F7F),
    Color(0xFFCB84FB),
    Color(0xFF78E667),
  ];

  List<Icon> catIcons = [
    Icon(Icons.category, color: Colors.white, size: 30),
    Icon(Icons.video_library, color: Colors.white, size: 30),
    Icon(Icons.assessment, color: Colors.white, size: 30),
    Icon(Icons.store, color: Colors.white, size: 30),
    Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
    Icon(Icons.emoji_events, color: Colors.white, size: 30),
  ];

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
                    //more vert with drop down
                    Padding(
                      padding: EdgeInsets.only(right: 1),
                    child: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                          Icon(
                            Icons.logout_outlined,
                          color: Colors.black54,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10.0
                              ),
                          ),   
                          Text('LogOut')
                        ],
                        ),
                        )
                      ],
                      child: Icon(
                     Icons.more_vert,
                      size: 30,
                      color: Colors.white,
                    ),
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
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final String username = snapshot.data ?? 'Unknown';
                            return Text(
                              'Hi, $username',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
                // Weather API area
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  
                ),
              ],
            ),
          ),

          // Large buttons area (main) 
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
                    // Navigate to different pages based on the button clicked
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
                          padding: EdgeInsets.all(06),//ui pixel bug change 10 to 06
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
