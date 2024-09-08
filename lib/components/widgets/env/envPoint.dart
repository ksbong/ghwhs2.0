import 'package:flutter/material.dart';
import 'package:ghwhs_app_flutter/screens/interactive/env_point_page.dart';
import '../../component.dart';
// import 'package:http/http.dart' as http;

class EnvPoint extends StatefulWidget {
  const EnvPoint({super.key});

  @override
  State createState() => _EnvPointState();
}

class _EnvPointState extends State<EnvPoint> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () =>Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EnvPointPage(),
            )),
        child: buildComponent(
            120,
            MediaQuery
                .of(context)
                .size
                .width,
            Stack(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 22, bottom: 15),
                      child: Text(
                        '환경 점수',
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
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 30),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/plant.png',
                            fit: BoxFit.fill,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '나의 분리수거 점수는?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '내 점수 보러가기',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}