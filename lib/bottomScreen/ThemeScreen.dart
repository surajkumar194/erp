// import 'package:erp/bottomScreen/ThemeProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class ThemeScreen extends StatelessWidget {
//   const ThemeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Theme Settings")),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
//             title: const Text("Dark Mode"),
//             trailing: Switch(
//               value: themeProvider.themeMode == ThemeMode.dark,
//               onChanged: (value) {
//                 themeProvider.toggleTheme(value);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
