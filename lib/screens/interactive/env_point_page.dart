import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';


class EnvPointPage extends StatefulWidget {
  const EnvPointPage({super.key});

  @override
  State createState() => _EnvPointPageState();
}

class _EnvPointPageState extends State<EnvPointPage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  Timer? _timer;

  var _future = Supabase.instance.client.from('ids').select();

  @override
  void initState() {
    super.initState();
   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
     _future = Supabase.instance.client.from('ids').select();
   });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff181A20),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            '환경점수',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff181A20),
          elevation: 0,
        ),
        body: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'),)
          : Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.vertical,
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  constraints: const BoxConstraints.expand(),
                  decoration: BoxDecoration(border: Border.all()),
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder<dynamic>(
                      valueListenable: result,
                      builder: (context, value, _) =>
                        Text('${value ?? ''}', style: const TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: GridView.count(
                  padding: const EdgeInsets.all(4),
                  crossAxisCount: 2,
                  childAspectRatio: 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  children: [
                    ElevatedButton(
                      onPressed: _tagRead,
                      child: const Text('Tag Read'),
                    ),
                  ],
                ),
              )
            ],

          ),
        ));
  }
  
  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var temp = tag.data;
      debugPrint(temp['nfca']['identifier']);
      result.value = temp['nfca']['identifier'];
      NfcManager.instance.stopSession();
    });
  }
}
