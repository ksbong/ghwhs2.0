import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MealPageTomorrow extends StatefulWidget {
  const MealPageTomorrow({super.key});

  @override
  State createState() => _MealPageState();
}

class _MealPageState extends State<MealPageTomorrow> {
  var breakFast = '', lunch = '', dinner = '';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      getMeal();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> getMeal() async {
    DateTime now = DateTime.now().add(const Duration(days: 1));
    String tomorrow = DateFormat('yyyyMMdd').format(now);
    String url =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=M10&SD_SCHUL_CODE=8000032&MLSV_YMD=$tomorrow';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var body = json.decode(response.body)["mealServiceDietInfo"];
      int lenOfMeal = body[0]["head"][0]["list_total_count"];

      var mealBody = body[1]["row"];
      // ["MMEAL_SC_NM"]
      switch(lenOfMeal) {
        case 1: {
          if (mealBody[0]["MMEAL_SC_NM"] == '조식') {
            setState(() {
              breakFast = mealBody[0]["DDISH_NM"];
              lunch = '오늘은 중식이 없어유';
              dinner = '오늘은 석식이 없어유';
            });
          } else {
            setState(() {
              breakFast = '오늘은 조식이 없어유';
              lunch = mealBody[0]["DDISH_NM"];
              dinner = '오늘은 석식이 없어유';
            });
          }
        } break;
        case 2: {
          if (mealBody[0]["MMEAL_SC_NM"] == '조식') {
            setState(() {
              breakFast = mealBody[0]["DDISH_NM"];
              lunch = mealBody[1]["DDISH_NM"];
              dinner = '오늘은 석식이 없어유';
            });
          } else {
            setState(() {
              breakFast = '오늘은 조식이 없어유';
              lunch = mealBody[0]["DDISH_NM"];
              dinner = mealBody[1]["DDISH_NM"];
            });
          }
        } break;

        case 3: {
          setState(() {
            breakFast = mealBody[0]["DDISH_NM"];
            lunch = mealBody[1]["DDISH_NM"];
            dinner = mealBody[2]["DDISH_NM"];
          });
        } break;

        default: {
          setState(() {
            breakFast = '문제가 생겼나봐유';
            lunch = '문제가 생겼나봐유';
            dinner = '문제가 생겼나봐유';
          });
        } break;

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
            '급식 정보',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff181A20),
          elevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      DateFormat('yyyy년MM월dd일').format(DateTime.now().add(const Duration(days: 1))),
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        mealCard('조식', breakFast),
                        const SizedBox(
                          height: 40,
                        ),
                        mealCard('중식', lunch),
                        const SizedBox(
                          height: 40,
                        ),
                        mealCard('석식', dinner),
                      ])
                ],
              ),
            )));
  }

  Widget mealCard(String title, String content) {
    getMeal();
    List<String> stringList = content
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('.', '')
        .split("<br/>");
    //List<String> stringList =  ['꼬들꼬들오이지무침' , '애호박볶음' , '배추김치 ', '진한초코 ', '우렁이된장찌개' , '친환경흰쌀밥 '];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(
          height: 5,
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: stringList
                .map((text) => Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ))
                .toList())
      ],
    );
  }
}
