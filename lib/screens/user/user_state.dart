import 'package:easy_localization/easy_localization.dart';
import '../../flixquest_main.dart';
import '/screens/common/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const FlixQuestHomePage();
          } else if (userSnapshot.connectionState == ConnectionState.active) {
            if (userSnapshot.hasData) {
              return const FlixQuestHomePage();
            } else {
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
