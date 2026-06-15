import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../main.dart';
import '../../../core/models/screenshot_tool.dart';
import '../sqa_annotation_stage.dart';
import '../sqa_annotation_toolbar.dart';
import '../sqa_floating_bar.dart';
import '../sqa_design_tokens.dart';
import '../sqa_styles.dart';
import 'providers/annotator_provider.dart';



class MediaAnnotatorView extends ConsumerStatefulWidget {
  final String filePath;
  final String format;

  const MediaAnnotatorView({
    super.key,
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
  bool _isClosing = false;
  double? _mediaAspectRatio;
  
  bool _isPlaying = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initMedia();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isWindowExpandedProvider.notifier).setExpanded(true);
    });
  }

  void _initMedia() {
    final ext = p.extension(widget.filePath).toLowerCase();
    _isVideo = ['.mp4', '.mkv', '.webm', '.avi'].contains(ext);

    if (_isVideo) {
      _player = Player();
      _videoController = VideoController(_player!);
      _player!.open(Media(widget.filePath));
      _player!.setPlaylistMode(PlaylistMode.loop);
      _player!.stream.videoParams.listen((params) {
        if (mounted && params.w != null && params.h != null && params.w! > 0 && params.h! > 0) {
          final ratio = params.w! / params.h!;
          if (_mediaAspectRatio != ratio) {
            setState(() {
              _mediaAspectRatio = ratio;
            });
          }
        }
      });
      _player!.stream.playing.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });
      _player!.stream.position.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _player!.stream.duration.listen((dur) {
        if (mounted) setState(() => _duration = dur);
      });
    } else {
      decodeImageFromList(File(widget.filePath).readAsBytesSync()).then((img) {
        if (mounted) {
          setState(() {
            _mediaAspectRatio = img.width / img.height;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(MediaAnnotatorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath || oldWidget.format != widget.format) {
      _reinitMedia();
    }
  }

  Future<void> _reinitMedia() async {
    if (_player != null) {
      final oldPlayer = _player;
      setState(() {
        _player = null;
        _videoController = null;
        _isVideo = false;
        _mediaAspectRatio = null;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      await oldPlayer?.dispose();
    }
    _initMedia();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _closeSafely() async {
    if (!mounted || _isClosing) return;
    
    setState(() {
      _isClosing = true;
    });
    
    if (mounted) {
      ref.read(isWindowExpandedProvider.notifier).setExpanded(false);
      Navigator.of(context).pop();
    }
    
    if (!Platform.isLinux) {
      await windowManager.setMinimumSize(const Size(450, 500));
      await windowManager.setSize(const Size(450, 500));
      await windowManager.center();
    } else {
      await windowManager.setSize(const Size(450, 500));
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  List<Widget> _buildMediaControls() {
    return [
      SqaFloatingBarButton(
        icon: _isPlaying ? Symbols.pause : Symbols.play_arrow,
        tooltip: _isPlaying ? 'Pause' : 'Play',
        onPressed: () {
          _player?.playOrPause();
        },
      ),
      const SizedBox(width: SqaTokens.spacingMedium),
      Text(
        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
        style: SqaTextStyles.mono(context, fontSize: SqaTokens.fontSizeSmall),
      ),
      const SizedBox(width: SqaTokens.spacingMedium),
      SizedBox(
        width: 150,
        child: Slider(
          value: _position.inMilliseconds.toDouble(),
          min: 0.0,
          max: _duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
          onChanged: (value) {
            _player?.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      ),
      const SqaFloatingBarDivider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(annotatorProvider(filePath: widget.filePath, format: widget.format));
    final notifier = ref.read(annotatorProvider(filePath: widget.filePath, format: widget.format).notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Media Layer + Annotation Layer tightly coupled
          if (_mediaAspectRatio == null && !_isClosing)
            const Center(child: CircularProgressIndicator())
          else if (!_isClosing)
            Center(
              child: AspectRatio(
                aspectRatio: _mediaAspectRatio!,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _isVideo
                        ? Video(
                            controller: _videoController!,
                            fit: BoxFit.contain,
                            controls: (state) => const SizedBox.shrink(),
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
            ),
          
          // Toolbar Layer
          Positioned(
            left: 0,
            right: 0,
            bottom: SqaTokens.spacingXLarge,
            child: Center(
              child: SqaAnnotationToolbar(
                leading: _isVideo && !_isClosing ? _buildMediaControls() : null,
                enabledTools: const [
                  ScreenshotTool.pen,
                  ScreenshotTool.line,
                  ScreenshotTool.arrow,
                  ScreenshotTool.rectangle,
                  ScreenshotTool.text,
                  ScreenshotTool.eraser,
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
                trailing: [
                  SqaFloatingBarButton(
                    icon: Symbols.save,
                    tooltip: 'Save Annotations',
                    isLoading: state.isProcessing,
                    onPressed: () async {
                      await notifier.save(_boundaryKey, isVideo: _isVideo);
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
          ),
        ],
      ),
    );
  }
}
