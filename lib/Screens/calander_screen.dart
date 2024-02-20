
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/etc/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalanderScreen extends StatefulWidget {
  @override
  State<CalanderScreen> createState() => _CalanderScreenState();
}

class _CalanderScreenState extends State<CalanderScreen> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 1.8,
        centerTitle: true,
        title: Text('Calendar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: Opacity(
                  opacity: 0.7,
                  child: Text("Add an Event"),
                ),
                content: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDay != null) {
                        events.addAll({_selectedDay!: [Event(_eventController.text)]});
                        _selectedEvents.value = _getEventsForDay(_selectedDay!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF674AEF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
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
            // Event list
            SizedBox(height: 8.0),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          //border: Border.all(),
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFB9B7B7).withOpacity(0.2),
                          
                        ),
                        child: ListTile(
                          onTap: () => print(" "), 
                          title: Text(value[index].title),
                          trailing: Icon(Icons.delete),//delete event

                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
