import 'package:flutter/material.dart';
import 'package:ghwhs_app_flutter/screens/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  String apiKey = dotenv.env['SUPABASE_API_KEY'] ?? '';
  await Supabase.initialize(url: 'https://pnoqycbessomqckuydrc.supabase.co', anonKey: apiKey);

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
