import 'dart:io';
import 'ffmpeg_engine.dart';

/// Strategy interface for platform-specific FFmpeg configurations.
abstract class FfmpegPlatformConfig {
  /// The URL to download the FFmpeg binary for this platform.
  String get downloadUrl;

  /// The name of the FFmpeg executable (e.g., 'ffmpeg.exe' or 'ffmpeg').
  String get executableName;

  /// The input format for video capture (e.g., 'gdigrab', 'avfoundation', 'x11grab').
  String get videoInputFormat;

  /// The input format for audio capture (e.g., 'dshow', 'avfoundation', 'pulse').
  String get audioInputFormat;

  /// The input name for video (e.g., 'desktop', 'capture_session').
  String get videoInputName;

  /// Builds the argument list for video capture.
  List<String> buildVideoArgs({
    required FfmpegVideoConfig config,
    int? x,
    int? y,
    int? w,
    int? h,
  });

  /// Builds the argument list for audio capture.
  List<String> buildAudioArgs(String deviceName);

  /// Arguments to list available audio devices.
  List<String> buildListAudioDevicesArgs();

  /// Regex to parse audio device names from FFmpeg output.
  RegExp get audioDeviceRegex;

  /// Factory to get the correct config for the current platform.
  factory FfmpegPlatformConfig.current() {
    if (Platform.isWindows) return WindowsFfmpegConfig();
    if (Platform.isMacOS) return MacOsFfmpegConfig();
    if (Platform.isLinux) return LinuxFfmpegConfig();
    throw UnsupportedError('Platform not supported for FFmpeg capture');
  }
}

/// Windows implementation using gdigrab and dshow.
class WindowsFfmpegConfig implements FfmpegPlatformConfig {
  @override
  String get downloadUrl =>
      'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip';

  @override
  String get executableName => 'ffmpeg.exe';

  @override
  String get videoInputFormat => 'gdigrab';

  @override
  String get audioInputFormat => 'dshow';

  @override
  String get videoInputName => 'desktop';

  @override
  List<String> buildVideoArgs({
    required FfmpegVideoConfig config,
    int? x,
    int? y,
    int? w,
    int? h,
  }) {
    final args = <String>[
      '-f', videoInputFormat,
      '-framerate', '${config.framerate}',
    ];

    if (x != null) args.addAll(['-offset_x', '$x']);
    if (y != null) args.addAll(['-offset_y', '$y']);
    if (w != null && h != null) args.addAll(['-video_size', '${w}x$h']);

    if (!config.showCursor) {
      args.addAll(['-draw_mouse', '0']);
    }
    return args;
  }

  @override
  List<String> buildAudioArgs(String deviceName) {
    return ['-f', audioInputFormat, '-i', 'audio=$deviceName'];
  }

  @override
  List<String> buildListAudioDevicesArgs() {
    return ['-f', audioInputFormat, '-list_devices', 'true', '-i', 'dummy'];
  }

  @override
  RegExp get audioDeviceRegex => RegExp(r'\[dshow @ .*\] "(.*)" \(audio\)');
}

/// macOS implementation shell (AVFoundation).
class MacOsFfmpegConfig implements FfmpegPlatformConfig {
  @override
  String get downloadUrl => 'https://evermeet.cx/ffmpeg/get/zip'; // Example URL

  @override
  String get executableName => 'ffmpeg';

  @override
  String get videoInputFormat => 'avfoundation';

  @override
  String get audioInputFormat => 'avfoundation';

  @override
  String get videoInputName => '1:none'; // Screen index : Audio index

  @override
  List<String> buildVideoArgs({
    required FfmpegVideoConfig config,
    int? x,
    int? y,
    int? w,
    int? h,
  }) {
    return [
      '-f', videoInputFormat,
      '-framerate', '${config.framerate}',
      '-capture_cursor', config.showCursor ? '1' : '0',
    ];
  }

  @override
  List<String> buildAudioArgs(String deviceName) {
    return ['-f', audioInputFormat, '-i', ':$deviceName'];
  }

  @override
  List<String> buildListAudioDevicesArgs() {
    return ['-f', audioInputFormat, '-list_devices', 'true', '-i', '""'];
  }

  @override
  RegExp get audioDeviceRegex => RegExp(r'\[AVFoundation .*\] \[\d+\] (.*)');
}

/// Linux implementation shell (x11grab/pulse).
class LinuxFfmpegConfig implements FfmpegPlatformConfig {
  @override
  String get downloadUrl => 'https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz';

  @override
  String get executableName => 'ffmpeg';

  @override
  String get videoInputFormat => 'x11grab';

  @override
  String get audioInputFormat => 'pulse';

  @override
  String get videoInputName => ':0.0';

  @override
  List<String> buildVideoArgs({
    required FfmpegVideoConfig config,
    int? x,
    int? y,
    int? w,
    int? h,
  }) {
    return [
      '-f', videoInputFormat,
      '-framerate', '${config.framerate}',
      // Note: x11grab uses -i :0.0+x,y which we handle in videoInputName logic if needed,
      // or we just use the crop filter which is more universal across platforms.
    ];
  }

  @override
  List<String> buildAudioArgs(String deviceName) {
    return ['-f', audioInputFormat, '-i', deviceName];
  }

  @override
  List<String> buildListAudioDevicesArgs() {
    return ['-f', audioInputFormat, '-list_devices', 'true', '-i', 'dummy']; // Pulse might differ
  }

  @override
  RegExp get audioDeviceRegex => RegExp(r'\[pulse @ .*\] (.*)');
}
