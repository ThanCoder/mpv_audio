import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

typedef SetLocaleNative = ffi.Pointer<ffi.Char> Function(
  ffi.Int32 category,
  ffi.Pointer<ffi.Char> locale,
);

typedef SetLocaleDart = ffi.Pointer<ffi.Char> Function(
  int category,
  ffi.Pointer<ffi.Char> locale,
);

///set local
void setNumericLocale() {
  final libc = ffi.DynamicLibrary.process();

  final setlocale = libc.lookupFunction<SetLocaleNative, SetLocaleDart>(
    'setlocale',
  );

  final locale = 'C'.toNativeUtf8();

  try {
    final result = setlocale(1, locale.cast<ffi.Char>());
    print('setlocale result: ${result.cast<Utf8>().toDartString()}');
  } finally {
    calloc.free(locale);
  }
}
