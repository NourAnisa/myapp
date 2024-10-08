import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tambahkan ikon di sini
            Image.network(
              'https://icons.iconarchive.com/icons/bokehlicia/captiva/128/apport-icon.png',
              width: 100, // Sesuaikan ukuran ikon
              height: 100,
            ),
            SizedBox(height: 20), // Spasi antara ikon dan teks
            const CircularProgressIndicator(),
            SizedBox(height: 20),
            const Text(
              "Selamat Datang di Aplikasi Pengaduan Kerusakan Pada Fasilitas Umum",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center, // Supaya teks berada di tengah
            ),
          ],
        ),
      ),
    );
  }
}
