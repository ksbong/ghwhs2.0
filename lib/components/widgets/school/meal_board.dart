import 'package:flutter/material.dart';
import 'package:ghwhs_app_flutter/components/component.dart';
import 'package:ghwhs_app_flutter/screens/view/school/meal_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';

class MealBoard extends StatefulWidget {
  const MealBoard({super.key});

  @override
  State createState() => MealBoardState();
}

class MealBoardState extends State<MealBoard> {
  var breakFast = '', lunch = '', dinner = '';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
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
    String today = DateFormat('yyyyMMdd').format(now);
    String url =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=M10&SD_SCHUL_CODE=8000032&MLSV_YMD=$today';

    DateTime tomorrow = now.add(const Duration(days: 1));
    String tomorrowDate = DateFormat('yyyyMMdd').format(tomorrow);
    String tomorrowURL =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=M10&SD_SCHUL_CODE=8000032&MLSV_YMD=$tomorrowDate';
    final response = await http.get(Uri.parse(url));
    final tomorrowResponse = await http.get(Uri.parse(tomorrowURL));

    String tomorrowYoil = DateFormat('E').format(tomorrow);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      try {
        var root = body['mealServiceDietInfo'][1]['row'];
        try {
          setState(() {
            breakFast = root[0]['DDISH_NM'];
            lunch = root[1]['DDISH_NM'];
            dinner = root[2]['DDISH_NM'];
          });
        } catch (e) {
          try {
            try {
              if (tomorrowResponse.statusCode == 200) {
                final body = json.decode(tomorrowResponse.body);
                var root = body['mealServiceDietInfo'][1]['row'];

                if (tomorrowYoil != 'Fri') {
                  debugPrint(root[0]['DDISH_NM']);
                  debugPrint(root[1]['DDISH_NM']);
                  debugPrint(root[2]['DDISH_NM']);
                }

                setState(() {
                  breakFast = '오늘은 조식이 없습니다.';
                  lunch = root[0]['DDISH_NM'];
                  dinner = root[1]['DDISH_NM'];
                });
              }
            } catch (e) {
              setState(() {
                breakFast = root[0]['DDISH_NM'];
                lunch = root[1]['DDISH_NM'];
                dinner = '오늘은 석식이 없습니다.';
              });
            }

          } catch (e) {
            setState(() {
              breakFast = '오늘은 조식이 없습니다.';
              lunch = root[0]['DDISH_NM'];
              dinner = '오늘은 석식이 없습니다.';
            });
          }
        }
      } catch (e) {
        // print(e);
        setState(() {
          breakFast = '오늘은 조식이 없습니다.';
          lunch = '오늘은 중식이 없습니다.';
          dinner = '오늘은 석식이 없습니다.';
        });
      }
    } else {
      // ignore: avoid_print
      print("Failed: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildComponent(
        250,
        MediaQuery.of(context).size.width,
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MealPage()));
          },
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 22, bottom: 15),
                    child: Text(
                      '급식',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20, right: 10, top: 10),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              // 급식 here
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [mealCard('중식', lunch), mealCard('석식', dinner)],
              )
            ],
          ),
        ));
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(
          height: 5,
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stringList
                .map((text) => Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ))
                .toList())
      ],
    );
  }
}
