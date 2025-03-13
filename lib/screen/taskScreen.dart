import 'package:erp/bottomScreen/bottom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Map<String, dynamic>> tasks = List.generate(
    100,
    (index) => {
      "client": "Client ${index + 1}",
      "task": "Task details for ${index + 1}",
      "status": "In Process"
    },
  );

  int monthlyTarget = 50;
  int achievedTarget = 20;
  String currentMonth = DateFormat.MMMM().format(DateTime.now());

  void updateStatus(int index, String status) {
    setState(() {
      tasks[index]['status'] = status;
      if (status == "Done") {
        achievedTarget++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      title: Text("Task Management - $currentMonth"),
      leading: IconButton(
        icon: Icon(Icons.arrow_back), // Back arrow icon
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNavigationBarWidget())); // Go back to the previous screen
        },
      ),
    ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Total Tasks: 100", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Monthly Target: $monthlyTarget", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Achieved: $achievedTarget", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(tasks[index]['client']),
                    subtitle: Text(tasks[index]['task']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => updateStatus(index, "In Process"),
                          child: Text("In Process"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => updateStatus(index, "Done"),
                          child: Text("Done"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
