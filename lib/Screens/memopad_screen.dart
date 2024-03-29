import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MemoPadScreen());
}

class MemoPadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MemoPad',
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
  final TextEditingController _textEditingController = TextEditingController();
  List<Map<String, dynamic>> memoItems = [];
  late int userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? -1;
    fetchMemos(); // Fetch memos once userId is retrieved
  }

  Future<void> fetchMemos() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/memos/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          memoItems = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch memos: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching memos: $e');
    }
  }

  Future<void> _saveMemo() async {
    final String memoText = _textEditingController.text.trim();

    if (memoText.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/memos'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'userId': userId,
            'content': memoText,
          }),
        );

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Memo text created successfully!'),
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
          setState(() {
            memoItems.add({'content': memoText});
            _textEditingController.clear();
          });
        } else {
          print('Failed to save memo: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error saving memo: $e');
      }
    }
  }

  Future<void> _deleteMemo(int memoId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/api/memos/$memoId'),
      );

      if (response.statusCode == 200) {
        // Remove the memo from the memoItems list
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Memo text deleted successfully!'),
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
        setState(() {
          memoItems.removeWhere((item) => item['id'] == memoId);
        });
      } else {
        print('Failed to delete memo: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error deleting memo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF674AEF),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.black,
            fontFamily: 'Roboto-Regular',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Enter your text here...",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 5,
            color: Colors.white60,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: memoItems.length,
              itemBuilder: (context, index) {
                return buildContainer(memoItems[index]);
              },
            ),
          ),
          buildSaveButton(),
        ],
      ),
    );
  }

  Widget buildContainer(Map<String, dynamic> item) {
    final String cleanedText = item['content'].replaceAll(RegExp(r'<[^>]*>'), '');
    final String limitedText = cleanedText.split(' ').take(12).join(' ');

    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      height: 45,
      width: double.infinity,
      child: InkWell(
        onTap: () => setText(item['content']),
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
                onPressed: () => _deleteMemo(item['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setText(String text) {
    setState(() {
      _textEditingController.text = text;
    });
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: _saveMemo,
      child: Container(
        width: double.infinity,
        height: 60,
        color: Colors.black87,
        child: Center(
          child: const Text(
            'SAVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}
