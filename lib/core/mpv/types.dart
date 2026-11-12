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
