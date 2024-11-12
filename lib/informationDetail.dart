import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class InformationDetails extends StatefulWidget {
  const InformationDetails({super.key});

  @override
  State<InformationDetails> createState() => _InformationDetailsState();
}

class _InformationDetailsState extends State<InformationDetails> {
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _photoUrl; // To store the URL of the user's profile photo
  File? _imageFile; // To store the image file temporarily
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      _nameController.text = userDoc['username'] ?? '';
      _emailController.text = user?.email ?? '';
      _phoneController.text = userDoc['contactNumber'] ?? '';
      _photoUrl = userDoc['photoUrl']; // Fetch existing photo URL
      setState(() {});
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      String? newPhotoUrl;

      if (_imageFile != null) {
        newPhotoUrl = await _uploadImage(_imageFile!);
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'username': _nameController.text,
        'contactNumber': _phoneController.text,
        'photoUrl': newPhotoUrl ?? _photoUrl,
      });

      await user?.updateProfile(displayName: _nameController.text, photoURL: newPhotoUrl);

      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      Fluttertoast.showToast(
        msg: 'Profile updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);

      _initializeFields();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update profile: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }finally{
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance.ref().child('profile_photos/${user!.uid}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        title: Text(
          "User Profile",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(
          color: kThemeColor,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileHeader(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kThemeColor),
              )
                  : ElevatedButton(
                onPressed: _updateUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kThemeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage, // Allow user to change profile picture on tap
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : NetworkImage(
                _photoUrl ?? 'https://via.placeholder.com/150',
              ) as ImageProvider,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'User Name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kThemeColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _emailController.text.isNotEmpty ? _emailController.text : 'user@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildEditableListTile(
              title: 'Name',
              controller: _nameController,
              icon: Icons.person,
              onEdit: () {},
            ),
            _buildDivider(),
            _buildEditableListTile(
              title: 'Email',
              controller: _emailController,
              icon: Icons.email,
              onEdit: () {},
              enabled: false
            ),
            _buildDivider(),
            _buildEditableListTile(
              title: 'Phone',
              controller: _phoneController,
              icon: Icons.phone,
              onEdit: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 20, color: Colors.grey.shade300);
  }

  Widget _buildEditableListTile({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required Function onEdit,
    bool enabled = true,
  }) {
    // Set the keyboard type based on the title
    TextInputType keyboardType;
    if (title == 'Email') {
      keyboardType = TextInputType.emailAddress;
    } else if (title == 'Phone') {
      keyboardType = TextInputType.phone;
    } else {
      keyboardType = TextInputType.text; // Default for Name
    }

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: kThemeColor,
        ),
      ),
      subtitle: TextField(
        keyboardType: keyboardType,
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: 'Enter $title',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: Icon(icon, color: kThemeColor),
        ),
      ),
    );
  }
}
