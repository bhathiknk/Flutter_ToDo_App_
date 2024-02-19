import 'package:flutter/material.dart';

class MemoPadScreen extends StatefulWidget {
  @override
  State<MemoPadScreen> createState() => _MemoPadScreenState();
}

class _MemoPadScreenState extends State<MemoPadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Memo Pad',
        )
      ),
    );
  }
}