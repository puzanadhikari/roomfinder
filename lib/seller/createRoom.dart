import 'dart:developer';
import 'dart:io';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:panorama/panorama.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth/firebase_auth.dart';
import '../Constants/styleConsts.dart';
import 'getLocation.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<XFile> _photos = []; // Array to hold selected photos
  String? _name, _description, _locationName,_sellerName,_sellerEmail,_sellerPhone;
  double? _price,
      _capacity,
      _length,
      _breadth,
      _latitude,
      _longitude,
      _water,
      _electricity,
      _fohor;
  bool _hasElectricity = false, _hasWater = false;
  String? _panoramaImagePath;

  String? _selectedLocationName;
  LatLng? _selectedLocationLatLng;

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSearchScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedLocationName = result['city'];
        _selectedLocationLatLng = result['latLng'];
      });
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _photos.addAll(selectedImages);
      });
    }
  }

  File? panorama;

  final FirebaseAuthService _auth = FirebaseAuthService();

  Future<void> _pickPanoramaImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _panoramaImagePath = pickedFile.path;
      });
      panorama = File(_panoramaImagePath!);
    }
  }

  Future<void> _capturePanorama() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PanoramaCaptureScreen()),
    ).then((value) {
      if (value != null && value is String) {
        setState(() {
          _panoramaImagePath = value;
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
        _locationName =
            "Current Location"; // You can also use reverse geocoding to get the location name
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: kThemeColor,
          ),
          title: Text(
            "Post Property",
            style: TextStyle(
              color: kThemeColor,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 25,
                            offset: Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22.0, vertical: 20),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Name"),
                                  onSaved: (value) => _name = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Price"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _price = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a price';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Capacity"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _capacity = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a capacity';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Length"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _length = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the length';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Breadth"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _breadth = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the breadth';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Electricity"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _electricity = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the electricity price';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "water price"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _water = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the water price';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                      labelText: "Fohor"),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) =>
                                      _fohor = double.tryParse(value!),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the Fohor price';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                    labelText: " Property Description",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                  minLines: 5,
                                  maxLines: null,
                                  onSaved: (value) => _description = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a description';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                    labelText: " Seller Name",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                  minLines: 5,
                                  maxLines: null,
                                  onSaved: (value) => _sellerName = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a Seller name';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                    labelText: " Seller Email",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                  minLines: 5,
                                  maxLines: null,
                                  onSaved: (value) => _sellerEmail = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a Seller Email';
                                    }
                                    return null;
                                  },
                                ),
                                kHeightSmall,
                                TextFormField(
                                  decoration: kFormFieldDecoration.copyWith(
                                    labelText: " Seller Phone",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                  minLines: 5,
                                  maxLines: null,
                                  onSaved: (value) => _sellerPhone = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a Seller Phone';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    kHeightSmall,
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Property Images',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Choose the image and Show how it looks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Center(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _photos.map((photo) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.file(
                                    File(photo.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.5,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _pickImages,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF072A2E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Select Photos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    kHeightSmall,
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1.0,
                        ),
                      ),
                      child: ExpandablePanel(
                        header: Text(
                          'Property Panorama Image',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF072A2E),
                            letterSpacing: 0.5,
                          ),
                        ),
                        collapsed: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _pickPanoramaImage,
                              icon: Icon(Icons.photo_camera_back,
                                  color: Colors.white),
                              label: const Text('Pick Panorama'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF072A2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 20.0),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        expanded: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_panoramaImagePath != null)
                              Container(
                                height: 500,
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Panorama(
                                    child: Image.file(
                                      File(_panoramaImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20.0),
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _pickPanoramaImage,
                                  icon: Icon(Icons.photo_camera_back,
                                      color: Colors.white),
                                  label: const Text('Pick Panorama'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0A3D40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 20.0),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        theme: const ExpandableThemeData(
                          hasIcon: true,
                          iconColor: Color(0xFF0A3D40),
                          expandIcon: Icons.expand_more,
                          collapseIcon: Icons.expand_less,
                          tapBodyToExpand: true,
                          tapBodyToCollapse: true,
                          headerAlignment: ExpandablePanelHeaderAlignment.center,
                        ),
                      ),
                    ),
                    kHeightSmall,
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type the name of the location to search the location in map',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_selectedLocationName != null)
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Selected Location:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _selectedLocationName!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Latitude: ${_selectedLocationLatLng!.latitude}, '
                                          'Longitude: ${_selectedLocationLatLng!.longitude}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.5,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  _navigateAndDisplaySelection(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF072A2E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14.0, horizontal: 20.0),
                                  textStyle: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                child: Text('Get Desired Location'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              double? lat = prefs.getDouble("lat");
                              double? lng = prefs.getDouble("lng");
                              String? location = prefs.getString("locationName");
                              List<String> uploadedPhotoUrls =
                                  await _uploadImages(_photos);
                              String uploadedPhotoUrlsPanorama =
                                  await _uploadImagesPanorama(panorama!);
                              await _auth.addSellerRoomDetail(
                                _name!,
                                  _price!,
                                _capacity!,
                                _description!,
                                _length!,
                                _breadth!,
                                uploadedPhotoUrls,
                                uploadedPhotoUrlsPanorama,
                                _electricity!,
                                _fohor!,
                                lat!,
                                location!,
                                lng!,
                                _sellerName!,
                                _sellerEmail!,
                                _sellerPhone!,
                                _water!
                              );
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF072A2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 20.0),
                            textStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    String photoUrls;

    String photoUrl = await _uploadSingleImagePanorama(File(photos.path));
    photoUrls = photoUrl;
    return photoUrls;
  }

  Future<String> _uploadSingleImage(File image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
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
      Reference ref = storage
          .ref()
          .child('panorama/${DateTime.now().millisecondsSinceEpoch}.jpg');
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
