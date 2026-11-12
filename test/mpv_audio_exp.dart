import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mpv_audio/core/result_t.dart';
import 'package:mpv_audio/mpv_audio.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';

const String path =
    '/home/thancoder/Downloads/mpv_audio_lib/libmpv_linux-x86_64/libmpv_audio.so';
const String aPath = '/home/thancoder/Music/test.mp3';
final lib = getMpv(libPath: path);
void main() {
  final mpv = lib.mpv_create();

  if (mpv == nullptr) {
    throw Exception('mpv create failed');
  }
  final result = lib.mpv_initialize(mpv);
  if (result < 0) {
    throw Exception('mpv_initialize failed: $result');
  }

  runMpvCommand(mpv, 'loadfile', aPath, 'replace');
}

Result<bool, String> runMpvCommand(
  Pointer<mpv_handle> mpv,
  String command,
  String file,
  String mode,
) {
  final args = calloc<Pointer<Char>>(4);

  final commandN = command.toNativeUtf8();
  final fileN = file.toNativeUtf8();
  final modeN = mode.toNativeUtf8();

  args[0] = commandN.cast<Char>();
  args[1] = fileN.cast<Char>();
  args[2] = modeN.cast<Char>();
  args[3] = nullptr;

  try {
    final res = lib.mpv_command(mpv, args);
    if (res < 0) {
      return Err('mpv_command failed: $res');
    }
    return Ok(true);
  } catch (e) {
    return Err(e.toString());
  } finally {
    malloc.free(commandN);
    malloc.free(fileN);
    malloc.free(modeN);
    calloc.free(args);
  }
}
