import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../flixquest_main.dart';
import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '/screens/user/forgot_password.dart';
import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/globle_method.dart';
import '../../ui_components/app_ui_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode passwordFocusNode = FocusNode();
  bool obscureText = true;
  String emailAddress = '';
  String password = '';
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  GlobalMethods globalMethods = GlobalMethods();
  bool isLoading = false;

  // @override
  // void dispose() {
  //   passwordFocusNode.dispose();
  //   super.dispose();
  // }

  void submitForm() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    checkConnection().then((value) async {
      if (value) {
        if (isValid && mounted) {
          setState(() {
            isLoading = true;
          });
          formKey.currentState!.save();
          try {
            await auth
                .signInWithEmailAndPassword(
                    email: emailAddress.toLowerCase().trim(),
                    password: password.trim())
                .then((value) {
              if (mounted) {
                Navigator.canPop(context)
                    ? Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: ((context) {
                        final mixpanel =
                            Provider.of<SettingsProvider>(context).mixpanel;
                        mixpanel.track(
                          'Users Login',
                        );
                        return const FlixQuestHomePage();
                      })))
                    : null;
              }
            });
          } on FirebaseAuthException catch (error) {
            if (mounted) {
              if (error.code == 'wrong-password') {
                globalMethods.authErrorHandle(
                    tr('invalid_credential'), context);
              } else if (error.code == 'invalid-email') {
                globalMethods.authErrorHandle(tr('invalid_email'), context);
              } else if (error.code == 'user-disabled') {
                globalMethods.authErrorHandle(tr('banned_user'), context);
              } else if (error.code == 'user-not-found') {
                globalMethods.authErrorHandle(tr('user_not_found'), context);
              }
            }
            // print('error occured $error}');
          } finally {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        }
      } else {
        GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Text(
                tr('check_connection'),
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: const Duration(seconds: 3),
            ),
            context.mounted ? context : null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('login'))),
      body: AppResponsiveContent(
          maxWidth: 520,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                      tag: 'logo_shadow',
                      child: SizedBox(
                          height: 112,
                          width: 112,
                          child: Image.asset('assets/images/logo.png'))),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TextFormField(
                                  key: const ValueKey('email'),
                                  validator: (value) {
                                    if (value!.isEmpty ||
                                        !value.contains('@')) {
                                      return tr('invalid_email');
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocusNode),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(FontAwesomeIcons.envelope),
                                      labelText: tr('email_address')),
                                  onSaved: (value) {
                                    emailAddress = value!;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TextFormField(
                                  key: const ValueKey('Password'),
                                  validator: (value) {
                                    if (value!.isEmpty || value.length < 7) {
                                      return tr('weak_password');
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.visiblePassword,
                                  focusNode: passwordFocusNode,
                                  decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(FontAwesomeIcons.lock),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            obscureText = !obscureText;
                                          });
                                        },
                                        child: Icon(obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      ),
                                      labelText: tr('password')),
                                  onSaved: (value) {
                                    password = value!;
                                  },
                                  obscureText: obscureText,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                              minimumSize:
                                                  WidgetStateProperty.all(
                                                      const Size(150, 50)),
                                              shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              )),
                                          onPressed: submitForm,
                                          child: Text(
                                            tr('login'),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17),
                                          )),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextButton(
                                  style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.transparent)),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: ((context) {
                                      return const ForgotPasswordScreen();
                                    })));
                                  },
                                  child: Text(
                                    tr('forgot_password'),
                                  )),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
