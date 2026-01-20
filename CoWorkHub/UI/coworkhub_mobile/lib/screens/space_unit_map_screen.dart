import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/space_unit.dart';

class SpaceUnitMapScreen extends StatefulWidget {
  final List<SpaceUnit> units;

  const SpaceUnitMapScreen({super.key, required this.units});

  @override
  State<SpaceUnitMapScreen> createState() => _SpaceUnitMapScreenState();
}

class _SpaceUnitMapScreenState extends State<SpaceUnitMapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();

    // Kreiranje markera za sve SpaceUnit u listi
    for (var su in widget.units) {
      if (su.workingSpace?.latitude != null &&
          su.workingSpace?.longitude != null) {
        _markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(
              su.workingSpace!.latitude,
              su.workingSpace!.longitude,
            ),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(su.name),
                    content: Text(
                      "${su.workingSpace!.city?.cityName ?? ''} • Kapacitet: ${su.capacity}\n${su.pricePerDay.toStringAsFixed(2)} KM / dan",
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
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        );
      }
    }

    // Ako postoje markeri, zumiranje na sve
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_markers.isNotEmpty) {
        LatLngBounds bounds = _computeBounds(_markers);
        _mapController.fitBounds(
          bounds,
          options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
        );
      }
    });
  }

  LatLngBounds _computeBounds(List<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(LatLng(0, 0), LatLng(0, 0));
    }

    double minLat = markers.first.point.latitude;
    double maxLat = markers.first.point.latitude;
    double minLng = markers.first.point.longitude;
    double maxLng = markers.first.point.longitude;

    for (var m in markers) {
      if (m.point.latitude < minLat) minLat = m.point.latitude;
      if (m.point.latitude > maxLat) maxLat = m.point.latitude;
      if (m.point.longitude < minLng) minLng = m.point.longitude;
      if (m.point.longitude > maxLng) maxLng = m.point.longitude;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  @override
  Widget build(BuildContext context) {
    LatLng center =
        widget.units.isNotEmpty &&
            widget.units[0].workingSpace?.latitude != null
        ? LatLng(
            widget.units[0].workingSpace!.latitude,
            widget.units[0].workingSpace!.longitude,
          )
        : const LatLng(44.787197, 20.457273);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa prostorija')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(center: center, zoom: 12),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.coworkhub',
            additionalOptions: {'email': 'tvoj.email@domena.com'},
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
