// ignore: unused_import
import 'package:bacaan_sholat/page/main_page.dart';
import 'package:bacaan_sholat/page/tampilan_awal.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Awalan(),
    );
  }
}
