import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  await windowManager.ensureInitialized();

  await windowManager.ensureInitialized();

  final alwaysOnTop = prefs.getBool('always_on_top') ?? true;

  const windowOptions = WindowOptions(
    size: Size(kDefaultWindowWidth, kToolbarWindowHeight),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlwaysOnTop(alwaysOnTop);
    await windowManager.setMinimumSize(
      const Size(kDefaultWindowWidth, kToolbarWindowHeight),
    );
    await windowManager.setPreventClose(true);
    await windowManager.show();
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

/// A no-animation page transition that renders the child immediately.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class SqaMultitoolsApp extends ConsumerWidget {
  const SqaMultitoolsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const noTransitions = PageTransitionsTheme(
      builders: {TargetPlatform.windows: _NoTransitionsBuilder()},
    );

    final settings = ref.watch(themeSettingsProvider);
    final themeMode = ThemeMode.values[settings.modeIndex];

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme? lightScheme;
        ColorScheme? darkScheme;

        if (settings.useDynamicColor &&
            lightDynamic != null &&
            darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          final seedColor = Color(settings.seedColorValue);
          lightScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'SQA-Multitools',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            pageTransitionsTheme: noTransitions,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppFlowyEditorLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            pageTransitionsTheme: noTransitions,
          ),
          builder: (context, child) {
            final isScreenshotVisible = ref
                .watch(screenshotProvider)
                .isOverlayVisible;
            final isRecorderVisible = ref
                .watch(screenRecorderProvider)
                .isOverlayVisible;
            final isOverlayActive = isScreenshotVisible || isRecorderVisible;

            return Material(
              color: isOverlayActive ? Colors.transparent : null,
              child: child ?? const SizedBox.shrink(),
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
      ref.read(hotkeySettingsProvider.notifier).setToolbarCallback(() async {
        await windowManager.show();
        await windowManager.focus();
      });
    });

    return child;
  }
}
