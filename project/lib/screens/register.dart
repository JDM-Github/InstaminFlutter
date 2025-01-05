import 'package:flutter/material.dart';
import 'package:project/utils/handleRequest.dart';
import '../utils/config.dart';
import 'login.dart';
import 'verify.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bdayController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _register() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(
        context,
        'user/create',
        body: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'username': _userController.text,
          'birthdate': _bdayController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phoneNumber': _phoneController.text
        },
      );
      if (response['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen(email: _emailController.text)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  bool _isAgreed = false;
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      _bdayController.text = "${selectedDate.toLocal()}".split(' ')[0];
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
              height: size.height * 0.15,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstNameController,
                          style: const TextStyle(color: Colors.pink),
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(color: Colors.pink),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _middleNameController,
                          style: const TextStyle(color: Colors.pink),
                          decoration: const InputDecoration(
                            labelText: 'Middle Name',
                            labelStyle: TextStyle(color: Colors.pink),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _lastNameController,
                          style: const TextStyle(color: Colors.pink),
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(color: Colors.pink),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _userController,
                    style: const TextStyle(color: Colors.pink),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.pink),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      hintStyle: TextStyle(color: Colors.pink),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _bdayController,
                    style: const TextStyle(color: Colors.pink),
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                      labelStyle: const TextStyle(color: Colors.pink),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      hintText: 'Pick your birthday',
                      hintStyle: const TextStyle(color: Colors.pink),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.pink),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

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
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.pink),
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(color: Colors.pink),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      hintStyle: TextStyle(color: Colors.pink),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.pink),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.pink),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      hintStyle: TextStyle(color: Colors.pink),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password input
                  TextField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(color: Colors.pink),
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.pink),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      hintStyle: TextStyle(color: Colors.pink),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAgreed = value!;
                            });
                          },
                          activeColor: Colors.pink,
                        ),
                        GestureDetector(
                          onTap: () => _showTermsModal(context), 
                          child: const Text(
                            "I agree to the Terms and Policy",
                            style: TextStyle(
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // REGISTER Button
                  ElevatedButton(
                    onPressed: () {
                      if (!_isAgreed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User is not agreed in Terms and Policy.')),
                        );
                      }
                      _register();
                      // RequestHandler.create_request(
                      // 	method="post",
                      // 	link="user/create",
                      // 	data={
                      // 		'firstName': self.first_name.input.text,
                      // 		'lastName' : self.last_name.input.text,
                      // 		'username' : self.username.input.text,
                      // 		'birthdate': self.birthday.input.text,
                      // 		'email'    : self.email.input.text,
                      // 		'password' : self.password.input.text,
                      // 		'isSeller' : False,
                      // 		'organizationName': None
                      // 	}
                      // )
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Button color
                      minimumSize: Size(size.width * 0.8, 50), // Button size
                    ),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // VERIFY ACCOUNT Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VerifyScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Button color
                      minimumSize: Size(size.width * 0.8, 50), // Button size
                    ),
                    child: const Text(
                      'VERIFY ACCOUNT',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const LoginScreen()),
                      // );
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

  void _showTermsModal(BuildContext context) async {
    Config config = await Config.load();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(config.title),
          content: SingleChildScrollView(
            child: Text(config.termsText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
