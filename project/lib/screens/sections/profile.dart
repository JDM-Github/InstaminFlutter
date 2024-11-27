import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project/screens/login.dart';
import 'package:project/screens/toShip.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDashboard extends StatefulWidget {
  final dynamic user;
  const ProfileDashboard(this.user, {super.key});

  @override
  _ProfileDashboardState createState() => _ProfileDashboardState();
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

  File? _selectedImage;

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  void _showEditModal(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController(text: widget.user['firstName']);
    final TextEditingController lastNameController = TextEditingController(text: widget.user['lastName']);
    final TextEditingController emailController = TextEditingController(text: widget.user['email']);
    final TextEditingController phoneController = TextEditingController(text: widget.user['phone']);
    final TextEditingController locationController = TextEditingController(text: widget.user['location']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      File? pickedImage = await _pickImage();

                      if (pickedImage != null) {
                        setState(() {
                          _selectedImage = pickedImage;
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.user['profileImage'] != null ? NetworkImage(widget.user['profileImage']) : null)
                              as ImageProvider?,
                      child: _selectedImage == null && widget.user['profileImage'] == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  widget.user['profileImage'] = _selectedImage != null ? _selectedImage!.path : null;
                  widget.user['firstName'] = firstNameController.text;
                  widget.user['lastName'] = lastNameController.text;
                  widget.user['email'] = emailController.text;
                  widget.user['phoneNumber'] = phoneController.text;
                  widget.user['location'] = locationController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
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
          // Profile Section
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

          // Order Status Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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

// ToPayScreen
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
