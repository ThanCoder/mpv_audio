// ignore_for_file: unused_import

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:mpv_audio/core/result_t.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';
import 'package:mpv_audio/mpv_audio.dart';

const String path =
    '/home/thancoder/Downloads/mpv_audio_lib/libmpv_linux-x86_64/libmpv_audio.so';
const String aPath = '/home/thancoder/Music/test.mp3';

void main() {
  final mpv = MpvAudio(libPath: path);
  mpv.init();

  final res = mpv.playAudio(aPath);

  if (res.isErr) {
    print('error: ${res.unwrapError()}');
  }

  // stdout.writeln("Wait...");
  // stdin.readLineSync();
}
