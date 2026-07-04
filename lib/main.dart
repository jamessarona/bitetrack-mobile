import 'package:flutter/material.dart';
import 'package:bitetrack/app/app.dart';
import 'package:bitetrack/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() async {
    runApp(const BiteTrackApp());
  });
}
