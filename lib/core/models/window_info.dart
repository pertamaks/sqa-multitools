import 'package:flutter/material.dart';

class WindowInfo {
  final int hwnd;
  final String title;
  final Rect rect;

  WindowInfo({required this.hwnd, required this.title, required this.rect});
}
