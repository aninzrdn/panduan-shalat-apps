import 'package:bacaan_sholat/page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Awalan extends StatefulWidget {
  const Awalan({Key? key}) : super(key: key);

  @override
  _AwalanState createState() => _AwalanState();
}

class _AwalanState extends State<Awalan> {
  Future<void> _startButtonPressed() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      // Izin lokasi belum diberikan, minta izin
      status = await Permission.location.request();
      if (status.isDenied) {
        // Izin lokasi ditolak, tampilkan pesan atau dialog
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      // Izin lokasi ditolak secara permanen, tampilkan pesan atau dialog
      openAppSettings(); // Buka pengaturan aplikasi untuk mengizinkan izin
      return;
    }

    // Dapatkan lokasi saat ini
    Position position = await Geolocator.getCurrentPosition();

    // Lakukan sesuatu dengan lokasi yang didapat, contoh: tampilkan di log
    print('Lokasi saat ini: ${position.latitude}, ${position.longitude}');

    // Navigasi ke halaman lain atau lakukan apa yang Anda inginkan di sini
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        toolbarHeight: 50,
      ),
      bottomSheet: Container(
        color: Colors.yellow,
        height: 50,
        padding: EdgeInsets.all(0),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Expanded(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/images/logo.jpg"),
                        height: 250,
                        width: 250,
                      ),
                      SizedBox(
                        height: 0,
                      ),
                      Text(
                        "Selamat Datang",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Expanded(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Dapatkan pelajaran yang terbaik\nuntuk meningkatkan waktu sholat anda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Expanded(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: _startButtonPressed,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "AYO MULAI!!",
                        style: TextStyle(
                          background: Paint()
                            ..color = Colors.yellow
                            ..style = PaintingStyle.fill,
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
