import 'dart:convert';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Every catalog SVG renders using Flutter SVG', () async {
    const staged = bool.fromEnvironment('VALIDATE_STAGED_ICONS');
    final directory = Directory(staged ? '.local/icon-sources/staged' : 'assets/services');
    final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.svg')).toList();
    expect(files.length, greaterThanOrEqualTo(100));
    final failures = <String>[];
    for (final file in files) {
      try {
        final picture = await vg.loadPicture(SvgStringLoader(await file.readAsString()), null);
        picture.picture.dispose();
      } catch (_) {
        failures.add(file.uri.pathSegments.last);
      }
    }
    if (staged) {
      File('.local/icon-sources/validation.json').writeAsStringSync(jsonEncode({'count': files.length, 'failures': failures}));
    } else {
      expect(failures, isEmpty, reason: 'All bundled icons must render');
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}
