import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LokasiKantorPage extends StatefulWidget {
  const LokasiKantorPage({super.key});

  @override
  State<LokasiKantorPage> createState() =>
      _LokasiKantorPageState();
}

class _LokasiKantorPageState
    extends State<LokasiKantorPage> {

  static const LatLng pusatKota =
      LatLng(-6.917464, 107.619123);

  final Set<Marker> markers = {
    const Marker(
      markerId: MarkerId('kantor_1'),
      position: LatLng(-6.917464, 107.619123),
      infoWindow: InfoWindow(
        title: 'Kantor Layanan Pusat',
      ),
    ),

    const Marker(
      markerId: MarkerId('kantor_2'),
      position: LatLng(-6.910000, 107.610000),
      infoWindow: InfoWindow(
        title: 'Kantor Layanan Utara',
      ),
    ),

    const Marker(
      markerId: MarkerId('kantor_3'),
      position: LatLng(-6.925000, 107.625000),
      infoWindow: InfoWindow(
        title: 'Kantor Layanan Selatan',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Kantor'),
      ),

      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: pusatKota,
          zoom: 13,
        ),
        markers: markers,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}