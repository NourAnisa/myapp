import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'report_list_page.dart'; // Mengimpor halaman daftar laporan
import 'package:logger/logger.dart'; // Logger untuk menggantikan print
import 'loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Inisialisasi Hive
  await Hive.openBox('reports'); // Membuka Hive box untuk laporan
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Kerusakan Fasilitas Umum',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitializerPage(), // Menampilkan loading screen saat aplikasi dibuka
    );
  }
}

class InitializerPage extends StatefulWidget {
  @override
  _InitializerPageState createState() => _InitializerPageState();
}

class _InitializerPageState extends State<InitializerPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulasi proses loading atau inisialisasi
    await Future.delayed(const Duration(seconds: 3)); // Simulasi delay 3 detik
    setState(() {
      _isLoading = false; // Setelah selesai, ubah state
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen jika _isLoading true, sebaliknya tampilkan halaman utama
    return _isLoading ? LoadingScreen() : const MapPage();
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  final TextEditingController descriptionController = TextEditingController();
  var logger = Logger(); // Menggunakan logger

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Kerusakan Fasilitas Umum"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // Navigasi ke halaman daftar laporan
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportListPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Peta Leaflet menggunakan flutter_map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: const LatLng(-1.2667, 116.9000), // Lokasi Balikpapan
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
                      descriptionController.clear(); // Kosongkan input deskripsi setelah penyimpanan
                    } else {
                      logger.w("Pilih lokasi dan masukkan deskripsi terlebih dahulu.");
                    }
                  },
                  child: const Text("Laporkan Kerusakan"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman daftar laporan
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportListPage()),
                    );
                  },
                  child: const Text("Lihat Daftar Laporan"),
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
    logger.i("Laporan berhasil disimpan secara lokal!");
  }
}
