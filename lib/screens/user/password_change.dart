import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_constants.dart';
import '../../services/globle_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);

  @override
  PasswordChangeScreenState createState() => PasswordChangeScreenState();
}

class PasswordChangeScreenState extends State<PasswordChangeScreen> {
  String currentPassword = '';
  String newPassword = '';
  bool _obscureText = true;
  User? user;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalMethods _globalMethods = GlobalMethods();
  bool _isLoading = false;
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _passwordVerifyFocusNode = FocusNode();
  String? _emailAddress;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = _auth.currentUser;
    setState(() {
      _emailAddress = user!.email;
    });
  }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        user = _auth.currentUser;

        await user!.updatePassword(newPassword).then((value) {
          GlobalMethods.showCustomScaffoldMessage(
              SnackBar(
                content: Text(
                  tr("password_changed"),
                  maxLines: 3,
                  style: kTextSmallBodyStyle,
                ),
                duration: const Duration(seconds: 4),
              ),
              context);
        });
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          if (e.code == 'user-mismatch') {
            _globalMethods.authErrorHandle(tr("user_mismatch"), context);
          } else if (e.code == 'user-not-found') {
            _globalMethods.authErrorHandle(tr("user_not_found"), context);
          } else if (e.code == 'invalid-credential') {
            _globalMethods.authErrorHandle(tr("invalid_credential"), context);
          } else if (e.code == 'invalid-email') {
            _globalMethods.authErrorHandle(tr("invalid_email"), context);
          } else if (e.code == 'wrong-password:') {
            _globalMethods.authErrorHandle(tr("wrong_password"), context);
          } else if (e.code == 'weak-password') {
            _globalMethods.authErrorHandle(tr("weak_password"), context);
          } else if (e.code == 'requires-recent-login') {
            _globalMethods.authErrorHandle(
                tr("requires_recent_login"), context);
          }
        }
        // print('error occured ${error.message}');
      } finally {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('change_password'))),
      body: _emailAddress == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        tr("password_change"),
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        tr("process_stuck"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('newPassword'),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 7) {
                                    return tr("weak_password");
                                  } else if (value == '12345678' ||
                                      value == 'qwertyuiop' ||
                                      value == 'password') {
                                    return tr("lame_password");
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: _newPasswordFocusNode,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscureText,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_passwordVerifyFocusNode),
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon:
                                        const Icon(FontAwesomeIcons.lock),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    labelText: tr("enter_new_pass"),
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background),
                                onChanged: (value) {
                                  setState(() {
                                    newPassword = value;
                                  });
                                },
                                onSaved: (value) {
                                  newPassword = value!;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('verifyPassword'),
                                validator: (value) {
                                  if (value != newPassword) {
                                    return tr("password_mismatch");
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: _passwordVerifyFocusNode,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon:
                                        const Icon(FontAwesomeIcons.lock),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    labelText: tr("repeat_new_password"),
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ButtonStyle(
                                  minimumSize: const MaterialStatePropertyAll(
                                      Size(200, 50)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  )),
                              onPressed: () {
                                _submitForm();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tr("reset_password"),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.refresh_outlined,
                                    size: 18,
                                  )
                                ],
                              )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
