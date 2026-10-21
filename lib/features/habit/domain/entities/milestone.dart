/// Streak lengths that show the celebration sheet (HAB-01), with the bit
/// they use in `habits.celebrated_milestones` (data-model.md §3.1).
/// Append-only: the bit index is the enum index.
enum Milestone {
  d7(7),
  d21(21),
  d30(30),
  d50(50),
  d100(100),
  d365(365);

  new(this.value);

  /// Streak length (days, or weeks for "times per week" habits).
  final int value;

  int get bit => 1 << index;

  static Set<Milestone> fromMask(int mask) => {
    for (final m in values)
      if (mask & m.bit != 0) m,
  };

  static int toMask(Set<Milestone> milestones) =>
      milestones.fold(0, (mask, m) => mask | m.bit);
}
