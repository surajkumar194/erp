import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _capturedImage;
  String? _dateTime;
  String? _location;

  final double allowedLatitude = 30.9009329;
  final double allowedLongitude = 75.8323451;
  final double allowedRadius = 500;

  Map<int, String> attendanceRecords = {};
  Map<int, String> lateTimings = {};
  Map<int, String> overtimeHours = {};
  Map<int, String> startTimes = {};
  Map<int, String> endTimes = {};
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String selectedYear = DateFormat('yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _initializeCamera();
  }

  Future<void> _initializeCamera([int cameraIndex = 0]) async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No camera found")),
      );
      return;
    }

    _selectedCameraIndex = cameraIndex;
    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } catch (e) {
      print("Camera Initialization Error: $e");
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.isEmpty) return;
    int newIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    _initializeCamera(newIndex);
  }

  Future<void> _captureAttendance() async {
    if (await _requestPermissions()) {
      Position position = await _determinePosition();
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, allowedLatitude, allowedLongitude);

      if (distance > allowedRadius) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not in the allowed location to mark attendance")),
        );
        return;
      }

      try {
        await _initializeControllerFuture;
        final image = await _controller!.takePicture();
        DateTime now = DateTime.now();
        int day = now.day;

        File imageFile = File(image.path);
        String fileName = '${DateFormat('yyyyMMdd_HHmmss').format(now)}.jpg';

        final ref = FirebaseStorage.instance.ref().child('attendance_images').child(fileName);
        await ref.putFile(imageFile);
        String downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('attendance').add({
          'imageUrl': downloadUrl,
          'timestamp': now.toIso8601String(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'status': startTimes.containsKey(day) ? 'End' : 'Start',
          'day': day,
          'month': selectedMonth,
          'year': selectedYear,
        });

        setState(() {
          _capturedImage = imageFile;
          _dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
          _location = "Lat: ${position.latitude}, Long: ${position.longitude}";

          if (!startTimes.containsKey(day)) {
            startTimes[day] = DateFormat('HH:mm:ss').format(now);
            attendanceRecords[day] = "Present";
          } else {
            endTimes[day] = DateFormat('HH:mm:ss').format(now);
          }

          DateTime officeStartTime = DateTime(now.year, now.month, now.day, 9, 0, 0);
          DateTime officeEndTime = DateTime(now.year, now.month, now.day, 18, 0, 0);

          lateTimings[day] = now.isAfter(officeStartTime)
              ? "Late: ${now.difference(officeStartTime).inMinutes} mins"
              : "On Time";

          overtimeHours[day] = now.isAfter(officeEndTime)
              ? "Overtime: ${now.difference(officeEndTime).inMinutes} mins"
              : "No Overtime";
        });
      } catch (e) {
        print("Error capturing image: $e");
      }
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
    ].request();

    if (statuses[Permission.location] != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required")),
      );
      return false;
    }

    if (statuses[Permission.camera] != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required")),
      );
      return false;
    }

    return true;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Attendance")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipOval(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 4),
                  ),
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _captureAttendance,
            child: const Text("Capture Attendance"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _switchCamera,
            child: const Text("Switch Camera"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Start Time')),
                    DataColumn(label: Text('End Time')),
                    DataColumn(label: Text('Late Timing')),
                    DataColumn(label: Text('Overtime')),
                  ],
                  rows: List.generate(31, (index) {
                    int day = index + 1;
                    return DataRow(cells: [
                      DataCell(Text('$day/${DateFormat('MM/yyyy').format(DateTime(int.parse(selectedYear), DateFormat('MMMM').parse(selectedMonth).month))}')),
                      DataCell(Text(attendanceRecords[day] ?? 'Absent')),
                      DataCell(Text(startTimes[day] ?? 'N/A')),
                      DataCell(Text(endTimes[day] ?? 'N/A')),
                      DataCell(Text(lateTimings[day] ?? 'N/A')),
                      DataCell(Text(overtimeHours[day] ?? 'N/A')),
                    ]);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
