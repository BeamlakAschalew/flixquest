import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cinemax/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    void updateFirstRunData() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstRun', false);
    }

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: deviceHeight,
          width: deviceWidth,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/images/grid_final.jpg',
                ),
                fit: BoxFit.cover),
          ),
          child: Container(
            decoration: const BoxDecoration(
              // color: Colors.black.withOpacity(0.5),
              gradient: LinearGradient(
                colors: [Color(0xff000000), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            height: 400,
            width: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFF57C00),
            ),
            child: Center(
                child: SizedBox(
              width: 250.0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'PoppinsBold',
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/logo_shadow.png'),
                        ),
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const Text('Thousands of:',
                        style: TextStyle(color: Colors.black)),
                    SizedBox(
                      height: 75,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            animatedTextWIdget(
                                textTitle: 'Top rated movies',
                                animationDuration: 90,
                                fontSize: 25),
                            animatedTextWIdget(
                                textTitle: 'Top rated tv shows',
                                animationDuration: 90,
                                fontSize: 25),
                            animatedTextWIdget(
                                textTitle: 'Trending movies',
                                animationDuration: 90,
                                fontSize: 25),
                            animatedTextWIdget(
                                textTitle: 'Trending tv shows',
                                animationDuration: 90,
                                fontSize: 25),
                            animatedTextWIdget(
                                textTitle: 'Popular movies',
                                animationDuration: 90,
                                fontSize: 25),
                            animatedTextWIdget(
                                textTitle: 'Popular tv shows',
                                animationDuration: 90,
                                fontSize: 25),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Unlimited, for free, any time on Cinemax',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          onPressed: () async {
                            updateFirstRunData();
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const CinemaxHomePage();
                            }));
                          },
                          child: const Text(
                            'GET STARTED',
                            style: TextStyle(color: Colors.black),
                          )),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }

  TypewriterAnimatedText animatedTextWIdget(
      {required String textTitle,
      required int animationDuration,
      required double fontSize}) {
    return TypewriterAnimatedText(textTitle,
        speed: Duration(milliseconds: animationDuration),
        textStyle: TextStyle(
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center);
  }
}
