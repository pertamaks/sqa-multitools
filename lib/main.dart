import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/window/window_utils.dart';
import 'core/window/window_native_api.dart';
import 'core/window/window_native_api_windows.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'core/window/tray_manager.dart';
import 'core/services/preferences_service.dart';
import 'core/services/audio_service.dart';
import 'ui/main_toolbar.dart';
import 'plugins/screen_recorder/providers/screen_recorder_provider.dart';
import 'plugins/screenshot/providers/screenshot_provider.dart';
import 'core/providers/hotkey_provider.dart';
import 'core/window/window_constants.dart';
import 'ui/widgets/sqa_styles.dart';
import 'ui/widgets/sqa_scroll_behavior.dart';
import 'core/ui/sqa_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the platform-specific native window API implementation.
  // Add else-if branches here when macOS / Linux support is added.
  // See docs/platform_porting_guide.md for instructions.
  if (Platform.isWindows) {
    WindowNativeApi.register(WindowNativeApiWindows());
  }

  AudioService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  await windowManager.ensureInitialized();

  final alwaysOnTop = prefs.getBool('always_on_top') ?? true;

  const windowOptions = WindowOptions(
    size: Size(
      WindowConstants.kDefaultWindowWidth,
      WindowConstants.kToolbarWindowHeight,
    ),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.setIcon('assets/desktop_new.png');
    await windowManager.setAlwaysOnTop(alwaysOnTop);
    await windowManager.setMinimumSize(
      const Size(
        WindowConstants.kDefaultWindowWidth,
        WindowConstants.kToolbarWindowHeight,
      ),
    );
    await windowManager.setPreventClose(true);
    await WindowUtils.safeShow();
    await windowManager.focus();
  });

  await TrayManager.init();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SqaMultitoolsApp(),
    ),
  );
}



class SqaMultitoolsApp extends ConsumerWidget {
  const SqaMultitoolsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final themeMode = ThemeMode.values[settings.modeIndex];

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightTheme = SqaTheme.createTheme(
          brightness: Brightness.light,
          dynamicScheme: lightDynamic,
          seedColor: Color(settings.seedColorValue),
          useDynamicColor: settings.useDynamicColor,
        );

        final darkTheme = SqaTheme.createTheme(
          brightness: Brightness.dark,
          dynamicScheme: darkDynamic,
          seedColor: Color(settings.seedColorValue),
          useDynamicColor: settings.useDynamicColor,
        );

        return MaterialApp(
          title: 'SQA-Multitools',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          scrollBehavior: const SqaMouseDragScrollBehavior(),
          theme: lightTheme,
          darkTheme: darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppFlowyEditorLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          builder: (context, child) {
            final isScreenshotVisible =
                ref.watch(screenshotProvider).isOverlayVisible;
            final isRecorderVisible =
                ref.watch(screenRecorderProvider).isOverlayVisible;
            final isOverlayActive = isScreenshotVisible || isRecorderVisible;

            final settings = ref.watch(themeSettingsProvider);

            return Opacity(
              opacity: isOverlayActive
                  ? 1.0
                  : (settings.isTransparencyModeEnabled
                      ? settings.opacity
                      : 1.0),
              child: ClipRRect(
                borderRadius: isOverlayActive
                    ? BorderRadius.zero
                    : SqaStyles.borderRadiusWindow,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Material(
                  color: isOverlayActive ? Colors.transparent : null,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
          home: const HotkeyInitializer(child: MainToolbar()),
        );
      },
    );
  }
}

/// A wrapper widget that initializes centralized hotkeys using Riverpod.
class HotkeyInitializer extends ConsumerWidget {
  final Widget child;
  const HotkeyInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use a post-frame callback to ensure the notifier is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Warm up providers to ensure they are instantiated and register their hotkeys
      ref.read(screenRecorderProvider);
      ref.read(screenshotProvider);

      ref.read(hotkeySettingsProvider.notifier).setToolbarCallback(() async {
        await WindowUtils.safeShow();
      });
    });

    return child;
  }
}
