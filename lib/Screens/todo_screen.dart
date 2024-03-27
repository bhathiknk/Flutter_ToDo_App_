import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoScreen extends StatefulWidget {
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoEntry> todoEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('ToDO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<dynamic>> _fetchTodos(int userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/todos?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Widget _buildTodoList() {
    return FutureBuilder<int>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          int userId = snapshot.data ?? -1;
          return SizedBox(
            height: 200, // Adjust the height as needed
            child: FutureBuilder<List<dynamic>>(
              future: _fetchTodos(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<dynamic>? todos = snapshot.data;
                  return ListView.builder(
                    itemCount: todos?.length ?? 0,
                    itemBuilder: (context, index) {
                      var todo = todos![index];
                      String title = todo['todoTitle'] ?? 'No Title';
                      String description = todo['todoDescription'] ?? 'No Description';
                      String time = todo['todoTime'] ?? 'No Time';
                      int todoId = todo['id'];
                      return Container(
                        margin: EdgeInsets.all(8.0), // Adjust margin as needed
                        padding: EdgeInsets.all(16.0), // Adjust padding as needed
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F3FF), // Set background color
                          borderRadius: BorderRadius.circular(8.0), // Set border radius
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18.0, // Set title font size
                                    fontWeight: FontWeight.bold, // Set title font weight
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteTodoById(todoId);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14.0, // Set description font size
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Time: $time',
                              style: TextStyle(
                                fontSize: 12.0, // Set time font size
                                fontStyle: FontStyle.italic, // Set italic font style
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _deleteTodoById(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/api/todos/$id'),
      );

      if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Todo deleted successfully!'),
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
        setState(() {});
      } else {
        // Handle errors
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }


  void _showAddTodoDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Todo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {});
                      }
                    },
                    child: Text('Select Time'),
                  ),
                  if (selectedTime != null)
                    Text('Selected Time: ${selectedTime!.format(context)}'),
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
                    _saveTodoData(
                      titleController.text,
                      descriptionController.text,
                      selectedTime,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTodoData(
      String title,
      String description,
      TimeOfDay? selectedTime,
      ) async {
    try {
      final int userId = await getUserId();
      if (userId != -1) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/todos'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'userId': userId.toString(),
            'title': title,
            'description': description,
            'time': selectedTime?.format(context) ?? '',
          },
        );

        if (response.statusCode == 201) {
          _showSuccessMessage();
        } else {
          // Handle errors
          print('Error: ${response.statusCode}');
        }
      } else {
        // Handle case where userId is -1
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }
  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Todo added successfully!'),
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



  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1;
  }
}

class TodoEntry {
  final String title;
  final String description;
  final TimeOfDay time;

  TodoEntry({
    required this.title,
    required this.description,
    required this.time,
  });
}

void main() {
  runApp(MaterialApp(
    home: TodoScreen(),
  ));
}