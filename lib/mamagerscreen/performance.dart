import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  List<Map<String, dynamic>> employeePerformance = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployeePerformance();
  }

  Future<void> fetchEmployeePerformance() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, Map<String, int>> performanceMap = {}; 
        for (var doc in querySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String employee = data['employee'] ?? 'Unknown';
          String status = data['status'] ?? 'N/A';

          if (!performanceMap.containsKey(employee)) {
            performanceMap[employee] = {'inProcess': 0, 'done': 0};
          }
          if (status == 'In Process') {
            performanceMap[employee]!['inProcess'] = (performanceMap[employee]!['inProcess'] ?? 0) + 1;
          } else if (status == 'Done') {
            performanceMap[employee]!['done'] = (performanceMap[employee]!['done'] ?? 0) + 1;
          }
        }

        setState(() {
          employeePerformance = performanceMap.entries.map((entry) => {
                'employee': entry.key,
                'inProcess': entry.value['inProcess'] ?? 0,
                'done': entry.value['done'] ?? 0,
              }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching performance data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Performance Overview",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: employeePerformance.length,
                    itemBuilder: (context, index) {
                      var performance = employeePerformance[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                        child: ListTile(
                          title: Text(performance['employee'], style: TextStyle(fontSize: 16.sp)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("In Process: ${performance['inProcess']}", style: TextStyle(fontSize: 14.sp, color: Colors.blue)),
                              Text("Completed: ${performance['done']}", style: TextStyle(fontSize: 14.sp, color: Colors.green)),
                            ],
                          ),
                          trailing: Text(
                            "Total: ${performance['inProcess'] + performance['done']}",
                            style: TextStyle(fontSize: 14.sp),
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