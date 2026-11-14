import 'dart:ffi';
import 'dart:isolate';

import 'package:mpv_audio/mpv_audio.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';

class BgEventThread {
  Isolate? _isolate;
  final ReceivePort _rx = ReceivePort();

  Future<void> init(String? libPath, int mpvAddress) async {
    _isolate = await Isolate.spawn<(String?, int, SendPort)>(_bgBgEventThread, (
      libPath,
      mpvAddress,
      _rx.sendPort,
    ));
    await _rx.first;
    print('init BgEventThread');
  }

  Future<void> dispose() async {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
    }
  }
}

///libpath,mpv address,sendport
void _bgBgEventThread((String?, int, SendPort) args) {
  final (libPath, mpvAddress, mainPort) = args;
  final lib = getMpvLib(libPath: libPath);
  final mpv = Pointer<mpv_handle>.fromAddress(mpvAddress);

  mainPort.send(true);

  while (true) {
    final event = lib.mpv_wait_event(mpv, 0.1);

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
    }
  }
}
