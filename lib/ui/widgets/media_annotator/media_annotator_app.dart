import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/sqa_theme.dart';
import 'media_annotator_view.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class MediaAnnotatorApp extends StatefulWidget {
  final String windowId;
  final Map<String, dynamic> args;

  const MediaAnnotatorApp({
    super.key,
    required this.windowId,
    required this.args,
  });

  @override
  State<MediaAnnotatorApp> createState() => _MediaAnnotatorAppState();
}

class _MediaAnnotatorAppState extends State<MediaAnnotatorApp> {
  late String _filePath;
  late String _format;

  @override
  void initState() {
    super.initState();
    _filePath = widget.args['filePath'] as String? ?? '';
    _format = widget.args['format'] as String? ?? 'PNG';

    WindowController.fromWindowId(widget.windowId).setWindowMethodHandler((call) async {
      if (call.method == 'setMedia') {
        final args = call.arguments as Map;
        setState(() {
          _filePath = args['filePath'] as String? ?? '';
          _format = args['format'] as String? ?? 'PNG';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Media Annotator',
        theme: SqaTheme.createTheme(
          brightness: Brightness.light,
          dynamicScheme: null,
          seedColor: Colors.blue,
          useDynamicColor: false,
        ),
        darkTheme: SqaTheme.createTheme(
          brightness: Brightness.dark,
          dynamicScheme: null,
          seedColor: Colors.blue,
          useDynamicColor: false,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        key: ValueKey('$_filePath-$_format'), // Force rebuild entirely on media change
        home: MediaAnnotatorView(
          windowId: widget.windowId,
          filePath: _filePath,
          format: _format,
        ),
      ),
    );
  }
}
