import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvPointPage extends StatefulWidget {
  const EnvPointPage({super.key});

  @override
  State createState() => _EnvPointPageState();
}

class _EnvPointPageState extends State<EnvPointPage> {
  ValueNotifier<String> result = ValueNotifier("NFC를 태그해주세요.");
  late String _nfcID;
  final TextEditingController _codeController = TextEditingController();
  bool isRegistering = false;

  String reqKey = dotenv.env['REQUIRED_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        final ndef = Ndef.from(tag);
        if (ndef == null) {
          result.value = 'NFC 태그가 NDEF 메시지를 지원하지 않습니다.';
          NfcManager.instance.stopSession(errorMessage: 'NFC 태그가 NDEF 메시지를 지원하지 않습니다.');
          return;
        }

        final NdefMessage ndefMessage = await ndef.read();

        final NdefRecord ndefRecord = ndefMessage.records.first;
        final String nfcID = String.fromCharCodes(ndefRecord.payload);

        result.value = '태그 ID: $nfcID';
        _nfcID = nfcID;

        final existingIDResponse = await Supabase.instance.client
            .from('ids')
            .select()
            .eq('id', nfcID);


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
    setState(() {
      isRegistering = true;
    });

    final code = _codeController.text;
    var requiredCode = reqKey; // 여기서 코드를 서버에서 받아올 수도 있습니다.

    if (code != requiredCode) {
      result.value = '코드가 일치하지 않습니다. 등록할 수 없습니다.';
      setState(() {
        isRegistering = false;
      });
      return;
    }

    final existingIDResponse = await Supabase.instance.client
        .from('ids')
        .select()
        .eq('id', _nfcID);



    if (existingIDResponse.isNotEmpty) {
      result.value = 'ID가 이미 존재합니다.';
      setState(() {
        isRegistering = false;
      });
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

    setState(() {
      isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181A20),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // NFC
            Card(
              color: const Color(0xff1f2128),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: ValueListenableBuilder<String>(
                  valueListenable: result,
                  builder: (context, value, _) => Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: '등록 코드 입력',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: const Color(0xff1f2128),
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: isRegistering ? null : _tagRead,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('태그 읽기'),
                    ),
                    ElevatedButton(
                      onPressed: isRegistering ? null : _registerID,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        backgroundColor: isRegistering
                            ? Colors.grey
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isRegistering
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text('등록'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
