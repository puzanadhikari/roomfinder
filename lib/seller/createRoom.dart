
import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:panorama/panorama.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth/firebase_auth.dart';
import 'getLocation.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {


  final _formKey = GlobalKey<FormState>();
  final List<XFile> _photos = []; // Array to hold selected photos
  String? _name, _description, _locationName;
  double? _price, _capacity, _length, _breadth, _latitude, _longitude,_water,_electricity,_fohor;
  bool _hasElectricity = false, _hasWater = false;
  String? _panoramaImagePath; Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _photos.addAll(selectedImages);
      });
    }
  }
  File ? panorama;

  final FirebaseAuthService _auth = FirebaseAuthService();
  // Function to pick images

  Future<void> _pickPanoramaImage() async {
    // Code to pick the image
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _panoramaImagePath = pickedFile.path;
      });
      panorama= File(_panoramaImagePath!);
      // Upload the image to Firebase Storage

    }
  }
  Future<void> _capturePanorama() async {
    // This will navigate to the panorama capture screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PanoramaCaptureScreen()),
    ).then((value) {
      if (value != null && value is String) {
        setState(() {
          _panoramaImagePath = value; // Get the image path from the panorama capture
        });
      }
    });
  }
  // Function to get location
  Future<void> _getLocation() async {
    Location location = Location();
    LocationData? currentLocation;

    try {
      currentLocation = await location.getLocation();
      setState(() {
        _latitude = currentLocation!.latitude;
        _longitude = currentLocation!.longitude;
        _locationName = "Current Location"; // You can also use reverse geocoding to get the location name
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (value) => _name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _price = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _capacity = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a capacity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Length'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _length = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the length';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Breadth'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _breadth = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the breadth';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Electricity'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _electricity = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the electricity price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Water'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _water = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the water price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Fohor'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _fohor = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Fohor price';
                    }
                    return null;
                  },
                ),

                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Select Photos'),
                ),

                // Display selected photos
                Wrap(
                  spacing: 8.0,
                  children: _photos.map((photo) {
                    return Image.file(
                      File(photo.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _pickPanoramaImage,
                  child: const Text('Pick Panorama'),
                ),
                // Display captured panorama image
                if (_panoramaImagePath != null)
                  Container(
                    height: 500,
                    child: Panorama(
                      child: Image.file(
                        File(_panoramaImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Button to get location
                ElevatedButton(
                  onPressed: _getLocation,
                  child: const Text('Get Current Location'),
                ),
                ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MapSearchScreen()));
                  },
                  child: const Text('Get Desired Location'),
                ),
                // Display location info
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                     double? lat= prefs.getDouble("lat");
                     double? lng= prefs.getDouble("lng");
                     String? location= prefs.getString("locationName");
                      List<String> uploadedPhotoUrls = await _uploadImages(_photos);
                      String uploadedPhotoUrlsPanorama = await _uploadImagesPanorama(panorama!);
                      await _auth.addSellerRoomDetail(
                        _name!,
                        _capacity!,
                        _description!,
                        _length!,
                        _breadth!,
                        uploadedPhotoUrls, // Pass the uploaded photo URLs
                        uploadedPhotoUrlsPanorama, // Pass the panorama URL
                        _electricity!,
                        _fohor!,
                        lat!,
                        location!,
                        lng!,

                      );  }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<List<String>> _uploadImages(List<XFile> photos) async {
    List<String> photoUrls = [];
    for (XFile photo in photos) {
      String photoUrl = await _uploadSingleImage(File(photo.path));
      photoUrls.add(photoUrl);
    }
    return photoUrls;
  }
  Future _uploadImagesPanorama(File photos) async {
   String photoUrls ;

      String photoUrl = await _uploadSingleImagePanorama(File(photos.path));
      photoUrls=photoUrl;
    return photoUrls;
  }


  Future<String> _uploadSingleImage(File image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Ensure the upload completed successfully
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception("Upload failed with state: ${snapshot.state}");
      }
    } catch (e) {
      print("Error uploading image: $e");
      rethrow; // Rethrow the exception to handle it upstream
    }
  }
  Future<String> _uploadSingleImagePanorama(File image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('panorama/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception("Upload failed with state: ${snapshot.state}");
      }
    } catch (e) {
      print("Error uploading image: $e");
      rethrow; // Rethrow the exception to handle it upstream
    }
  }


}
class PanoramaCaptureScreen extends StatelessWidget {
  const PanoramaCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panorama Capture')),
      body: Center(
        child: Panorama(
          child: Image.network('https://example.com/panorama.jpg'),
        ),
      ),
    );
  }
}