import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ReportListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('reports');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Laporan"),
      ),
      body: ListView.builder(
        itemCount: box.length,
        itemBuilder: (context, index) {
          var report = box.get(index);
          return ListTile(
            title: Text(report['description']),
            subtitle: Text('Lokasi: ${report['latitude']}, ${report['longitude']}'),
          );
        },
      ),
    );
  }
}
