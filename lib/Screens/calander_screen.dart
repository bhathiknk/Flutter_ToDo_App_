import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/etc/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CalanderScreen extends StatefulWidget {
  @override
  State<CalanderScreen> createState() => _CalanderScreenState();
}

class Event {
  String title;
  DateTime date;

  Event(this.title, {required this.date});
}

class _CalanderScreenState extends State<CalanderScreen> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;
  TextEditingController _eventController = TextEditingController();

  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = today;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
      _selectedDay = selectedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1; // Return -1 if user ID is not available
  }

  Future<void> insertEvent(String title, DateTime eventDate) async {
    int userId = await getUserId();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/events'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'title': title,
        'date': DateFormat('yyyy-MM-dd').format(eventDate),
      }),
    );

    if (response.statusCode == 200) {
      print('Event created successfully');
      await retrieveEvents();
      showSuccessDialog(context, 'Event saved successfully');
    } else {
      print('Error creating event');
      throw Exception('Failed to create event');
    }
  }

  Future<void> retrieveEvents() async {
    int userId = await getUserId();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/events/user/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);

      // Clear existing events
      events.clear();

      // Add retrieved events to the map
      responseBody.forEach((event) {
        if (event['eventDate'] != null && event['title'] != null) {
          DateTime eventDate = DateFormat('yyyy-MM-dd').parse(event['eventDate']);
          Event newEvent = Event(event['title'], date: eventDate);
          events[eventDate] = [newEvent];
        }
      });

      // Update the displayed events
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    } else {
      print('Error retrieving events');
      throw Exception('Failed to retrieve events');
    }
  }


  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) async {
    TextEditingController _eventTitleController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventTitleController,
                decoration: InputDecoration(labelText: 'Event Title'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Validate and save the event
                  if (_eventTitleController.text.isNotEmpty) {
                    await insertEvent(_eventTitleController.text, _selectedDay!);

                    // Close the 'Add Event' dialog
                    Navigator.popUntil(context, (route) => route.isFirst);

                    // Navigate to CalanderScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CalanderScreen()),
                    );

                    // Show the success dialog
                    showSuccessDialog(context, 'Event saved successfully');
                  } else {
                    showSnackBar(context, 'Please enter a title');
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 1.8,
        centerTitle: true,
        title: Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text("Selected Date = " + DateFormat('yyyy-MM-dd').format(today)),
            TableCalendar(
              locale: "en_US",
              rowHeight: 43,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (_selectedDay) => isSameDay(_selectedDay, today),
              focusedDay: today,
              firstDay: DateTime.utc(2000, 01, 01),
              lastDay: DateTime.utc(2050, 12, 31),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showAddEventDialog(context);
              },
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}
