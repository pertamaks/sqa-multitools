// ignore_for_file: avoid_print
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

void main() async {
  final url = 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip';
  final dir = Directory.systemTemp.createTempSync('ffmpeg_test_');
  final archiveFile = File(p.join(dir.path, 'ffmpeg_temp.zip'));
  final ffmpegDir = Directory(p.join(dir.path, 'ffmpeg'));

  print('Downloading...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != 200) {
      print('Failed to download FFmpeg: \${response.statusCode}');
      if (response.statusCode == 301 || response.statusCode == 302) {
         print('Redirected to: \${response.headers.value("location")}');
      }
      return;
    }

    final sink = archiveFile.openWrite();
    await for (var chunk in response) {
      sink.add(chunk);
    }
    await sink.close();

    print('Downloaded. Size: \${await archiveFile.length()} bytes');

    print('Extracting...');
    await ffmpegDir.create(recursive: true);
    extractFileToDisk(archiveFile.path, ffmpegDir.path);

    print('Listing extracted files...');
    final extractedBins = await ffmpegDir
        .list(recursive: true)
        .where((e) => e is File && e.path.endsWith('ffmpeg.exe'))
        .toList();

    if (extractedBins.isNotEmpty) {
      print('Found: \${extractedBins.first.path}');
    } else {
      print('Not found in downloaded archive.');
    }
  } catch (e) {
    print('Error: \$e');
  } finally {
    dir.deleteSync(recursive: true);
  }
}
