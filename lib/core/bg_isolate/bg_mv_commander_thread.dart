import 'dart:ffi';
import 'dart:isolate';

import 'package:mpv_audio/core/mpv/mpv_core.dart';
import 'package:mpv_audio/core/mpv/types.dart';
import 'package:mpv_audio/core/result_t.dart';
import 'package:mpv_audio/mpv_audio.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';

enum MvpBgCommand { dispose }

class BgMvCommanderThread {
  Isolate? _isolate;
  SendPort? _tx;

  Future<void> init(String? libPath, int mpvAddress) async {
    final ReceivePort rx = ReceivePort();
    _isolate = await Isolate.spawn<(String?, int, SendPort)>(
      _bgBgMvCommanderThread,
      (libPath, mpvAddress, rx.sendPort),
    );
    _tx = await rx.first as SendPort;
    rx.close();
    print('init BgMvCommanderThread');
  }

  Future<void> dispose() async {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
    }
  }

  Future<Result<bool, String>> sendCommand(
    String? path, {
    required MpvCommand command,
    required MpvLoadMode mode,
  }) async {
    final tx = _tx;
    if (tx == null) {
      return Err('bg `SendPort` is null');
    }
    final ReceivePort rx = ReceivePort();

    _tx!.send({'command': command, 'mpvLoadMode': mode, 'path': path});
    final res = await rx.first as Map;
    final success = res['success'] as bool;
    rx.close();
    if (success) {
      return Ok(true);
    }
    return Err(res['message'] as String);
  }
}

///libpath,mpv address,sendport
void _bgBgMvCommanderThread((String?, int, SendPort) args) {
  final (libPath, mpvAddress, mainPort) = args;
  final lib = getMpvLib(libPath: libPath);
  final mpv = Pointer<mpv_handle>.fromAddress(mpvAddress);
  final rx = ReceivePort();
  mainPort.send(rx.sendPort);

  rx.listen((msg) {
    if (msg is MvpBgCommand) {
      if (msg == .dispose) {
        // clean up
        mainPort.send(true);
        rx.close();
      }
    }

    if (msg is Map) {
      try {
        final command = msg['command'] as AudioCommand;
        final mpvLoadMode = msg['mpvLoadMode'] as MpvLoadMode;
        final path = msg['path'] as String;

        print('bg path');

        final res = runMpvCommand(lib, mpv, path, command, mpvLoadMode);
        res.onResult(
          onErr: (err) {
            mainPort.send({'success': false, 'message': err});
          },
          onOk: (val) {
            mainPort.send({'success': val});
          },
        );
      } catch (e) {
        mainPort.send({'success': false, 'message': e.toString()});
      }
    }
  });
}
