import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> test() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: 'https://pnoqycbessomqckuydrc.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBub3F5Y2Jlc3NvbXFja3V5ZHJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyODMwNTIsImV4cCI6MjAzNjg1OTA1Mn0.L5aYxLZkFmyJEBojb0NxO1HMsJoUou_Sa_EPwwF4G8Q');

  runApp(const Test());
}

class Test extends StatelessWidget {
  const Test({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Supabase Flutter Test',
        home: TestPage()
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  var _future = Supabase.instance.client.from('ids').select();

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client.from('ids').select();
  }

  Future<void> _updateData(String id, int newData) async {
    final response = await Supabase.instance.client.from('ids')
        .update({'point': newData}).eq('id', id);

    if (response.error != null) {
      debugPrint('Error updating point: ${response.error!.message}');
    } else {
      debugPrint('Point updated successfully');
      setState(() {
        _future = Supabase.instance.client
            .from('ids').select();
      });
    }
  }

  Future<void> _addID(String id) async {
    final existingIDResponse = await Supabase.instance.client
        .from('ids')
        .select()
        .eq('id', id);

    if (existingIDResponse.isNotEmpty) {
      debugPrint('ID already exists');
      return;
    }

    final response = await Supabase.instance.client
        .from('ids')
        .insert({'id': id});

    if (response.error != null) {
      debugPrint('Error adding ID: ${response.error!.message}');
    } else {
      debugPrint('ID added successfully');
      setState(() {
        _future = Supabase.instance.client
            .from('ids')
            .select();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Test'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final ids = snapshot.data;
          return ListView.builder(
            itemCount: ids!.length,
            itemBuilder: (context, index) {
              final id = ids[index];
              return ListTile(
                title: Text('${id['point']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _updateData('test', 19),
        child: const Icon(Icons.plus_one),
      ),
    );
  }
}
