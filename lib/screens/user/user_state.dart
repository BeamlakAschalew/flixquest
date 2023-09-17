import 'package:easy_localization/easy_localization.dart';
import '/main.dart';
import '/screens/common/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        // ignore: missing_return
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const CinemaxHomePage();
          } else if (userSnapshot.connectionState == ConnectionState.active) {
            if (userSnapshot.hasData) {
              //  print('The user is already logged in');
              return const CinemaxHomePage();
            } else {
              // print('The user didn\'t login yet');
              return const LandingScreen();
            }
          } else {
            return Center(
              child: Text(tr("error_occured")),
            );
          }
        });
  }
}
