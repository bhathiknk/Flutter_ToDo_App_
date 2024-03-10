import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo Files App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MemoFilesScreen(),
    );
  }
}

class MemoFilesScreen extends StatefulWidget {
  @override
  State<MemoFilesScreen> createState() => _MemoFilesScreenState();
}

class _MemoFilesScreenState extends State<MemoFilesScreen> {
  late int userId;
  List<FileData> savedFiles = [];

  @override
  void initState() {
    super.initState();
    _getUserId();
    _getSavedFiles(); // Fetch saved files on initialization
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? -1;
    });
  }

  Future<void> _getSavedFiles() async {
    try {
      await _getUserId(); // Wait for _getUserId to complete

      var response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/files/user/$userId'),
      );

      if (response.statusCode == 200) {
        List<FileData> files = (json.decode(response.body) as List)
            .map((file) => FileData.fromMap(file))
            .toList();

        setState(() {
          savedFiles = files;
        });
      } else {
        print('Error fetching saved files: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching saved files: $e');
    }
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
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          SizedBox(height: 16),
          Text('Saved Files:', style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          Column(
            children: savedFiles
                .map((file) => FileContainer(file: file))
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openFilePicker();
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF674AEF), // Set your preferred background color
      ),
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
    TextEditingController fileNameController = TextEditingController();
    String fileFormat = file.extension ?? 'Unknown'; // Get file format

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('File Preview'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File Format: $fileFormat'),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Rename:'),
                  SizedBox(width: 10),
                  Flexible(
                    child: TextField(
                      controller: fileNameController,
                      decoration: InputDecoration(
                        labelText: 'New File Name',
                        hintText: 'Enter a new name',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Original File Name: ${file.name}'),
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
                _saveFile(file, fileNameController.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveFile(PlatformFile file, String newFileName) async {
    try {
      // Determine the file type using the mime package
      String fileFormat = file.extension ?? ''; // Get file format

      // Create FormData and add the file with the new name and type
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
        filename: newFileName.isEmpty ? '${file.name}' : '$newFileName.$fileFormat',
        contentType: MediaType.parse('application/octet-stream'),
      ));

      // Send the API request
      var response = await request.send();

      // Handle the API response as needed
      if (response.statusCode == 200) {
        _showSuccessPopup();
        _getSavedFiles(); // Fetch updated saved files after saving a new file
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

class FileData {
  final int id;
  final String fileName;
  final String uploadDate;

  FileData({
    required this.id,
    required this.fileName,
    required this.uploadDate,
  });

  factory FileData.fromMap(Map<String, dynamic> map) {
    return FileData(
      id: map['id'] as int? ?? -1, // Provide a default value if 'fileId' is null
      fileName: map['fileName'].toString(),
      uploadDate: map['uploadDate'].toString(),
    );
  }
}

class FileContainer extends StatelessWidget {
  final FileData file;

  FileContainer({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text(
          file.fileName,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          'Upload Date: ${file.uploadDate}',
          style: TextStyle(
            color: Color(0xFF674AEF),
            fontSize: 16,
          ),
        ),
        onTap: () {
          _viewFileContent(context, file);
        },
      ),
    );
  }

  void _viewFileContent(BuildContext context, FileData file) {
    if (file.fileName.toLowerCase().endsWith('.pdf')) {
      // PDF file
      _viewPDFContent(context, file);
    } else if (file.fileName.toLowerCase().endsWith('.png') ||
        file.fileName.toLowerCase().endsWith('.jpg') ||
        file.fileName.toLowerCase().endsWith('.jpeg')) {
      // Image file
      _viewImageContent(context, file);
    } else {
      // Handle other file types as needed
      print('Unsupported file type.');
    }
  }

  void _viewPDFContent(BuildContext context, FileData file) async {
    try {
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/files/${file.id}/content'),
      );

      if (response.statusCode == 200) {
        // Assume that the response.body contains the PDF content as bytes
        // Make sure to handle different content types appropriately
        int fileId = file.id;
        String fileName = file.fileName;
        Uint8List pdfBytes = response.bodyBytes;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(pdfData: pdfBytes),
          ),
        );
      } else {
        print('Error fetching file content. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error fetching file content. Status code: ${response.statusCode}'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the error popup
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching file content: $e\n$stackTrace');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error fetching file content: $e'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the error popup
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _viewImageContent(BuildContext context, FileData file) async {
    try {
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/files/${file.id}/content'),
      );

      if (response.statusCode == 200) {
        // Assume that the response.body contains the image content as bytes
        // Make sure to handle different content types appropriately
        int fileId = file.id;
        String fileName = file.fileName;
        Uint8List imageBytes = response.bodyBytes;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(imageData: imageBytes),
          ),
        );
      } else {
        print('Error fetching image content. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error fetching image content. Status code: ${response.statusCode}'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the error popup
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching image content: $e\n$stackTrace');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error fetching image content: $e'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the error popup
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class PDFViewerScreen extends StatelessWidget {
  final Uint8List pdfData;

  PDFViewerScreen({required this.pdfData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PDFView(
        filePath: null,
        pdfData: pdfData,
        // Add other parameters as needed
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final Uint8List imageData;

  ImageViewerScreen({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Image.memory(imageData),
    );
  }
}
