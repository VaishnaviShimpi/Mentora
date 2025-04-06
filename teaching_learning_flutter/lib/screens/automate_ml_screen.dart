import 'package:flutter/material.dart';

class AutomateMLScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Automate ML')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome to Automate ML", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(
              "Select dataset, features, and ML models to train and evaluate.",
            ),
            // Add dropdowns, buttons, and API calls here
          ],
        ),
      ),
    );
  }
}
