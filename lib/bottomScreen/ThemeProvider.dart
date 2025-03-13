// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   ThemeMode get themeMode => _themeMode;

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }

//   Future<void> toggleTheme(bool isDark) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkMode', isDark);
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
// }
