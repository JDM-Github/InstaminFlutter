import 'package:flutter/material.dart';
import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _generatedController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
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
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 36.0),
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
                  ),
                  const SizedBox(height: 16),
                  buildPasswordField(
                    controller: _generatedController,
                    labelText: 'Verify your account',
                    icon: Icons.check_circle_outline,
                    isPasswordField: false,
                    isPasswordVisible: false,
                    toggleVisibility: () {},
                  ),
                  const SizedBox(height: 16),
                  buildPasswordField(
                    controller: _passwordController,
                    labelText: 'New Password',
                    icon: Icons.lock_outline,
                    isPasswordField: true,
                    isPasswordVisible: _isPasswordVisible,
                    toggleVisibility: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 16),
                  buildPasswordField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm New Password',
                    icon: Icons.lock_outline,
                    isPasswordField: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    toggleVisibility: _toggleConfirmPasswordVisibility,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: Size(size.width * 0.8, 50),
                    ),
                    child: const Text(
                      'VERIFY ACCOUNT',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: size.height * 0.14),
                  TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const LoginScreen()),
                      // );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
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

  Widget buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isPasswordField,
    required bool isPasswordVisible,
    required Function toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.pink),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.pink),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink),
        ),
        hintStyle: const TextStyle(color: Colors.pink),
        prefixIcon: Icon(
          icon,
          color: Colors.pink,
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.pink,
                ),
                onPressed: () {
                  toggleVisibility();
                },
              )
            : null,
      ),
      obscureText: isPasswordField ? !isPasswordVisible : false,
    );
  }
}
