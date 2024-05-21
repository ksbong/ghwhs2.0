import 'package:flutter/material.dart';
import 'package:ghwhs_app_flutter/components/widgets/school/student_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghwhs_app_flutter/screens/interactive/login_type_page.dart';
import 'package:ghwhs_app_flutter/screens/interactive/student_edit.dart';

import 'dart:async';

FlutterSecureStorage storage = const FlutterSecureStorage();

class StudentIDPage extends StatefulWidget {
  const StudentIDPage({super.key});

  @override
  State<StudentIDPage> createState() => _StudentIDPageState();
}

class _StudentIDPageState extends State<StudentIDPage> {
  bool isLoggedIn = false; // 로그인 상태를 저장할 변수

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<Map<String, dynamic>> fetchData() async {
    String? grade1 = await storage.read(key: 'grade1');
    String? grade2 = await storage.read(key: 'grade2');
    String? grade3 = await storage.read(key: 'grade3');

    String? storedName = await storage.read(key: 'name');
    List<String> nameList = [];

    String? storedBday = await storage.read(key: 'bday');

    String? storedID = await storage.read(key: 'studentID');

    String? bDay = await storage.read(key: 'bday');

    if (storedName != null) {
      for (int i = 0; i < storedName.length; i++) {
        nameList.add(storedName[i]);
      }
    }

    List<dynamic>? temp = bDay?.split('.');

    String validYearStart = (int.parse(temp?[0]) + 16).toString();
    String validYearEnd = (int.parse(temp?[0]) + 16 + 3).toString();

    return {
      "name": nameList,
      "grade1": grade1,
      "grade2": grade2,
      "grade3": grade3,
      "bday": storedBday,
      "studentID": storedID,
      "validYearStart": validYearStart,
      "validYearEnd": validYearEnd
    };
  }

  Future<void> checkLoginStatus() async {
    const storage = FlutterSecureStorage();
    String loggedIn = await storage.read(key: 'isLoggedIn') ?? 'false';
    setState(() {
      isLoggedIn = loggedIn == 'true';
    });
  }

  String isTeacher = 'false';

  void fetchDataTeacher() async {
    String? storedStateT = await storage.read(key: 'teacher');

    setState(() {
      isTeacher = storedStateT ?? 'false';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            '모바일 학생증',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff181A20),
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentIDEditPage())),
              child: const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        backgroundColor: const Color(0xff181A20),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
                child: isLoggedIn
                    ? isTeacher == 'false'
                        ? FutureBuilder(
                            future: fetchData(),
                            builder: (context, snapshot) {
                              return snapshot.hasData
                                  ? IDCard(
                                      storedName: snapshot.data?["name"],
                                      storedBday: snapshot.data?["bday"],
                                      grade1: snapshot.data?["grade1"],
                                      grade2: snapshot.data?["grade2"],
                                      grade3: snapshot.data?["grade3"],
                                      storedID: snapshot.data?["studentID"],
                                      validYearStart:
                                          snapshot.data?["validYearStart"],
                                      validYearEnd:
                                          snapshot.data?["validYearEnd"],
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ));
                            })
                        : const Text(
                            '선생님께는 학생증 기능이 제공되지 않습니다.',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                    : const LogInTypePage())));
  }
}
