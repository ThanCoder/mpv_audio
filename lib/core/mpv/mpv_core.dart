import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mpv_audio/core/mpv/types.dart';
import 'package:mpv_audio/core/result_t.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';

///create && init
Result<Pointer<mpv_handle>, String> createMpv(MpvAudioBindings lib) {
  final mpv = lib.mpv_create();

  if (mpv == nullptr) {
    return Err('mpv create failed');
  }
  final result = lib.mpv_initialize(mpv);
  if (result < 0) {
    return Err('mpv_initialize failed: $result');
  }
  return Ok(mpv);
}

/// run command
Result<bool, String> runMpvCommand(
  MpvAudioBindings lib,
  Pointer<mpv_handle> mpv,
  MpvCommand command,
  String file,
  MpvLoadMode loadMode,
) {
  final args = calloc<Pointer<Char>>(4);

  final commandN = command.command.toNativeUtf8();
  final fileN = file.toNativeUtf8();
  final modeN = loadMode.mode.toNativeUtf8();

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

/// mpv observe
void mpvObserve(
  MpvAudioBindings lib,
  Pointer<mpv_handle> mpv,
  String name,
  int userdata,
  mpv_format format,
) {
  final ptr = name.toNativeUtf8();

  try {
    final result = lib.mpv_observe_property(
      mpv,
      userdata,
      ptr.cast<Char>(),
      format,
    );

    if (result < 0) {
      throw Exception('Observe failed: $name ($result)');
    }
  } finally {
    malloc.free(ptr);
  }
}
