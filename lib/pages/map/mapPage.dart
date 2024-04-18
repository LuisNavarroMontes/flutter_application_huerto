import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/land.dart';
import '../../service/land_supabase.dart';
import 'landDetail.dart';

const MAP_KEY = '9b116f76-e8c1-4133-b90d-c7bd4b68c8c7';
const styleUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

class MapPage extends StatefulWidget {
  final Guid userId;
  const MapPage(this.userId, {super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  bool hasLocationPermission = false;
  bool isLoading = true;

  LatLng? myPosition;
  List<Land> lands = [];
  List<Marker> markers = [];

  late int indexLand;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    indexLand = -1;
  }

  void _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    setState(() {
      hasLocationPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    });

    if (permission == LocationPermission.denied) {
      setState(() {
        isLoading = false;
        loadLands();
      });
      print("Location permission denied");
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
        loadLands();
      });
      print("Location permission permanently denied");
    } else {
      await getCurrentLocation().then((_) => setState(() {
            isLoading = false;
            loadLands();
          }));
    }
  }

  Future<Position> determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void loadLands() async {
    lands = await LandSupabase().readLands();
    setState(() {
      lands.sort(
          (a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));
      markers = transformLandsToMarkers(lands);
      if (hasLocationPermission) {
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: myPosition!,
            child: IconButton(
              icon: const Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 30.0, // Reducir el tamaño del icono
              ),
              onPressed: () {
                // Centra el mapa en la ubicación actual
                mapController.move(myPosition!, 18);
              },
            ),
          ),
        );
      }
    });
  }

  double _calculateDistance(Land land) {
    if (myPosition == null) return double.infinity;
    final landPosition = LatLng(land.latitude, land.longitude);
    var distance = const Distance();
    return distance(myPosition!, landPosition);
  }

  List<Marker> transformLandsToMarkers(List<Land> lands) {
    return lands.map((land) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(land.latitude, land.longitude),
        child: IconButton(
          icon: const Icon(
            Icons.location_on,
            color: Colors.black,
            size: 30.0, // Reducir el tamaño del icono
          ),
          onPressed: () {
            // Centra el mapa en la ubicación de la propiedad
            mapController.move(LatLng(land.latitude, land.longitude), 18);
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: indexLand != -1
                      ? LatLng(
                          lands[indexLand].latitude, lands[indexLand].longitude)
                      : (hasLocationPermission
                          ? myPosition!
                          : const LatLng(39.4702, -0.3898)),
                  zoom: 18,
                  keepAlive: false,
                ),
                children: [
                  TileLayer(
                    urlTemplate: styleUrl,
                    additionalOptions: const {
                      'accessToken': MAP_KEY,
                    },
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: lands.length,
                itemBuilder: (context, index) {
                  final land = lands[index];
                  return ListTile(
                    title: Text(land.location),
                    subtitle: Text(
                      hasLocationPermission
                          ? 'Tamaño: ${land.size}, Proximidad: ${_calculateDistance(land).toStringAsFixed(2)} metros'
                          : 'Tamaño: ${land.size}, Proximidad: No disponible',
                    ),
                    onTap: () {
                      setState(() {
                        indexLand = index;
                        mapController.move(
                            LatLng(
                                lands[index].latitude, lands[index].longitude),
                            18);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
