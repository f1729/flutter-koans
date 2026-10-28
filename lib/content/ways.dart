import '../engine/koan.dart';
import 'dart/dart_way.dart';
import 'flutter/flutter_way.dart';

final ways = [dartWay, flutterWay];

Way? wayById(String id) => ways.where((w) => w.id == id).firstOrNull;
