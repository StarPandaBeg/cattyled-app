import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<Version> fetchVersion(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw Error();

  final version = response.body;
  return Version.parse(version);
}

Future<bool> tryHttpSocket(String ip) async {
  return Socket.connect(
    ip,
    80,
    timeout: const Duration(milliseconds: 500),
  ).then(
    (s) async {
      await s.close();
      return true;
    },
  ).catchError((_) => false);
}

Future<bool> tryWebsocketConnection(String ip) async {
  final socketOk = await tryHttpSocket(ip);
  if (!socketOk) return false;

  final uri = Uri.parse('ws://$ip/ws');
  final connection = WebSocketChannel.connect(uri);

  try {
    await connection.ready;
    await connection.sink.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> findAvailableIp(String ip) async {
  final String subnet = ip.substring(0, ip.lastIndexOf('.'));
  final List<Future<String?>> tasks = [];
  final completer = Completer<String?>();

  for (var i = 0; i < 256; i += 8) {
    if (completer.isCompleted) break;

    final batch = List.generate(
      8,
      (index) {
        final targetIP = '$subnet.${i + index}';
        log("Trying $targetIP");
        return tryWebsocketConnection(targetIP).then((result) {
          if (result && !completer.isCompleted) {
            completer.complete(targetIP);
          }
          return result ? targetIP : null;
        });
      },
    );

    tasks.addAll(batch);
    await Future.wait(batch);
  }
  return completer.isCompleted ? completer.future : null;
}

Future<bool> checkAppUpdates() async {
  try {
    const url = String.fromEnvironment("UPDATE_URL");
    final remoteVersion = await fetchVersion("$url/ver.txt");
    final localVersion = await getAppVersion();
    return (remoteVersion > Version.parse(localVersion));
  } catch (e) {
    return false;
  }
}

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<bool> gotoAppUpdates() async {
  const urlBase = String.fromEnvironment("UPDATE_URL");
  final url = Uri.parse("$urlBase/app.apk");
  return await launchUrl(url);
}
