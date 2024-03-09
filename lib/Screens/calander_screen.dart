import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CalanderScreen extends StatefulWidget {
  @override
  State<CalanderScreen> createState() => _CalanderScreenState();
}

class Event {
  int? id;
  String title;
  DateTime date;

  Event(this.title, {required this.date, this.id});
}

class _CalanderScreenState extends State<CalanderScreen> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;
  TextEditingController _eventController = TextEditingController();

  List<Event> _userEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = today;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    // Fetch user events when the screen is initialized
    fetchUserEvents();
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> fetchUserEvents() async {
    int userId = await getUserId();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/events/user/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> eventData = jsonDecode(response.body);

      setState(() {
        _userEvents = eventData.map((event) {
          return Event(
            event['title'],
            date: DateTime.parse(event['date']),
            id: event['id'],
          );
        }).toList();
      });
    } else {
      print('Error fetching user events');
      throw Exception('Failed to fetch user events');
    }
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
      _selectedDay = selectedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _userEvents.where((event) => isSameDay(event.date, day)).toList();
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
      showSuccessDialog(context, 'Event saved successfully');
      // Refresh user events after adding a new event
      fetchUserEvents();
    } else {
      print('Error creating event');
      throw Exception('Failed to create event');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/api/events/$eventId'),
    );

    if (response.statusCode == 200) {
      print('Event deleted successfully');
      showSuccessDialog(context, 'Event deleted successfully');
      // Refresh user events after deleting an event
      fetchUserEvents();
    } else if (response.statusCode == 404) {
      print('Event not found');
      showSnackBar(context, 'Event not found');
    } else {
      print('Error deleting event');
      showSnackBar(context, 'Error deleting event');
    }
  }

  Container buildEventContainer(Event userEvent) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text(
          userEvent.title,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        subtitle: Text(
          DateFormat('yyyy-MM-dd').format(userEvent.date),
          style: TextStyle(
            color: Color(0xFF674AEF),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            showDeleteConfirmationDialog(userEvent);
          },
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(Event userEvent) async {
    if (userEvent.id == null) {
      // Handle the case where the event ID is null
      showSnackBar(context, 'Invalid event ID');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await deleteEvent(userEvent.id!); // Assuming id is available
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
                    await insertEvent(
                        _eventTitleController.text, _selectedDay!);

                    // Close the 'Add Event' dialog
                    Navigator.popUntil(
                        context, (route) => route.isFirst);

                    // Navigate to CalanderScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CalanderScreen()),
                    );

                    // Show the success dialog
                    showSuccessDialog(
                        context, 'Event saved successfully');
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back when the back button is pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Text("Selected Date = " +
                DateFormat('yyyy-MM-dd').format(today)),
            TableCalendar(
              locale: "en_US",
              rowHeight: 43,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (_selectedDay) =>
                  isSameDay(_selectedDay, today),
              focusedDay: today,
              firstDay: DateTime.utc(2000, 01, 01),
              lastDay: DateTime.utc(2050, 12, 31),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddEventDialog(context);
                },
                child: Text('Add Event'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 20.0),
              child: Text(
                "Your Events",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            if (_userEvents.isNotEmpty)
              Column(
                children: [
                  for (Event userEvent in _userEvents)
                    buildEventContainer(userEvent),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
