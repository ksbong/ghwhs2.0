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
    DateTime now = DateTime.now();
    String today = DateFormat('yyyyMMdd').format(now);
    String url =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=M10&SD_SCHUL_CODE=8000032&MLSV_YMD=$today';

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
