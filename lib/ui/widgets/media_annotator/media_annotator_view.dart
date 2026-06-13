import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../core/ui/sqa_theme.dart';
import '../../../core/models/screenshot_tool.dart';
import '../sqa_annotation_stage.dart';
import '../sqa_annotation_toolbar.dart';
import '../sqa_floating_bar.dart';
import 'providers/annotator_provider.dart';
import 'models/annotator_state.dart';



class MediaAnnotatorView extends ConsumerStatefulWidget {
  final String windowId;
  final String filePath;
  final String format;

  const MediaAnnotatorView({
    super.key,
    required this.windowId,
    required this.filePath,
    required this.format,
  });

  @override
  ConsumerState<MediaAnnotatorView> createState() => _MediaAnnotatorViewState();
}

class _MediaAnnotatorViewState extends ConsumerState<MediaAnnotatorView> {
  final GlobalKey _boundaryKey = GlobalKey();
  
  Player? _player;
  VideoController? _videoController;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  void _initMedia() {
    final ext = p.extension(widget.filePath).toLowerCase();
    _isVideo = ['.mp4', '.mkv', '.webm', '.avi'].contains(ext);

    if (_isVideo) {
      _player = Player();
      _videoController = VideoController(_player!);
      _player!.open(Media(widget.filePath));
      _player!.setPlaylistMode(PlaylistMode.loop);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _closeSafely() async {
    if (_player != null) {
      final p = _player;
      setState(() {
        _player = null;
        _videoController = null;
        _isVideo = false;
      });
      // Small delay to let the UI detach the video widget
      await Future.delayed(const Duration(milliseconds: 50));
      await p?.dispose();
    }
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(annotatorProvider(filePath: widget.filePath, format: widget.format));
    final notifier = ref.read(annotatorProvider(filePath: widget.filePath, format: widget.format).notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Layer + Annotation Layer tightly coupled
          Center(
            child: Stack(
              fit: StackFit.loose,
              children: [
                _isVideo
                    ? Video(
                        controller: _videoController!,
                        fit: BoxFit.contain,
                        controls: NoVideoControls,
                      )
                    : Image.file(
                        File(widget.filePath),
                        fit: BoxFit.contain,
                      ),
                Positioned.fill(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: SqaAnnotationStage(
                      currentTool: state.currentTool,
                      annotationColor: state.annotationColor,
                      annotations: state.annotations,
                      onAnnotationAdded: notifier.addAnnotation,
                      onAnnotationRemoved: notifier.removeAnnotation,
                      selectionRect: null, // Full screen drawing
                      isRecording: false,
                      isCapturing: true,
                      animationValue: 1.0,
                      ripples: const [],
                      clickFeedbackColor: Colors.transparent,
                      rightClickFeedbackColor: Colors.transparent,
                      canDraw: true,
                      textHasBackground: state.textHasBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Toolbar Layer
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: SqaAnnotationToolbar(
                enabledTools: const [
                  ScreenshotTool.pointer,
                  ScreenshotTool.pen,
                  ScreenshotTool.line,
                  ScreenshotTool.arrow,
                  ScreenshotTool.rectangle,
                  ScreenshotTool.text,
                ],
                currentTool: state.currentTool,
                onToolSelected: notifier.setTool,
                currentColor: state.annotationColor,
                onColorSelected: notifier.setColor,
                textHasBackground: state.textHasBackground,
                onTextBackgroundToggled: notifier.setTextHasBackground,
                onClear: notifier.clearAnnotations,
                availableColors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.amber,
                  Colors.cyan,
                  Colors.pink,
                  Colors.white,
                  Colors.black,
                ],
              ),
            ),
          ),

          // Action Buttons Layer
          Positioned(
            top: 24,
            right: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SqaFloatingBarButton(
                  icon: Symbols.save,
                  tooltip: 'Save Annotations',
                  isLoading: state.isProcessing,
                  onPressed: () async {
                    await notifier.save(_boundaryKey, isVideo: _isVideo);
                    try {
                      await WindowController.fromWindowId('0').invokeMethod('refresh');
                    } catch (_) {}
                    await _closeSafely();
                  },
                ),
                SqaFloatingBarButton(
                  icon: Symbols.close,
                  tooltip: 'Cancel',
                  color: Colors.red,
                  onPressed: () async {
                    await _closeSafely();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
