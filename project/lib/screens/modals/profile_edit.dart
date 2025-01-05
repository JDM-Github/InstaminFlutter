import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String> _getUserLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return 'Location services are disabled.';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return 'Location permission denied.';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return 'Location permissions are permanently denied.';
  }

  Position position = await Geolocator.getCurrentPosition();

  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } else {
      return 'Address not found.';
    }
  } catch (e) {
    return 'Failed to get address: $e';
  }
}

class EditProfileModal extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(File? selectedImage, Map<String, dynamic> updatedUser) onSave;

  const EditProfileModal({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  File? _selectedImage;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user['firstName']);
    lastNameController = TextEditingController(text: widget.user['lastName']);
    emailController = TextEditingController(text: widget.user['email']);
    phoneController = TextEditingController(text: widget.user['phoneNumber']);
    locationController = TextEditingController(text: widget.user['location']);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Profile"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
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
                enabled: false,
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
              // TextField(
              //   controller: locationController,
              //   decoration: InputDecoration(
              //     labelText: 'Location',
              //     suffixIcon: IconButton(
              //       icon: const Icon(Icons.my_location),
              //       onPressed: () async {
              //         String currentLocation = await _getUserLocation();
              //         locationController.text = currentLocation;
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Map<String, dynamic> updatedUser = {
              'firstName': firstNameController.text,
              'lastName': lastNameController.text,
              'email': emailController.text,
              'phone': phoneController.text,
              'location': locationController.text,
              'profileImage': _selectedImage?.path ?? widget.user['profileImage'],
            };
            widget.onSave(_selectedImage, updatedUser);
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
  }
}
