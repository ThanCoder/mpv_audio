sealed class Result<T, E> {
  const new();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() => switch (this) {
    Ok(val: final val) => val,
    Err() => throw StateError('Called `unwrap()` on Err'),
  };
  E unwrapError() => switch (this) {
    Err(val: final val) => val,
    Ok() => throw StateError('Called `unwrapError()` on Err'),
  };
  R fold<R>({
    required R Function(E err) onErr,
    required R Function(T val) onOk,
  }) => switch (this) {
    Ok(val: final val) => onOk(val),
    Err(val: final val) => onErr(val),
  };

  void onResult({
    required void Function(E err) onErr,
    required void Function(T val) onOk,
  }) => switch (this) {
    Ok(val: final val) => onOk(val),
    Err(val: final val) => onErr(val),
  };
  void onError({required void Function(E err) onErr}) => switch (this) {
    Ok() => {},
    Err(val: final val) => onErr(val),
  };
}

class Ok<T, E> extends Result<T, E> {
  final T val;
  const new(this.val);
}

class Err<T, E> extends Result<T, E> {
  final E val;
  const new(this.val);
}
