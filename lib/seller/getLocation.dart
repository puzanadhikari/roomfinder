import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    prefs.setDouble("lat", selectedLocation.latitude);
    prefs.setDouble("lng", selectedLocation.longitude);
    prefs.setString("locationName", _selectedCityName!);
        // You can use the latitude and longitude from selectedLocation
        print("City: $city, Latitude: ${selectedLocation.latitude}, Longitude: ${selectedLocation.longitude}");
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Enter city',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await _getCitySuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                _onCitySelected(suggestion);
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
            ),
          ),
          if (_selectedCityName != null && _selectedLatLng != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected City: $_selectedCityName\nLatitude: ${_selectedLatLng!.latitude}, Longitude: ${_selectedLatLng!.longitude}',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

