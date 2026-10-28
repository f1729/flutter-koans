import '../../engine/koan.dart';
import 'async.dart';
import 'classes.dart';
import 'collection_control.dart';
import 'enums.dart';
import 'equality.dart';
import 'exceptions.dart';
import 'extensions_mixins.dart';
import 'functions.dart';
import 'generics.dart';
import 'iterables.dart';
import 'lists.dart';
import 'maps.dart';
import 'null_safety.dart';
import 'numbers.dart';
import 'records_patterns.dart';
import 'sets.dart';
import 'streams.dart';
import 'strings.dart';
import 'variables.dart';

final dartWay = Way(
  id: 'dart',
  title: const Tr('The Way of Dart', 'Jalan Dart'),
  tagline: const Tr(
    'Values, types, collections and functions: the language beneath it all.',
    'Nilai, tipe, koleksi, dan fungsi: bahasa yang menopang segalanya.',
  ),
  categories: [
    equality,
    variables,
    nullSafety,
    numbers,
    strings,
    lists,
    sets,
    maps,
    collectionControl,
    functions,
    iterables,
    classes,
    enums,
    extensionsMixins,
    generics,
    recordsPatterns,
    exceptions,
    asyncKoans,
    streams,
  ],
);
