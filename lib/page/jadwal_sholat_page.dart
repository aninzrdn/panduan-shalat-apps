import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class JadwalSholat extends StatefulWidget {
  const JadwalSholat({Key? key}) : super(key: key);

  @override
  State<JadwalSholat> createState() => _JadwalSholatState();
}

class _JadwalSholatState extends State<JadwalSholat> {
  Map<String, dynamic> todayPrayerTimes = {};
  Map<String, dynamic> tomorrowPrayerTimes = {};
  Map<String, dynamic> yesterdayPrayerTimes = {};

  Future<void> fetchTodayPrayerTimes(double latitude, double longitude) async {
    final currentDate = DateTime.now();
    final tomorrowDate = currentDate.add(Duration(days: 1));
    final yesterdayDate = currentDate.subtract(Duration(days: 1));

    final responseToday = await http.get(Uri.parse(
        'http://api.aladhan.com/v1/timings/$currentDate.millisecondsSinceEpoch?latitude=$latitude&longitude=$longitude'));
    final responseTomorrow = await http.get(Uri.parse(
        'http://api.aladhan.com/v1/timings/$tomorrowDate.millisecondsSinceEpoch?latitude=$latitude&longitude=$longitude'));
    final responseYesterday = await http.get(Uri.parse(
        'http://api.aladhan.com/v1/timings/$yesterdayDate.millisecondsSinceEpoch?latitude=$latitude&longitude=$longitude'));

    if (responseToday.statusCode == 200) {
      final data = json.decode(responseToday.body);
      setState(() {
        todayPrayerTimes = data['data']['timings'];
      });
    } else {
      throw Exception('Failed to load prayer times');
    }

    if (responseTomorrow.statusCode == 200) {
      final data = json.decode(responseTomorrow.body);
      setState(() {
        tomorrowPrayerTimes = data['data']['timings'];
      });
    } else {
      throw Exception('Failed to load prayer times');
    }

    if (responseYesterday.statusCode == 200) {
      final data = json.decode(responseYesterday.body);
      setState(() {
        yesterdayPrayerTimes = data['data']['timings'];
      });
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  Future<void> getLocationAndFetchPrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      fetchTodayPrayerTimes(position.latitude, position.longitude);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getLocationAndFetchPrayerTimes();
  }

  PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 0 && page < 3) {
      _pageController.animateToPage(
        page,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Jadwal Sholat Wajib'),
        foregroundColor: Colors.black,
        toolbarHeight: 50,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      bottomSheet: Container(
        color: Colors.yellow,
        height: 50,
        padding: EdgeInsets.all(0),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          buildPrayerTimeCard(yesterdayPrayerTimes, 'Kemarin',
              DateTime.now().subtract(Duration(days: 1))),
          buildPrayerTimeCard(todayPrayerTimes, 'Hari ini', DateTime.now()),
          buildPrayerTimeCard(tomorrowPrayerTimes, 'Besok',
              DateTime.now().add(Duration(days: 1))),
        ],
      ),
    );
  }

  Widget buildPrayerTimeCard(
      Map<String, dynamic> prayerTimes, String title, DateTime date) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_currentPage > 0)
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  iconSize: 24,
                  color: Color(0xff0e1446),
                  onPressed: () {
                    _goToPage(_currentPage - 1);
                  },
                )
              else
                SizedBox(
                  width: 24,
                  height: 24,
                ),
              Column(
                children: [
                  Text(
                    '$title, ${DateFormat('dd MMMM yyyy').format(date)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0e1446),
                    ),
                  ),
                  Text(
                    '${Hijriyah.fromDate(date).toFormat("dd MMMM yyyy")}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0e1446),
                    ),
                  ),
                ],
              ),
              if (_currentPage < 2)
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  iconSize: 24,
                  color: Color(0xff0e1446),
                  onPressed: () {
                    _goToPage(_currentPage + 1);
                  },
                )
              else
                SizedBox(
                  width: 24,
                  height: 24,
                ),
            ],
          ),
          SizedBox(height: 20),
          if (prayerTimes.isNotEmpty)
            Column(
              children: <Widget>[
                PrayerTimeCard('Shubuh', prayerTimes['Fajr']),
                PrayerTimeCard('Dhuhur', prayerTimes['Dhuhr']),
                PrayerTimeCard('Ashar', prayerTimes['Asr']),
                PrayerTimeCard('Maghrib', prayerTimes['Maghrib']),
                PrayerTimeCard('Isya', prayerTimes['Isha']),
              ],
            ),
        ],
      ),
    );
  }
}

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;

  PrayerTimeCard(this.prayerName, this.prayerTime);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(prayerName),
            Text(prayerTime),
          ],
        ),
      ),
    );
  }
}
