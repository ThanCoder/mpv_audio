enum MpvCommand {
  loadfile,
  stop,
  set,
  seek,
  playlistNext('playlist-next'),
  playlistPrev('playlist-prev'),
  playlistClear('playlist-clear'),
  cycle;

  const MpvCommand([this.value]);

  final String? value;

  String get command => value ?? name;
}

enum MpvLoadMode {
  replace,
  append,
  appendPlay('append+play'),
  insertNext('insert-next'),
  insertNextPlay('insert-next+play'),
  insertAt('insert-at'),
  insertAtPlay('insert-at+play');

  const MpvLoadMode([this.value]);

  final String? value;

  String get mode => value ?? name;
}

enum AudioArgCommand {
  ///['loadfile', path, 'replace'],
  play,

  /// [
  //   'seek',
  //   seconds.toString(),
  //   relative ? 'relative' : 'absolute',
  // ],
  seek,

  ///['set', 'volume', volume.toString()],
  setVolume,
}

enum AudioCommand {
  ///['loadfile', path, 'replace'],
  // play,

  /// ['stop'],
  stop,

  /// ['set', 'pause', 'yes'],
  pause,

  /// ['set', 'pause', 'no'],
  resume,

  /// ['cycle', 'pause'],
  togglePause;

  /// [
  //   'seek',
  //   seconds.toString(),
  //   relative ? 'relative' : 'absolute',
  // ],
  // seek,

  ///['set', 'volume', volume.toString()],
  // setVolume;

  List<String> toArgs() {
    return switch (this) {
      stop => ['stop'],
      pause => ['set', 'pause', 'yes'],
      resume => ['set', 'pause', 'no'],
      togglePause => ['cycle', 'pause'],
    };
  }
}
