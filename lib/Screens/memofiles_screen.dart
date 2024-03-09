import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MemoFilesScreen extends StatefulWidget {
  @override
  State<MemoFilesScreen> createState() => _MemoFilesScreenState();
}

class _MemoFilesScreenState extends State<MemoFilesScreen> {
  late int userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? -1;
    });
  }

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
        _showFilePreviewPopup(result.files.single);
      } else {
        // User canceled the file picking
        print('File picking canceled.');
      }
    } catch (e) {
      print('Error while picking a file: $e');
    }
  }

  void _showFilePreviewPopup(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('File Preview'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File Name: ${file.name}'),
              Text('File Size: ${file.size} bytes'),
              // Add more file details as needed
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the preview popup
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the preview popup
                _saveFile(file);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveFile(PlatformFile file) async {
    try {
      // Create FormData and add the file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8080/api/files/upload'),
      );

      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['userId'] = userId.toString();

      // Read file content from path
      List<int> fileBytes = await File(file.path!).readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
      ));

      // Send the API request
      var response = await request.send();

      // Handle the API response as needed
      if (response.statusCode == 200) {
        _showSuccessPopup();
      } else {
        print('Error saving file: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('File saved successfully.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the success popup
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
