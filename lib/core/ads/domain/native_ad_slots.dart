/// Global row indexes an EXP-01 native ad goes in front of: after row
/// [first], then every [every] rows, at most [max] per screen load (spec
/// §11). An ad only goes between two rows, never after the last one.
/// `nativeAdRowIndexes(40) == [8, 23, 38]`. Pure Dart.
List<int> nativeAdRowIndexes(
  int rowCount, {
  int first = 8,
  int every = 15,
  int max = 3,
}) => [
  for (var i = 0, row = first; i < max && row < rowCount; i++, row += every)
    row,
];
