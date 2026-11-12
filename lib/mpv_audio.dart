import 'package:mpv_audio/core/keys.dart';
import 'package:mpv_audio/mpv_audio_bindings_generated.dart';

/// custom libpath
MpvAudioBindings getMpv({String? libPath}) {
  if (libPath != null) {
    return MpvAudioBindings(.open(libPath));
  }
  return MpvAudioBindings(.open(mpvLibName));
}
