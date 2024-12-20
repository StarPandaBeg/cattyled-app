import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

Future<Version> fetchVersion(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw Error();

  final version = response.body;
  return Version.parse(version);
}
