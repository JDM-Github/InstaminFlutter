import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project/utils/handleRequest.dart';
import 'login.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  const VerifyScreen({this.email = "", super.key});

  @override
  // ignore: library_private_types_in_public_api
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();

  String verificationCode = "";

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    WidgetsBinding.instance.addPostFrameCallback((_) => generateVerificationCode());
  }

  String generateVerificationCode() {
    final random = Random();
    int verificationCode = 100000 + random.nextInt(900000);
    return verificationCode.toString();
  }

  Future<void> sendEmail() async {
    if (_emailController.text.isEmpty) return;
    RequestHandler requestHandler = RequestHandler();
    try {
      setState(() {
        verificationCode = generateVerificationCode();
      });

      String email = _emailController.text;
      Map<String, dynamic> body = {
        "verificationCode": verificationCode,
        "email": email,
      };
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'send-email', body: body);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Email sent successfully.'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Loading sending email error'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<void> verifyCode(code) async {
    if (_emailController.text.isEmpty || verificationCode.isEmpty) return;
    if (verificationCode != code) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code does not match. Invalid code'),
        ),
      );
      return;
    }

    RequestHandler requestHandler = RequestHandler();
    try {
      String email = _emailController.text;
      Map<String, dynamic> body = {
        "email": email,
      };
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'user/verify', body: body);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email has been verified.'),
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Verifying email error'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            width: size.width,
            height: size.height,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size.width,
              height: size.height * 0.35,
              decoration: const BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.pink),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.pink),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                        hintStyle: TextStyle(color: Colors.pink),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.pink,
                        ),
                      ),
                      enabled: widget.email.isEmpty),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.pink),
                    decoration: const InputDecoration(
                      labelText: 'Verify your account',
                      labelStyle: TextStyle(color: Colors.pink),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      hintStyle: TextStyle(color: Colors.pink),
                      prefixIcon: Icon(
                        Icons.password,
                        color: Colors.pink,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      sendEmail();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: Size(size.width * 0.8, 50),
                    ),
                    child: const Text(
                      'SEND/RESEND CODE',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      verifyCode(_passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: Size(size.width * 0.8, 50),
                    ),
                    child: const Text(
                      'VERIFY ACCOUNT',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: size.height * 0.25),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text(
                      "Have an account? Sign In",
                      style: TextStyle(color: Colors.pink),
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
}
