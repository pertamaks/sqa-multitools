import 'package:dbus/dbus.dart';
import 'dart:async';
import 'dart:io';

void main() async {
  final client = DBusClient.session();
  final object = DBusRemoteObject(
    client,
    name: 'org.freedesktop.portal.Desktop',
    path: DBusObjectPath('/org/freedesktop/portal/desktop'),
  );

  print('Calling portal...');
  final response = await object.callMethod(
    'org.freedesktop.portal.Screenshot',
    'Screenshot',
    [
      DBusString(''),
      DBusDict.stringVariant({
        'interactive': DBusBoolean(false),
      }),
    ],
  );

  final requestPath = response.returnValues[0].asObjectPath();
  print('Request path: $requestPath');

  final requestObject = DBusRemoteObject(
    client,
    name: 'org.freedesktop.portal.Desktop',
    path: requestPath,
  );

  final completer = Completer<String?>();
  final sub = DBusRemoteObjectSignalStream(
    object: requestObject,
    interface: 'org.freedesktop.portal.Request',
    name: 'Response',
  ).listen((signal) {
    print('Got signal: ${signal.values}');
    if (signal.values.length >= 2) {
      final code = signal.values[0].asUint32();
      if (code == 0) {
        final results = signal.values[1].asStringVariantDict();
        // we might need to parse it manually
        for (var key in results.keys) {
          if (key == 'uri') {
            completer.complete(results[key]!.asString());
            return;
          }
        }
      }
    }
    completer.complete(null);
  });

  final uri = await completer.future;
  print('URI: $uri');
  await sub.cancel();
  await client.close();
}
