import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/models/custom_exceptions.dart';
import 'package:flutter/material.dart';

class GlobalMethods {
  Future<void> showCustomDialog(
      String title, String subtitle, Function fct, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Image.network(
                    'https://image.flaticon.com/icons/png/128/564/564619.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title),
                ),
              ],
            ),
            content: Text(subtitle),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr("cancel"))),
              TextButton(
                  onPressed: () {
                    fct();
                    Navigator.pop(context);
                  },
                  child: Text(tr("ok")))
            ],
          );
        });
  }

  Future<void> authErrorHandle(String subtitle, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(tr("error_occured")),
                ),
              ],
            ),
            content: Text(subtitle),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(tr("ok")))
            ],
          );
        });
  }

  Future<void> checkMessage(String subtitle, BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text(subtitle),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(tr("ok")))
            ],
          );
        });
  }

  Future<void> passwordResetException(
      String subtitle, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(tr("error_occured")),
                ),
              ],
            ),
            content: Text(subtitle),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(tr("ok")))
            ],
          );
        });
  }

  //TODO: translate Server is down or media is not found
  static void showErrorScaffoldMessengerMediaLoad(
      Exception error, BuildContext context, String server) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      error is TimeoutException
          ? 'Error: Fetch timed out'
          : error is SocketException
              ? 'Error: Connection problem'
              : error is NotFoundException
                  ? 'Error: media is not found on $server Server'
                  : error is ServerDownException
                      ? 'Error: $server Server is down ${error.toString()}'
                      : 'Error: ${error.toString()}',
      style: const TextStyle(fontFamily: 'Poppins'),
    )));
  }

  static void showErrorScaffoldMessengerGeneral(
      Exception error, BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      error is TimeoutException
          ? 'Error: Fetch timed out'
          : error is SocketException
              ? 'Error: Connection problem'
              : 'Error: ${error.toString()}',
      style: const TextStyle(fontFamily: 'Poppins'),
    )));
  }
}
