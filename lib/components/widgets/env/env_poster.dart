import 'package:flutter/material.dart';
import 'package:ghwhs_app_flutter/screens/view/env/env_poster_page.dart';
import '../../component.dart';

Widget envPoster(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(context,
           MaterialPageRoute(builder: (context) => const EnvPosterPage()));
      },
      child: buildComponent(
          120,
          MediaQuery.of(context).size.width,
          Stack(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 22, bottom: 15),
                    child: Text(
                      '이달의 포스터',
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
                          'assets/logo.png',
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
                          '이번달 선정 포스터',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '포스터 보러 가기',
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
