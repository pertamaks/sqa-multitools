import 'package:dbus/dbus.dart';
import 'dart:async';

void main() async {
  final client = DBusClient.session();
  final object = DBusRemoteObject(
    client,
    name: 'org.gnome.Shell.Screencast',
    path: DBusObjectPath('/org/gnome/Shell/Screencast'),
  );

  await object.callMethod(
    'org.gnome.Shell.Screencast',
    'Screencast',
    [
      DBusString('sqa_rec_%d_%t.webm'),
      DBusDict.stringVariant({}),
    ],
  );

  print('Started. Waiting 5 seconds before closing client...');
  await Future.delayed(Duration(seconds: 5));
  print('Closing client now - does the screencast stop?');
  await client.close();
}
