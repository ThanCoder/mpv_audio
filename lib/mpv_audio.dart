import 'dart:async';
import 'dart:ffi';

import 'package:mpv_audio/core/bg_isolate/bg_event_thread.dart';
import 'package:mpv_audio/core/bg_isolate/bg_mv_commander_thread.dart';
import 'package:mpv_audio/core/keys.dart';
import 'package:mpv_audio/core/mpv/mpv_core.dart';
import 'package:mpv_audio/core/result_t.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';

/// custom libpath
MpvAudioBindings getMpvLib({String? libPath}) {
  if (libPath != null) {
    return MpvAudioBindings(.open(libPath));
  }
  return MpvAudioBindings(.open(mpvLibName));
}

class MpvAudio {
  final String? _libPath;
  new({this._libPath});

  MpvAudioBindings get _lib => getMpvLib(libPath: _libPath);

  Pointer<mpv_handle> _mpv = nullptr;

  int get mpvClientApiVersion => _lib.mpv_client_api_version();

  final BgEventThread _bgEventThread = .new();
  final BgMvCommanderThread _bgMvCommanderThread = .new();

  ///  initialized
  void init() async {
    final res = createMpv(_lib);
    if (res.isErr) {
      throw Exception(res.unwrapError());
    }
    _mpv = res.unwrap();

    // Pointer<mpv_handle>.fromAddress(1);

    mpvObserve(_lib, _mpv, 'time-pos', 1, mpv_format.MPV_FORMAT_DOUBLE);

    mpvObserve(_lib, _mpv, 'duration', 2, mpv_format.MPV_FORMAT_DOUBLE);

    mpvObserve(_lib, _mpv, 'pause', 3, mpv_format.MPV_FORMAT_FLAG);

    // await _bgEventThread.init(_libPath, _mpv.address);
    await _bgMvCommanderThread.init(_libPath, _mpv.address);
  }

  /// close && free memory
  Future<void> dispose() async {
    await _bgEventThread.dispose();
    await _bgMvCommanderThread.dispose();

    if (_mpv != nullptr) {
      _lib.mpv_terminate_destroy(_mpv);
    }
  }

  Future<Result<bool, String>> playAudio(String path) async {
    return await _bgMvCommanderThread.sendCommand(
      path,
      command: .loadfile,
      mode: .replace,
    );
  }

  Future<Result<bool, String>> pause(String path) async {
    return await _bgMvCommanderThread.sendCommand(
      path,
      command: .stop,
      mode: .replace,
    );
  }
}
