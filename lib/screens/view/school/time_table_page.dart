import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  String apiKey = dotenv.env['API_KEY'] ?? '';
  String selectedGrade = '3';
  String selectedClass = '4';
  List<String> grades = ['1', '2', '3'];
  List<String> classes = ['1', '2', '3', '4', '5'];

  late Future<List<dynamic>> timetableFuture;

  @override
  void initState() {
    super.initState();
    timetableFuture = timeTable();
  }

  Future<List<dynamic>> timeTable() async {
    String today = DateFormat('yyyyMMdd').format(DateTime.now());
    String apiKey = dotenv.env['NEIS_API_KEY'] ?? '';

    var url = Uri.parse(
        'https://open.neis.go.kr/hub/hisTimetable?KEY=$apiKey&Type=json&ATPT_OFCDC_SC_CODE=M10&SD_SCHUL_CODE=8000032&GRADE=$selectedGrade&CLRM_NM=$selectedClass&ALL_TI_YMD=$today'
    );

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

      // JSON 응답이 무엇인지 로그로 출력해 디버깅
      print(jsonResponse);

      if (jsonResponse.containsKey('hisTimetable') && jsonResponse['hisTimetable'][1].containsKey('row')) {
        return jsonResponse['hisTimetable'][1]['row'] as List<dynamic>;
      } else {
        return []; // 데이터가 없으면 빈 리스트 반환
      }
    } else {
      throw Exception('Failed to load timetable');
    }
  }

  void updateTimetable() {
    setState(() {
      timetableFuture = timeTable();
    });
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
            onPressed: () => Navigator.of(context).pop()
        ),
        title: const Text('시간표', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xff181A20),
      ),
      body: Column(
        children: [
          Center(
              child: Text(
                DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 20),
              )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown for Grade selection
                DropdownButton<String>(
                  value: selectedGrade,
                  dropdownColor: const Color(0xff282A36),
                  style: const TextStyle(color: Colors.white),
                  items: grades.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGrade = newValue!;
                    });
                    updateTimetable(); // Update timetable when grade is changed
                  },
                ),
                const Text('학년', style: TextStyle(color: Colors.white),),
                const SizedBox(width: 16),
                // Dropdown for Class selection
                DropdownButton<String>(
                  value: selectedClass,
                  dropdownColor: const Color(0xff282A36),
                  style: const TextStyle(color: Colors.white),
                  items: classes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClass = newValue!;
                    });
                    updateTimetable(); // Update timetable when class is changed
                  },
                ),
                const Text('반', style: TextStyle(color: Colors.white),)
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: timetableFuture, // Use the updated future
              builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (DateFormat('E').format(DateTime.now()) == 'Sat' || DateFormat('E').format(DateTime.now()) == 'Sun') {
                    return const Center(child: Text('시간표가 없나봐유~', style: TextStyle(color: Colors.white),),);
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('시간표를 불러오는데 오류가 발생했습니다.', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text('시간표가 없나봐유~', style: TextStyle(color: Colors.white)));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var timetable = snapshot.data![index];
                      String period = timetable['PERIO'] ?? '';
                      String subject = timetable['ITRT_CNTNT'] ?? '';

                      return Card(
                        color: const Color(0xff282A36),
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: ListTile(
                          title: Text(
                            '$period교시',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            subject,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
