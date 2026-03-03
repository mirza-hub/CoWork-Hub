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
  late MapController _mapController;
  final List<Marker> _markers = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.clear();

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
              onTap: () => _showSpaceUnitDialog(su),
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        );
      }
    }

    if (mounted && _markers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isInitialized && mounted) {
          _fitBoundsToMarkers();
          setState(() => _isInitialized = true);
        }
      });
    }
  }

  void _fitBoundsToMarkers() {
    if (_markers.isEmpty) return;

    try {
      LatLngBounds bounds = _computeBounds(_markers);
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(
          padding: EdgeInsets.all(100),
          maxZoom: 15,
        ),
      );
    } catch (e) {
      debugPrint('Error fitting bounds: $e');
      if (_markers.isNotEmpty) {
        _mapController.move(_markers.first.point, 13);
      }
    }
  }

  LatLngBounds _computeBounds(List<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(const LatLng(0, 0), const LatLng(0, 0));
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

  void _showSpaceUnitDialog(SpaceUnit su) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(su.name),
        content: Text(
          "${su.workingSpace?.city?.cityName ?? 'Nepoznato'}\n"
          "Kapacitet: ${su.capacity}\n"
          "${su.pricePerDay.toStringAsFixed(2)} KM / dan",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Zatvori"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Početna lokacija
    LatLng center =
        widget.units.isNotEmpty &&
            widget.units[0].workingSpace?.latitude != null
        ? LatLng(
            widget.units[0].workingSpace!.latitude,
            widget.units[0].workingSpace!.longitude,
          )
        : const LatLng(44.787197, 20.457273);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa prostorija'), elevation: 2),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: center,
              zoom: 13,
              maxZoom: 19,
              minZoom: 5,
              interactiveFlags: InteractiveFlag.all,
              onMapReady: _initializeMarkers,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.coworkhub',
                additionalOptions: const {'email': 'info@coworkhub.com'},
                tileSize: 256,
                maxNativeZoom: 19,
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          // Loading indicator na početku
          if (!_isInitialized)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
