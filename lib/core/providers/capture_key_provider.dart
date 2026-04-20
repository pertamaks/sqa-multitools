import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final captureKeyProvider = Provider<GlobalKey>((ref) {
  return GlobalKey();
});
