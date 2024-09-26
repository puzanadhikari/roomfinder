import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  _MapSearchScreenState createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(27.7172, 85.3240); // Kathmandu, Nepal
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCityName;
  LatLng? _selectedLatLng;
  Marker? _marker;
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _marker = Marker(
      markerId: MarkerId('selected-location'),
      position: _center,
      onDrag: (value){
      },
      onTap: () {
        log("here");
        _showLocationDetails();
      },
    );
      setState(() {

      });
  }
  void _updateMarker(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId('selected-location'),
        position: position,
        onTap: () {
          _showLocationDetails();
          // Show details when marker is tapped
        },
      );
    });
  }
  void _showLocationDetails() {
    log("details".toString());
    if (_selectedLatLng != null) {
      String details = 'Location: ${_selectedCityName ?? 'Unknown'}\n'
          'Coordinates: ${_selectedLatLng!.latitude}, ${_selectedLatLng!.longitude}';
      log(details.toString());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Details'),
          content: Text(details),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
  Future<List<String>> _getCitySuggestions(String query) async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyCzZwn-q2Dd8s9RX5nIr32ZJSGEVbFbyPI'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> predictions = json.decode(response.body)['predictions'];
      log(predictions.toString());
      return predictions.map((p) => p['description'] as String).toList();
    } else {
      throw Exception('Failed to load city suggestions');
    }
  }

  Future<void> _onCitySelected(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      List<Location> locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        LatLng selectedLocation = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation));
        _updateMarker(selectedLocation);
        setState(() {
          _center = selectedLocation;
          _selectedCityName = city;
          _selectedLatLng = selectedLocation;
          prefs.setDouble("lat", locations.first.latitude);
          prefs.setDouble("lng", locations.first.longitude);
          prefs.setString("locationName", city);

        });

        // Return the selected location to the previous page
        Navigator.pop(context, {
          'city': _selectedCityName,
          'latLng': _selectedLatLng,
        });
      }
    } catch (e) {
      log("Error occurred while selecting city: $e");
    }
  }

  void getLocationFromLatLng(LatLng position) async{
    SharedPreferences prefs =await SharedPreferences.getInstance();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );
    LatLng selectedLocation = LatLng(position.latitude, position.longitude);
    _center = position;
    _selectedCityName ="${ placemarks.first.street} ${placemarks.first.subAdministrativeArea!}";
    _selectedLatLng = selectedLocation;
    prefs.setDouble("lat", position.latitude);
    prefs.setDouble("lng", position.longitude);
    prefs.setString("locationName", _selectedCityName!);
    log("latitude 1"+position.latitude.toString());
    log(selectedLocation.toString());
    Navigator.pop(context, {
      'city': _selectedCityName,
      'latLng': _selectedLatLng,
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: const Color(0xFF072A2E),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Enter city',
                    suffixIcon: Icon(Icons.search, color: Color(0xFF072A2E)),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await _getCitySuggestions(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                    tileColor: Colors.white,
                  );
                },
                onSuggestionSelected: (suggestion) {
                  log(suggestion.toString());
                  _onCitySelected(suggestion);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GoogleMap(
                  markers: _marker != null ? {_marker!} : {},
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 14.0,
                  ),
                  onTap: (position){
                    log(position.toString());
                    getLocationFromLatLng(position);
                    _updateMarker(position);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}