import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeTableScreen extends StatefulWidget {
  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  late int userId; // Variable to store logged userId
  List<Task> mondayTasks = [];
  List<Task> tuesdayTasks = [];
  List<Task> WednesdayTasks = [];
  List<Task> ThursdayTasks = [];
  List<Task> FridayTasks = [];
  List<Task> SaturdayTasks = [];
  List<Task> SundayTasks = [];
  // Add similar lists for other days

  @override
  void initState() {
    super.initState();
    getUserId(); // Call getUserId in initState
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? -1;
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Weekly Tasks'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildDayColumn('Monday', mondayTasks),
              buildDayColumn('Tuesday', tuesdayTasks),
              buildDayColumn('Wednesday', WednesdayTasks),
              buildDayColumn('Thursday', ThursdayTasks),
              buildDayColumn('Friday', FridayTasks),
              buildDayColumn('Saturday', SaturdayTasks),
              buildDayColumn('Sunday', SundayTasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDayColumn(String day, List<Task> tasks) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _showAddTaskDialog(day, tasks);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index].taskName),
                  subtitle: Text('${tasks[index].startTime} - ${tasks[index].endTime}'),
                  // You can add more details or actions here
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(String day, List<Task> tasks) {
    TextEditingController taskController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Start Time'),
              ),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'End Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addTaskToTimeTable(day, taskController.text, startTimeController.text, endTimeController.text);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addTaskToTimeTable(String day, String taskName, String startTime, String endTime) async {
    if (userId != -1) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/timetable/addTask/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'day': day,
          'taskName': taskName,
          'startTime': startTime,
          'endTime': endTime,
        }),
      );

      if (response.statusCode == 200) {
        // Task added successfully, you may update the local state or perform any other actions
      } else {
        // Handle the error
        print('Failed to add task. Error: ${response.body}');
      }
    } else {
      // Handle the case when userId is not available
      print('UserId not available');
    }
  }
}

class Task {
  final String taskName;
  final String startTime;
  final String endTime;

  Task({required this.taskName, required this.startTime, required this.endTime});
}

void main() {
  runApp(MaterialApp(
    home: TimeTableScreen(),
  ));
}
