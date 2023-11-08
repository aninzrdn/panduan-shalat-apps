import 'dart:convert';

import 'package:bacaan_sholat/page/ayat_kursi_page.dart';
import 'package:bacaan_sholat/page/bacaan_sholat_page.dart';
import 'package:bacaan_sholat/page/jadwal_sholat_page.dart';
import 'package:bacaan_sholat/page/niat_sholat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic> prayerTimes = {};
  Position? currentPosition;

  Future<void> fetchPrayerTimes(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'http://api.aladhan.com/v1/timings/$DateTime.now().millisecondsSinceEpoch?latitude=$latitude&longitude=$longitude'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        prayerTimes = data['data']['timings'];
      });
    } else {
      throw Exception('Gagal Memuat Waktu Sholat');
    }
  }

  Future<void> getLocationAndFetchPrayerTimes() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        fetchPrayerTimes(position.latitude, position.longitude);
        setState(() {
          currentPosition = position;
        });
      } catch (e) {
        print('Error: $e');
      }
    } else {
      SystemNavigator.pop();
    }
  }

  String getNextPrayerTime() {
    if (prayerTimes.isEmpty) {
      return 'Tidak ada waktu sholat berikutnya';
    }

    DateTime now = DateTime.now();
    String ishaTime = prayerTimes['Isha'];

    // ignore: unnecessary_null_comparison
    if (ishaTime != null && ishaTime.isNotEmpty) {
      DateTime ishaDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(ishaTime.split(':')[0]),
        int.parse(ishaTime.split(':')[1]),
      );

      String nextPrayerName = '';
      String nextPrayerTime = '';

      if (ishaDateTime.isBefore(now)) {
        // Jika waktu Isha sudah terlewat, tampilkan waktu Fajr untuk besok
        String fajrTimeTomorrow = prayerTimes['Fajr'];
        // ignore: unnecessary_null_comparison
        if (fajrTimeTomorrow != null && fajrTimeTomorrow.isNotEmpty) {
          nextPrayerName = 'Fajr (Besok)';
          DateTime fajrDateTimeTomorrow = DateTime(
            now.year,
            now.month,
            now.day + 1, // Besok
            int.parse(fajrTimeTomorrow.split(':')[0]),
            int.parse(fajrTimeTomorrow.split(':')[1]),
          );
          Duration timeUntilFajrTomorrow = fajrDateTimeTomorrow.difference(now);
          int hours = timeUntilFajrTomorrow.inHours;
          int minutes = timeUntilFajrTomorrow.inMinutes.remainder(60);
          nextPrayerTime = '${hours} Jam ${minutes} Menit';
        }
      } else {
        List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        for (String prayerName in prayerNames) {
          String prayerTime = prayerTimes[prayerName];
          // ignore: unnecessary_null_comparison
          if (prayerTime != null && prayerTime.isNotEmpty) {
            DateTime prayerDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(prayerTime.split(':')[0]),
              int.parse(prayerTime.split(':')[1]),
            );

            if (prayerDateTime.isAfter(now)) {
              nextPrayerName = prayerName;
              Duration timeUntilPrayer = prayerDateTime.difference(now);
              int hours = timeUntilPrayer.inHours;
              int minutes = timeUntilPrayer.inMinutes.remainder(60);
              nextPrayerTime = '${hours} Jam ${minutes} Menit';
              break;
            }
          }
        }
      }

      if (nextPrayerName.isNotEmpty && nextPrayerTime.isNotEmpty) {
        return '$nextPrayerName - $nextPrayerTime';
      }
    }

    return 'Tidak ada waktu sholat berikutnya';
  }

  @override
  void initState() {
    super.initState();
    getLocationAndFetchPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    String locationText = 'Lokasi: Latitude - Longitude';
    if (currentPosition != null) {
      locationText =
          '${currentPosition!.latitude.toStringAsFixed(4)} - ${currentPosition!.longitude.toStringAsFixed(4)}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
      ),
      bottomSheet: Container(
        color: Colors.yellow,
        height: 50,
        padding: EdgeInsets.all(0),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Container(
                              child: Image(
                                image: AssetImage("assets/images/sunset.jpg"),
                                height: 200,
                                width: 500,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    '${getNextPrayerTime().split(' - ')[0]}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JadwalSholat(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Time >',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 65,
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '- ${getNextPrayerTime().split(' - ')[1]}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            locationText,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Container(
                margin: EdgeInsets.all(2),
                child: Container(
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NiatSholat()));
                    },
                    child: Column(
                      children: [
                        Image(
                          image: AssetImage("assets/images/sholat 2.jpg"),
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(height: 1),
                        Text(
                          "Niat Sholat",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BacaanSholat()));
                        },
                        child: Column(
                          children: [
                            Image(
                              image: AssetImage("assets/images/ngaji.jpg"),
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Bacaan Sholat",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AyatKursi()));
                        },
                        child: Column(
                          children: [
                            Image(
                              image: AssetImage("assets/images/quran 2.jpg"),
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Ayat Kursi",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
