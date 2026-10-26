/// Where a native ad sits (spec §11 table). Used only to tag requests for
/// reporting; never carries app data (FR-010). Pure Dart.
enum NativePlacement { home, transactions, budgets, habits }
