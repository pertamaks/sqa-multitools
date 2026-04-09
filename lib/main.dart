import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/window/tray_manager.dart';
import 'core/services/preferences_service.dart';
import 'core/services/audio_service.dart';
import 'ui/main_toolbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  await windowManager.ensureInitialized();

  await hotKeyManager.unregisterAll();
  await hotKeyManager.register(
    HotKey(
      key: PhysicalKeyboardKey.space,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    ),
    keyDownHandler: (hotKey) async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  const windowOptions = WindowOptions(
    size: Size(kDefaultWindowWidth, kToolbarWindowHeight),
    center: true,
    backgroundColor: Color(0xFF1C1B1F),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
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
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            pageTransitionsTheme: noTransitions,
          ),
          builder: (context, child) {
            return Material(child: child ?? const SizedBox.shrink());
          },
          home: const MainToolbar(),
        );
      },
    );
  }
}
