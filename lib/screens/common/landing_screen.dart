import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../flixquest_main.dart';
import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '../../services/globle_method.dart';
import '/provider/settings_provider.dart';
import '/screens/user/login_screen.dart';
import '/screens/user/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool anonButtonVisible = true;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    // void updateFirstRunData() async {
    //   final sharedPrefsSingleton = await SharedPreferences.getInstance();
    //   await sharedPrefsSingleton.setBool('isFirstRun', false);
    // }

    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                            fontFamily: 'FigtreeBold',
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
                                  height: 100,
                                  width: 100,
                                  child: Hero(
                                    tag: 'logo_shadow',
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Image.asset('assets/images/logo.png'),
                                    ),
                                  ),
                                ),
                              ),
                              Text(tr('thousands_of'),
                                  style: const TextStyle(color: Colors.black)),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      animatedTextWIdget(
                                          textTitle: tr('top_rated_movies'),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr('top_rated_tv_shows'),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr('trending_movies'),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr('trending_tv_shows'),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr('popular_movies'),
                                          animationDuration: 90,
                                          fontSize: 25),
                                      animatedTextWIdget(
                                          textTitle: tr('popular_tv_shows'),
                                          animationDuration: 90,
                                          fontSize: 25),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  tr('unlimited_on_cinemax'),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      //  crossAxisAlignment: WrapCrossAlignment.start,
                      // spacing: 10,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                    const Size(150, 50)),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                    const Color(0xFFf57c00))),
                            onPressed: () async {
                              // updateFirstRunData();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const LoginScreen();
                              }));
                            },
                            child: Text(
                              tr('log_in'),
                              style: const TextStyle(color: Colors.white),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                    const Size(150, 50)),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.white)),
                            onPressed: () async {
                              // updateFirstRunData();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const SignupScreen();
                              }));
                            },
                            child: Text(
                              tr('sign_up'),
                              style: const TextStyle(color: Colors.black),
                            )),
                        const SizedBox(
                          height: 40,
                        ),
                        anonButtonVisible
                            ? ElevatedButton(
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        const Size(150, 50)),
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color(0xFFfad2aa))),
                                onPressed: () async {
                                  // Use async/await with mounted checks and error handling
                                  if (!mounted) return;
                                  setState(() {
                                    anonButtonVisible = false;
                                  });

                                  try {
                                    final connected = await checkConnection();
                                    if (!connected && mounted) {
                                      // Restore button and show connection message
                                      setState(() {
                                        anonButtonVisible = true;
                                      });
                                      GlobalMethods.showCustomScaffoldMessage(
                                          SnackBar(
                                            content: Text(
                                              tr('check_connection'),
                                              maxLines: 3,
                                              style: kTextSmallBodyStyle,
                                            ),
                                            duration:
                                                const Duration(seconds: 3),
                                          ),
                                          context);
                                    }

                                    // Attempt anonymous sign-in
                                    await auth.signInAnonymously();
                                    mixpanel.track('Anonymous Login');

                                    if (!mounted) return;
                                    setState(() {
                                      anonButtonVisible = true;
                                    });

                                    if (!mounted) return;
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const FlixQuestHomePage();
                                    }));
                                  } catch (e) {
                                    // Restore button and show an error message
                                    if (mounted) {
                                      setState(() {
                                        anonButtonVisible = true;
                                      });
                                      GlobalMethods.showCustomScaffoldMessage(
                                          SnackBar(
                                            content: Text(
                                              e.toString(),
                                              maxLines: 3,
                                              style: kTextSmallBodyStyle,
                                            ),
                                            duration:
                                                const Duration(seconds: 3),
                                          ),
                                          context);
                                    }
                                  }
                                },
                                child: Text(
                                  tr('continue_anonymously'),
                                  style: const TextStyle(color: Colors.black),
                                ))
                            : const CircularProgressIndicator()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
