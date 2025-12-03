import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/space_unit.dart';

class SpaceUnitMapScreen extends StatefulWidget {
  final List<SpaceUnit> units;

  const SpaceUnitMapScreen({super.key, required this.units});

  @override
  State<SpaceUnitMapScreen> createState() => _SpaceUnitMapScreenState();
}

class _SpaceUnitMapScreenState extends State<SpaceUnitMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Kreiraj markere za sve SpaceUnit
    for (var su in widget.units) {
      if (su.workingSpace?.city?.latitude != null &&
          su.workingSpace?.city?.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(su.spaceUnitId.toString()),
            position: LatLng(
              su.workingSpace!.city!.latitude!,
              su.workingSpace!.city!.longitude!,
            ),
            infoWindow: InfoWindow(
              title: su.name,
              snippet:
                  "${su.workingSpace!.city!.cityName} • Kapacitet: ${su.capacity}\n${su.pricePerDay.toStringAsFixed(2)} KM / dan",
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(su.name),
                  content: Text(
                    "${su.workingSpace!.city!.cityName} • Kapacitet: ${su.capacity}\n${su.pricePerDay.toStringAsFixed(2)} KM / dan",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Zatvori"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default centar mape (prvi marker ili Beograd)
    LatLng center =
        widget.units.isNotEmpty &&
            widget.units[0].workingSpace?.city?.latitude != null
        ? LatLng(
            widget.units[0].workingSpace!.city!.latitude!,
            widget.units[0].workingSpace!.city!.longitude!,
          )
        : const LatLng(44.787197, 20.457273); // Beograd

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa prostorija')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 12),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;

          // Automatski zum da svi markeri budu vidljivi
          if (_markers.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              LatLngBounds bounds = _computeBounds(_markers);
              _mapController.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 50),
              );
            });
          }
        },
      ),
    );
  }

  // Funkcija za izračunavanje bounds svih markera
  LatLngBounds _computeBounds(Set<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }

    final first = markers.first.position;
    double x0 = first.latitude;
    double x1 = first.latitude;
    double y0 = first.longitude;
    double y1 = first.longitude;

    for (var marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (lat > x1) x1 = lat;
      if (lat < x0) x0 = lat;
      if (lng > y1) y1 = lng;
      if (lng < y0) y0 = lng;
    }

    return LatLngBounds(southwest: LatLng(x0, y0), northeast: LatLng(x1, y1));
  }
}
