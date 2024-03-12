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
    getUserId().then((value) {
      // Fetch tasks for each day after getting the userId
      fetchTasksForDay('Monday', mondayTasks);
      fetchTasksForDay('Tuesday', tuesdayTasks);
      fetchTasksForDay('Wednesday', WednesdayTasks);
      fetchTasksForDay('Thursday', ThursdayTasks);
      fetchTasksForDay('Friday', FridayTasks);
      fetchTasksForDay('Saturday', SaturdayTasks);
      fetchTasksForDay('Sunday', SundayTasks);
    });
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
        title: Text('Weekly TimeTable'),
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
    // Sort tasks based on start time
    tasks.sort((a, b) {
      DateTime aStartTime = DateTime.parse('2022-01-01 ${a.startTime.padLeft(2, '0')}:00:00');
      DateTime bStartTime = DateTime.parse('2022-01-01 ${b.startTime.padLeft(2, '0')}:00:00');
      return aStartTime.compareTo(bStartTime);
    });

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
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    _deleteTask(day, tasks[index]);
                  },
                  background: Container(
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF), // Set background color
                      ),
                      margin: const EdgeInsets.all(5.0),
                      child: ListTile(
                        title: Text(
                          tasks[index].taskName,
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          'Time: ${tasks[index].formattedTime} ${tasks[index].timePeriod}',
                          style: TextStyle(color: Colors.black),
                        ),
                        // You can add more details or actions here
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String startSelectedPeriod = 'AM';
  String endSelectedPeriod = 'AM';

  void _showAddTaskDialog(String day, List<Task> tasks) {
    TextEditingController taskController = TextEditingController();
    TextEditingController startHourController = TextEditingController();
    TextEditingController endHourController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(labelText: 'Task Name'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startHourController,
                          decoration: InputDecoration(labelText: 'Start Hour'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              // Automatically determine AM/PM for start time
                              startSelectedPeriod = _determinePeriod(value);
                            });
                          },
                        ),
                      ),
                      DropdownButton<String>(
                        value: startSelectedPeriod,
                        items: ['AM', 'PM']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            startSelectedPeriod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: endHourController,
                          decoration: InputDecoration(labelText: 'End Hour'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              // Automatically determine AM/PM for end time
                              endSelectedPeriod = _determinePeriod(value);
                            });
                          },
                        ),
                      ),
                      DropdownButton<String>(
                        value: endSelectedPeriod,
                        items: ['AM', 'PM']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            endSelectedPeriod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  // Display selected AM/PM values
                  Text('Start Time: ${startHourController.text} $startSelectedPeriod'),
                  Text('End Time: ${endHourController.text} $endSelectedPeriod'),
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
                    _addTaskToTimeTable(
                      day,
                      taskController.text,
                      _formatTime(startHourController.text, startSelectedPeriod),
                      _formatTime(endHourController.text, endSelectedPeriod),
                    );
                    Navigator.pop(context);
                    _showSuccessMessage();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _determinePeriod(String hour) {
    // Convert hour to int and determine AM/PM
    try {
      int hourValue = int.parse(hour);
      return (hourValue >= 12) ? 'PM' : 'AM';
    } catch (e) {
      return 'AM'; // Default to 'AM' if parsing fails
    }
  }

  String _formatTime(String time, String period) {
    try {
      // Convert time to 24-hour format
      int hours = int.parse(time.split(':')[0]);
      if (period == 'PM' && hours < 12) {
        hours += 12;
      } else if (period == 'AM' && hours == 12) {
        hours = 0;
      }

      // Ensure the hours are within the valid range (0-23)
      hours = hours % 24;

      // Convert the hours to a two-digit string
      String formattedHours = hours.toString().padLeft(2, '0');

      // Return the adjusted time
      return '$formattedHours:${time.split(':')[1]}:00';
    } catch (e) {
      // Handle any parsing errors here
      print('Error formatting time: $e');
      return time; // Return the original time if an error occurs
    }
  }

  void _addTaskToTimeTable(String day, String taskName, String startTime, String endTime) async {
    if (userId != -1) {
      // Format the time with selected AM/PM
      String formattedStartTime = _formatTime(startTime, startSelectedPeriod);
      String formattedEndTime = _formatTime(endTime, endSelectedPeriod);

      // Format the time for the backend
      String backendFormattedStartTime = _formatBackendTime(formattedStartTime, startSelectedPeriod);
      String backendFormattedEndTime = _formatBackendTime(formattedEndTime, endSelectedPeriod);

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/timetable/addTask/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'day': day,
          'taskName': taskName,
          'startTime': backendFormattedStartTime,
          'endTime': backendFormattedEndTime,
        }),
      );

      if (response.statusCode == 200) {
        // Task added successfully, now fetch the updated data
        await fetchTasksForDay(day, getTasksListForDay(day));
      } else {
        // Handle the error
        print('Failed to add task. Error: ${response.body}');
      }
    } else {
      // Handle the case when userId is not available
      print('UserId not available');
    }
  }

  String _formatBackendTime(String time, String period) {
    try {
      // Convert time to 24-hour format
      int hours = int.parse(time.split(':')[0]);
      if (period == 'PM' && hours < 12) {
        hours += 12;
      } else if (period == 'AM' && hours == 12) {
        hours = 0;
      }

      // Ensure the hours are within the valid range (0-23)
      hours = hours % 24;

      // Convert the hours back to a two-digit string
      String formattedHours = hours.toString().padLeft(2, '0');

      return '$formattedHours:${time.split(':')[1]}:00';
    } catch (e) {
      // Handle any parsing errors here
      print('Error formatting time for backend: $e');
      return time; // Return the original time if an error occurs
    }
  }

  Future<void> fetchTasksForDay(String day, List<Task> tasks) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/timetable/$userId/$day'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskData = json.decode(response.body);
        tasks.clear(); // Clear existing tasks
        taskData.forEach((task) {
          tasks.add(Task(
            taskName: task['taskName'],
            startTime: task['startTime'],
            endTime: task['endTime'],
            timePeriod: _determinePeriod(task['startTime']),
          ));
        });
        setState(() {}); // Update the UI after fetching tasks
      } else {
        print('Failed to fetch tasks for $day. Error: ${response.body}');
      }
    } catch (error) {
      print('Error fetching tasks: $error');
    }
  }

  Future<void> _deleteTask(String day, Task task) async {
    if (userId != -1) {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/api/timetable/deleteTask/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'day': day,
          'taskName': task.taskName,
          'startTime': task.startTime,
          'endTime': task.endTime,
        }),
      );

      if (response.statusCode == 200) {
        // Task deleted successfully, now fetch the updated data
        await fetchTasksForDay(day, getTasksListForDay(day));

        // Show success message after deleting the task
        _showDeleteSuccessMessage();
      } else {
        // Handle the error
        print('Failed to delete task. Error: ${response.body}');
      }
    } else {
      // Handle the case when userId is not available
      print('UserId not available');
    }
  }

  void _showDeleteSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Task deleted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Task> getTasksListForDay(String day) {
    switch (day) {
      case 'Monday':
        return mondayTasks;
      case 'Tuesday':
        return tuesdayTasks;
      case 'Wednesday':
        return WednesdayTasks;
      case 'Thursday':
        return ThursdayTasks;
      case 'Friday':
        return FridayTasks;
      case 'Saturday':
        return SaturdayTasks;
      case 'Sunday':
        return SundayTasks;
      default:
        return [];
    }
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Task added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class Task {
  final String taskName;
  final String startTime;
  final String endTime;
  final String timePeriod; // Added field to store AM/PM

  Task({required this.taskName, required this.startTime, required this.endTime, required this.timePeriod});

  // Define a getter for formattedTime
  String get formattedTime {
    return '$startTime - $endTime';
  }
}

void main() {
  runApp(MaterialApp(
    home: TimeTableScreen(),
  ));
}
