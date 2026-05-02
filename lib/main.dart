import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/window/window_utils.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          // Generate the accent-based scheme for primary/secondary roles
          lightScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );

          // M3's fromSeed tints ALL colors with the seed hue, making
          // "white" text/icons appear colored with saturated seeds.
          // Override neutral roles with a grey-based scheme to keep
          // surfaces and text clean while preserving the accent.
          final neutralLight = ColorScheme.fromSeed(
            seedColor: Colors.grey,
            brightness: Brightness.light,
          );
          final neutralDark = ColorScheme.fromSeed(
            seedColor: Colors.grey,
            brightness: Brightness.dark,
          );

          lightScheme = lightScheme.copyWith(
            surface: neutralLight.surface,
            onSurface: neutralLight.onSurface,
            onSurfaceVariant: neutralLight.onSurfaceVariant,
            surfaceContainerLowest: neutralLight.surfaceContainerLowest,
            surfaceContainerLow: neutralLight.surfaceContainerLow,
            surfaceContainer: neutralLight.surfaceContainer,
            surfaceContainerHigh: neutralLight.surfaceContainerHigh,
            surfaceContainerHighest: neutralLight.surfaceContainerHighest,
            outline: neutralLight.outline,
            outlineVariant: neutralLight.outlineVariant,
          );
          darkScheme = darkScheme.copyWith(
            surface: neutralDark.surface,
            onSurface: neutralDark.onSurface,
            onSurfaceVariant: neutralDark.onSurfaceVariant,
            surfaceContainerLowest: neutralDark.surfaceContainerLowest,
            surfaceContainerLow: neutralDark.surfaceContainerLow,
            surfaceContainer: neutralDark.surfaceContainer,
            surfaceContainerHigh: neutralDark.surfaceContainerHigh,
            surfaceContainerHighest: neutralDark.surfaceContainerHighest,
            outline: neutralDark.outline,
            outlineVariant: neutralDark.outlineVariant,
          );
        }

        return MaterialApp(
          title: 'SQA-Multitools',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          scrollBehavior: const SqaMouseDragScrollBehavior(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            pageTransitionsTheme: noTransitions,
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: WidgetStateProperty.all(true),
              trackVisibility: WidgetStateProperty.all(false),
              thickness: WidgetStateProperty.all(4.0),
              radius: const Radius.circular(2.0),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.dragged)) {
                  return lightScheme?.primary.withValues(alpha: 0.8);
                }
                return lightScheme?.primary.withValues(alpha: 0.5);
              }),
              interactive: true,
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
              dayOverlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return lightScheme?.primary.withValues(alpha: 0.08);
                }
                if (states.contains(WidgetState.pressed)) {
                  return lightScheme?.primary.withValues(alpha: 0.12);
                }
                return null;
              }),
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              dayStyle: const TextStyle(fontSize: 14),
            ),
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusMedium,
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusMedium,
              ),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return lightScheme!.primaryContainer;
                }
                return lightScheme!.surfaceContainerHigh;
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return lightScheme!.onPrimaryContainer;
                }
                return lightScheme!.onSurface;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return lightScheme!.primary;
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return lightScheme!.onPrimary;
                }
                return lightScheme!.onSurfaceVariant;
              }),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: WidgetStateProperty.all(true),
              trackVisibility: WidgetStateProperty.all(false),
              thickness: WidgetStateProperty.all(4.0),
              radius: const Radius.circular(2.0),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.dragged)) {
                  return darkScheme?.primary.withValues(alpha: 0.8);
                }
                return darkScheme?.primary.withValues(alpha: 0.5);
              }),
              interactive: true,
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
              dayOverlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return darkScheme?.primary.withValues(alpha: 0.08);
                }
                if (states.contains(WidgetState.pressed)) {
                  return darkScheme?.primary.withValues(alpha: 0.12);
                }
                return null;
              }),
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              dayStyle: const TextStyle(fontSize: 14),
            ),
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusMedium,
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusMedium,
              ),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return darkScheme!.primaryContainer;
                }
                return darkScheme!.surfaceContainerHigh;
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return darkScheme!.onPrimaryContainer;
                }
                return darkScheme!.onSurface;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return darkScheme!.primary;
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return darkScheme!.onPrimary;
                }
                return darkScheme!.onSurfaceVariant;
              }),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
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
