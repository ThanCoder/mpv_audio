// ignore_for_file: avoid_print

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'archive_lib.dart';

Future<void> downloadLib(String url, File output) async {
  final client = HttpClient();

  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Download failed: ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }

    await output.parent.create(recursive: true);

    final sink = output.openWrite();

    try {
      await response.pipe(sink);
    } finally {
      await sink.close();
    }
  } catch (e) {
    if (await output.exists()) {
      await output.delete();
    }

    rethrow;
  } finally {
    client.close(force: true);
  }
}

Future<void> extractZip(
  File input, {
  required Directory outDir,
  required List<ArchiveLib> libs,
}) async {
  final archive = ZipDecoder().decodeBytes(input.readAsBytesSync());
  await outDir.create(recursive: true);

  for (var lib in libs) {
    final libFile = File(p.join(outDir.path, lib.libName));
    if (libFile.existsSync()) continue;
    final f = archive.findFile(lib.archivePath);
    if (f == null) {
      throw PathNotFoundException(lib.archivePath, .new('Not Found Lib Path'));
    }
    await libFile.writeAsBytes(f.content, flush: true);
  }
}

extension DurationX on Duration {
  String toTimeString() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

String formatFileSizeLable(int size) {
  if (size <= 0) return '0 bytes';
  int i = 0;
  final pow = 1024;
  final list = ['bytes', 'KB', 'MB', 'GB', 'TB'];
  double sizeD = size.toDouble();
  while (sizeD > pow && i < (list.length - 1)) {
    sizeD /= pow;
    i++;
  }
  return '${sizeD.toStringAsFixed(2)} ${list[i]}';
}

extension StringX on String {
  String join(String name) {
    return '$this${Platform.pathSeparator}$name';
  }

  String get nameOnly {
    return split(Platform.pathSeparator).last;
  }
}

extension MapX on Map<String, dynamic> {
  String getStringOr(String key, String def) {
    final val = _getOrNull<String>(key);
    return val ?? def;
  }

  int getIntOr(String key, int def) {
    return _getOr<int>(key, def);
  }

  double getDoubleOr(String key, double def) {
    return _getOr<double>(key, def);
  }

  T _getOr<T>(String key, T def) {
    final val = _getOrNull<T>(key);
    return val ?? def;
  }

  T? _getOrNull<T>(String key) {
    final val = this[key];

    if (val is T) {
      return val;
    }

    if (val == null) return null;

    return switch (T) {
      String => val.toString() as T?,
      int =>
        (val is String ? int.tryParse(val) : int.tryParse(val.toString()))
            as T?,
      double =>
        (val is String ? double.tryParse(val) : double.tryParse(val.toString()))
            as T?,
      bool => (val is String ? bool.tryParse(val) : null) as T?,
      _ => null,
    };
  }
}
