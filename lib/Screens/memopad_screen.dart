import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_summernote/flutter_summernote.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MemoPadScreen());
}

class MemoPadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotesPage(title: 'Memo Pad'),
    );
  }
}

class NotesPage extends StatefulWidget {
  NotesPage({required this.title});

  final String title;

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  GlobalKey<FlutterSummernoteState> _keyEditor = GlobalKey();
  List<String> todoItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F3FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          width: double.infinity,
          color: Color(0xFF674AEF),
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: Center(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.black,
                  fontFamily: 'Roboto-Regular',
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
            elevation: 0,
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  // Handle save button press
                  final value = await _keyEditor.currentState?.getText();
                  if (value != null && value.isNotEmpty) {
                    // Call API to save memo
                    await saveMemo(value);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'SAVE',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: FlutterSummernote(
                hint: 'Your text here...',
                key: _keyEditor,
                customToolbar: """
                  [
                    ['style', ['bold', 'italic', 'underline', 'clear']],
                    ['font', ['strikethrough', 'superscript', 'subscript']],
                    ['insert', ['link', 'table', 'hr']]
                  ]
                """,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: todoItems.length,
              itemBuilder: (context, index) {
                return buildContainer(todoItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildContainer(String text) {
    // Remove HTML tags
    String cleanedText = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Limit text to the first 12 words
    String limitedText = cleanedText.split(' ').take(12).join(' ');

    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      height: 45,
      width: double.infinity,
      child: InkWell(
        onTap: () {
          // Populate Summernote text area with clicked text
          _keyEditor.currentState?.setText(text);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                limitedText,
                style: TextStyle(fontSize: 15),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                onPressed: () async {
                  // Call API to delete memo
                  await deleteMemo(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveMemo(String text) async {
    try {
      // Make POST request to save memo
      final response = await http.post(
        Uri.parse('http://your-api-url/api/memos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': text}),
      );

      if (response.statusCode == 201) {
        // If memo saved successfully, add it to the list
        setState(() {
          todoItems.add(text);
        });
      } else {
        // Handle error
        print('Failed to save memo: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }

  Future<void> deleteMemo(String text) async {
    try {
      // Make DELETE request to delete memo
      final response = await http.delete(
        Uri.parse('http://your-api-url/api/memos/$text'),
      );

      if (response.statusCode == 200) {
        // If memo deleted successfully, remove it from the list
        setState(() {
          todoItems.remove(text);
        });
      } else {
        // Handle error
        print('Failed to delete memo: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }
}
