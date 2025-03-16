import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // textTheme: GoogleFonts.poppinsTextTheme(),
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
    );
  }
}
