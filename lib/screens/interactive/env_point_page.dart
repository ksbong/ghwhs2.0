import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';

class EnvPointPage extends StatefulWidget {
  const EnvPointPage({super.key});

  @override
  State createState() => _EnvPointPageState();
}

class _EnvPointPageState extends State<EnvPointPage> {
  ValueNotifier<String> result = ValueNotifier("NFC를 태그해주세요.");
  late String _nfcID;

  @override
  void initState() {
    super.initState();
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var id = tag.data['id'] as Uint8List?;
        if (id == null) {
          result.value = 'NFC 태그가 아닙니다.';
          NfcManager.instance.stopSession(errorMessage: 'NFC 태그가 아닙니다.');
          return;
        }

        String nfcID = identifierToHexString(id);


        result.value = '태그 ID: $nfcID';
        _nfcID = nfcID;


        final existingIDResponse = await Supabase.instance.client
            .from('ids')
            .select()
            .eq('id', nfcID);



        // if (existingIDResponse.hasError) {
        //   result.value = '데이터베이스 오류가 발생했습니다.';
        //   NfcManager.instance.stopSession(errorMessage: '데이터베이스 오류가 발생했습니다.');
        //   return;
        // }

        if (existingIDResponse.isEmpty) {
          result.value = 'ID가 존재하지 않습니다. 등록 버튼을 눌러주세요.';
        } else {
          var fetchedData = existingIDResponse[0];
          result.value = 'ID: $nfcID, Points: ${fetchedData['point']}';
        }

        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = '오류가 발생했습니다.';
        NfcManager.instance.stopSession(errorMessage: '오류가 발생했습니다.');
      }
    });
  }

  Future<void> _registerID() async {
    final existingIDResponse = await Supabase.instance.client
        .from('ids')
        .select()
        .eq('id', _nfcID);

    // if (existingIDResponse.hasError) {
    //   result.value = '데이터베이스 오류가 발생했습니다.';
    //   return;
    // }

    if (existingIDResponse.isNotEmpty) {
      result.value = 'ID가 이미 존재합니다.';
      return;
    }

    final response = await Supabase.instance.client
        .from('ids')
        .insert({'id': _nfcID, 'point': 0});

    if (response.hasError) {
      result.value = 'ID 추가 중 오류가 발생했습니다.';
    } else {
      result.value = 'ID가 성공적으로 등록되었습니다.';
    }
  }

  String identifierToHexString(Uint8List identifier) {
    return identifier.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
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
      body: Flex(
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
                child: ValueListenableBuilder<String>(
                  valueListenable: result,
                  builder: (context, value, _) => Center(
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
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
                  child: const Text('태그 읽기'),
                ),
                ElevatedButton(
                  onPressed: _registerID,
                  child: const Text('등록'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
