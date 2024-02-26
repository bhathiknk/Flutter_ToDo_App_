import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MemoFilesScreen extends StatefulWidget {
  @override
  State<MemoFilesScreen> createState() => _MemoFilesScreenState();
}

class _MemoFilesScreenState extends State<MemoFilesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Memo Files'),
      ),
      body: Center(
        child: Text('Your memo files content goes here.'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            _openFilePicker();
          },
          tooltip: 'Add',
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF674AEF), // Set your preferred background color
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        // Handle the selected file
        print('File picked: ${result.files.first.name}');
      } else {
        // User canceled the file picking
        print('File picking canceled.');
      }
    } catch (e) {
      print('Error while picking a file: $e');
    }
  }
}
