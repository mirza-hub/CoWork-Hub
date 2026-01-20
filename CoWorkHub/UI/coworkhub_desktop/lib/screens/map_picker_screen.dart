import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;

  const MapPickerScreen({super.key, this.initialLat, this.initialLon});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selectedLatLng;
  String? address;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      selectedLatLng = LatLng(widget.initialLat!, widget.initialLon!);
      _fetchAddress(widget.initialLat!, widget.initialLon!);
    }
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'CoWorkHubDesktop/1.0 (your@email.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final addr = data['address'] as Map<String, dynamic>?;

        String shortAddress = '';

        if (addr != null) {
          final road = addr['road'];
          final houseNumber = addr['house_number'];
          final city = addr['city'] ?? addr['town'] ?? addr['village'];
          final postcode = addr['postcode'];

          if (road != null) {
            shortAddress = road;
            if (houseNumber != null) {
              shortAddress += ' $houseNumber';
            }
          }

          if (city != null) {
            if (shortAddress.isNotEmpty) {
              shortAddress += ', ';
            }
            shortAddress += city;
          }

          if (postcode != null) {
            if (shortAddress.isNotEmpty) shortAddress += ' ';
            shortAddress += postcode;
          }
        }

        setState(() {
          address = shortAddress.isNotEmpty
              ? shortAddress
              : "Adresa nije dostupna, molimo unesite ručno";
        });
      } else {
        setState(() {
          address = '';
        });
      }
    } catch (e) {
      debugPrint("Greška prilikom fetch-a adrese: $e");
      setState(() {
        address = "Adresa nije dostupna, molimo unesite ručno";
      });
    }
  }

  void _onTapMap(TapPosition pos, LatLng latlng) async {
    setState(() {
      selectedLatLng = latlng;
      address = null;
    });
    await _fetchAddress(latlng.latitude, latlng.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Odaberi lokaciju")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: selectedLatLng ?? LatLng(43.8563, 18.4131),
                zoom: 13,
                onTap: _onTapMap,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                if (selectedLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLatLng!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              address ?? "Odaberite lokaciju na karti...",
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: selectedLatLng != null
                  ? () {
                      Navigator.pop(context, {
                        "lat": selectedLatLng!.latitude,
                        "lon": selectedLatLng!.longitude,
                        "address": address,
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Potvrdi lokaciju",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
