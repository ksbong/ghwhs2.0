import 'package:flutter/material.dart';
import 'package:ghwhs_app_flutter/screens/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {

  await Supabase.initialize(url: 'https://pnoqycbessomqckuydrc.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBub3F5Y2Jlc3NvbXFja3V5ZHJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyODMwNTIsImV4cCI6MjAzNjg1OTA1Mn0.L5aYxLZkFmyJEBojb0NxO1HMsJoUou_Sa_EPwwF4G8Q');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: '광혜원고',
        debugShowCheckedModeBanner: false,
        // home: TestComponent(),
        home: HomePage());
  }
}
