import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:project/screens/login.dart';
import 'package:project/screens/modals/profile_edit.dart';
import 'package:project/screens/toShip.dart';
import 'package:project/utils/handleRequest.dart';

class ProfileDashboard extends StatefulWidget {
  final dynamic user;
  const ProfileDashboard(this.user, {super.key});

  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  String _name = 'John Doe';
  String _email = 'johndoe@example.com';
  String _phone = '+1 234 567 890';
  String _location = 'New York, USA';
  String _profileImageUrl = 'https://www.w3schools.com/w3images/avatar2.png';

  @override
  void initState() {
    super.initState();
    _name = widget.user['firstName'] + " " + widget.user['lastName'];
    _email = widget.user['email'];
    _phone = widget.user['phoneNumber'];
    _location = widget.user['location'];
    _profileImageUrl = widget.user['profileImage'];
  }

   Future<void> _showLoading(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PopScope(
          canPop: true,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<String> uploadFile(selectedFile) async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload.')),
      );
      return "";
    }
  await _showLoading(context);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://instantmine.netlify.app/.netlify/functions/api/file/upload-image'));
      request.files.add(await http.MultipartFile.fromPath('file', selectedFile));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded: ${responseData['uploadedDocument']}')),
          );
          return responseData['uploadedDocument'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${responseData['message']}')),
          );
        }
      } else {
        throw Exception('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
    Navigator.pop(context);
    return "";
  }

  Future<void> updateProfile(selectedImage, updatedUser) async {
    String imageUrl = "";
    if (selectedImage != null) {
      imageUrl = await uploadFile(selectedImage.path);
    }
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'user/updateUser',
          body: {
            'profileImage': imageUrl,
            'firstName': updatedUser['firstName'],
            'lastName': updatedUser['lastName'],
            'email': updatedUser['email'],
            'phoneNumber': updatedUser['phone'],
            'location': updatedUser['location'],
          },
          willLoadingShow: true);

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Successfully updated user'),
            ),
          );
        }
        setState(() {
          widget.user['profileImage'] = imageUrl;
          widget.user['firstName'] = updatedUser['firstName'];
          widget.user['lastName'] = updatedUser['lastName'];
          widget.user['email'] = updatedUser['email'];
          widget.user['phoneNumber'] = updatedUser['phone'];
          widget.user['location'] = updatedUser['location'];

          _name = widget.user['firstName'] + " " + widget.user['lastName'];
          _email = widget.user['email'];
          _phone = widget.user['phoneNumber'];
          _location = widget.user['location'];
          _profileImageUrl = imageUrl;
        });
        Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Updating user error'),
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

  void _showEditModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditProfileModal(
        user: widget.user,
        onSave: (selectedImage, updatedUser) async {
          updateProfile(selectedImage, updatedUser);
        },
      ),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Don't log out
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm log out
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    bool? confirmed = await _showLogoutConfirmationDialog(context);
    if (confirmed != null && confirmed == true) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: size.width,
            padding: const EdgeInsets.all(16.0),
            color: Colors.pink[100],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      _profileImageUrl == "" ? 'https://www.w3schools.com/w3images/avatar2.png' : _profileImageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _email,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        _phone == "" ? "NOT SET" : _phone,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        _location,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showEditModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text('Edit', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Sign out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrderStatusButton(Icons.settings, 'Process', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ToShipScreen(widget.user, toProcess: true, textAbove: "Process Order")));
                }),
                _buildOrderStatusButton(Icons.local_shipping, 'To Ship', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ToShipScreen(widget.user, toShip: true, textAbove: "To Ship")));
                }),
                _buildOrderStatusButton(Icons.move_to_inbox, 'To Receive', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ToShipScreen(widget.user, toReceive: true, textAbove: "To Receive")));
                }),
                _buildOrderStatusButton(Icons.check_circle, 'Completed', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ToShipScreen(widget.user, isComplete: true, textAbove: "Completed Order")));
                }),
              ],
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const Center(child: Text("No recent orders", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildOrderStatusButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        CircleAvatarButton(
          radius: 25,
          backgroundColor: Colors.pink,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class CircleAvatarButton extends StatelessWidget {
  final double radius;
  final Color backgroundColor;
  final Widget child;
  final VoidCallback onPressed;

  const CircleAvatarButton({
    super.key,
    required this.radius,
    required this.backgroundColor,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }
}
