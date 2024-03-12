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

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: todoEntries.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(todoEntries[index].title),
          subtitle: Text(todoEntries[index].description),
          // You can add more details or actions here
        );
      },
    );
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
