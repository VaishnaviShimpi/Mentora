import 'package:flutter/material.dart';
import 'screens/teacher_screen.dart';
import 'screens/student_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teaching Learning Platform',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userType = 'Teacher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teaching-Learning Platform')),
      body: Column(
        children: [
          SizedBox(height: 20),
          DropdownButton<String>(
            value: userType,
            items:
                ['Teacher', 'Student'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (value) {
              setState(() {
                userType = value!;
              });
            },
          ),
          Expanded(
            child: userType == 'Teacher' ? TeacherScreen() : StudentScreen(),
          ),
        ],
      ),
    );
  }
}
