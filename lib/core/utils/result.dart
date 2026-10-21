/// A value or an error, without exceptions.
sealed class Result<T, E> {
  const new();
}

final class Ok<T, E> extends Result<T, E> {
  const new(this.value);

  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const new(this.error);

  final E error;
}
