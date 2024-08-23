import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class MapSearchScreen extends StatefulWidget {
  @override
  _MapSearchScreenState createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  GoogleMapController? _mapController;
  LatLng _center = LatLng(27.7172, 85.3240); // Kathmandu, Nepal
  TextEditingController _searchController = TextEditingController();
  String? _selectedCityName;
  LatLng? _selectedLatLng;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
    try {
      List<Location> locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        LatLng selectedLocation = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation));

        setState(() {
          _center = selectedLocation;
          _selectedCityName = city;
          _selectedLatLng = selectedLocation;
        });

        // Return the selected location to the previous page
        Navigator.pop(context, {
          'city': _selectedCityName,
          'latLng': _selectedLatLng,
        });
      }
    } catch (e) {
      print("Error occurred while selecting city: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Location'),
        backgroundColor: Color(0xFF072A2E),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
              child: TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}