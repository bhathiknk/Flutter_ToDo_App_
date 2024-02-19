import 'package:flutter/material.dart';

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
        title: Text(
          'Memo Files',
        )
      ),
    );
  }
}