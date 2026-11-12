import 'dart:async';
import 'dart:ffi';

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

  void init() async {
    final res = createMpv(_lib);
    if (res.isErr) {
      throw Exception(res.unwrapError());
    }
    _mpv = res.unwrap();

    mpvObserve(_lib, _mpv, 'time-pos', 1, mpv_format.MPV_FORMAT_DOUBLE);

    mpvObserve(_lib, _mpv, 'duration', 2, mpv_format.MPV_FORMAT_DOUBLE);

    mpvObserve(_lib, _mpv, 'pause', 3, mpv_format.MPV_FORMAT_FLAG);
  }

  /// close && free memory
  void dispose() {
    if (_mpv != nullptr) {
      _lib.mpv_terminate_destroy(_mpv);
    }
  }

  Result<bool, String> playAudio(String path) {
    final res = runMpvCommand(_lib, _mpv, .loadfile, path, .replace);
    if (res.isOk) {
      _waitEvents();
    }
    return res;
  }

  bool _isListening = false;

  Future<void> _waitEvents() async {
    if (_isListening) return;

    _isListening = true;

    try {
      while (_isListening) {
        final event = _lib.mpv_wait_event(_mpv, 0.1);

        final eventId = event.ref.event_id;

        if (eventId == mpv_event_id.MPV_EVENT_NONE) {
          continue;
        }

        if (eventId == mpv_event_id.MPV_EVENT_PROPERTY_CHANGE) {
          final userdata = event.ref.reply_userdata;
          final property = event.ref.data.cast<mpv_event_property>();

          if (property == nullptr) continue;

          if (property.ref.format == mpv_format.MPV_FORMAT_NONE) {
            continue;
          }

          switch (userdata) {
            case 1:
              final position = property.ref.data.cast<Double>().value;
              print('Position: $position seconds');

            case 2:
              final duration = property.ref.data.cast<Double>().value;
              print('Duration: $duration seconds');

            case 3:
              final paused = property.ref.data.cast<Int32>().value != 0;
              print('Paused: $paused');
          }
        }

        if (eventId == mpv_event_id.MPV_EVENT_START_FILE) {
          print('Starting file...');
        }
        if (eventId == mpv_event_id.MPV_EVENT_FILE_LOADED) {
          print('File loaded!');
        }
        if (eventId == mpv_event_id.MPV_EVENT_PLAYBACK_RESTART) {
          print('Playback started!');
        }
        if (eventId == mpv_event_id.MPV_EVENT_END_FILE) {
          print('Playback ended!');
        }
        if (eventId == mpv_event_id.MPV_EVENT_SHUTDOWN) {
          print('Player shutdown!');
          _isListening = false;
        }
      }
    } finally {
      _isListening = false;
    }
  }
}
