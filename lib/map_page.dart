import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Kerusakan Fasilitas Umum"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: const LatLng(-1.2667, 116.9000),  // Lokasi Balikpapan
                zoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: const LatLng(-1.2667, 116.9000),
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                    if (_selectedLocation != null)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _selectedLocation!,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_selectedLocation != null)
                  Text(
                    'Lokasi yang dipilih: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Kerusakan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedLocation != null &&
                        descriptionController.text.isNotEmpty) {
                      _saveReport(
                        descriptionController.text,
                        _selectedLocation!,
                      );
                    } else {
                      print("Pilih lokasi dan masukkan deskripsi terlebih dahulu.");
                    }
                  },
                  child: const Text("Laporkan Kerusakan"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menyimpan laporan ke Hive
  void _saveReport(String description, LatLng location) async {
    var box = Hive.box('reports');
    await box.add({
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
    });
    print("Laporan berhasil disimpan secara lokal!");
  }
}
