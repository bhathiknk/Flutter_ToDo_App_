import 'package:flutter/material.dart';
import 'package:flutter_todo_app/Screens/todo_screen.dart';

import 'memofiles_recover.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> imgList = [
    'MemoFiles',

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'History',
        ),
      ),
      body: GridView.builder(
        itemCount: imgList.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio:
          (MediaQuery.of(context).size.height - 50 - 25) / (4 * 240),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MemoFilesRecover()),
                  );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFFF5F3FF),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(06),
                    child: Image.asset(
                      "images/Memo Files.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    imgList[index],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Objectives add here",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}