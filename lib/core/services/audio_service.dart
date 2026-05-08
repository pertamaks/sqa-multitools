import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// A singleton service to handle audio playback on the correct platform thread using just_audio.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  AudioPlayer? _player;
  String? _currentPath;

  /// Initializes the player on the main thread.
  void init() {
    if (kIsWeb ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        Platform.isLinux) return;
    try {
      _player ??= AudioPlayer();
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  /// Pre-loads an asset into memory to ensure zero-latency playback later.
  Future<void> preLoad(String path) async {
    if (_player == null) init();
    try {
      final assetPath = path.startsWith('assets/') ? path : 'assets/$path';
      if (_currentPath == assetPath) return;

      await _player?.setAsset(assetPath, preload: true);
      _currentPath = assetPath;
    } catch (e) {
      debugPrint('AudioService pre-load error: $e');
    }
  }

  /// Plays an asset sound safely.
  Future<void> playAsset(String path) async {
    if (_player == null) init();
    try {
      final assetPath = path.startsWith('assets/') ? path : 'assets/$path';

      // If a new asset is requested, load it.
      // Otherwise, we just reuse the pre-loaded one for zero latency.
      if (_currentPath != assetPath) {
        await _player?.setAsset(assetPath);
        _currentPath = assetPath;
      }

      await _player?.seek(Duration.zero);
      await _player?.play();
    } catch (e) {
      debugPrint('AudioService play error: $e');
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
