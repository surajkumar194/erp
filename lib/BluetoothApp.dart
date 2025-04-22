// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';


// class BluetoothPrintPage extends StatefulWidget {
//   const BluetoothPrintPage({super.key});

//   @override
//   _BluetoothPrintPageState createState() => _BluetoothPrintPageState();
// }

// class _BluetoothPrintPageState extends State<BluetoothPrintPage> {
//   // final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
//   List<ScanResult> scannedDevices = [];
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? writableCharacteristic;
//   TextEditingController _controller = TextEditingController();
//   bool isScanning = false;

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//   }

//   Future<void> _requestPermissions() async {
//     await [
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location,
//     ].request();
//   }

//   void startScan() {
//     setState(() {
//       scannedDevices.clear();
//       isScanning = true;
//     });

//     FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

//     FlutterBluePlus.scanResults.listen((results) {
//       for (var r in results) {
//         if (!scannedDevices.any((d) => d.device.id == r.device.id)) {
//           setState(() {
//             scannedDevices.add(r);
//           });
//         }
//       }
//     }).onDone(() {
//       setState(() {
//         isScanning = false;
//       });
//     });
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await FlutterBluePlus.stopScan();

//     setState(() {
//       connectedDevice = device;
//     });

//     await device.connect(timeout: Duration(seconds: 10)).catchError((e) {});
//     discoverServices(device);
//   }

//   Future<void> discoverServices(BluetoothDevice device) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         if (characteristic.properties.write) {
//           setState(() {
//             writableCharacteristic = characteristic;
//           });
//           return;
//         }
//       }
//     }
//     print('No writable characteristic found!');
//   }

//   void sendToPrinter(String text) async {
//     if (writableCharacteristic == null) return;
//     List<int> bytes = utf8.encode("$text\n\n");
//     await writableCharacteristic!.write(bytes, withoutResponse: true);
//     print('Sent to printer');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Bluetooth BLE Print")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: startScan,
//               child: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
//             ),
//             SizedBox(height: 10),
//             DropdownButton<BluetoothDevice>(
//               hint: Text("Select a Device"),
//               value: connectedDevice,
//               items: scannedDevices.map((r) {
//                 return DropdownMenuItem(
//                   value: r.device,
//                   child: Text(r.device.name.isNotEmpty
//                       ? r.device.name
//                       : r.device.id.toString()),
//                 );
//               }).toList(),
//               onChanged: (device) {
//                 if (device != null) connectToDevice(device);
//               },
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "Text to Print",
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 if (_controller.text.isNotEmpty) {
//                   sendToPrinter(_controller.text);
//                   _controller.clear();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Text sent to printer")),
//                   );
//                 }
//               },
//               child: Text("Print"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     connectedDevice?.disconnect();
//     super.dispose();
//   }
// }
