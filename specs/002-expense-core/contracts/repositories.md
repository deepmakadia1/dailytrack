# Contract: Expense domain interfaces

Location: `lib/features/expense/domain/` (pure Dart: no Flutter, Drift, or plugin imports).
Implementations: `lib/features/expense/data/` (Drift DAOs, mappers, plugin adapters). Test fakes:
`test/features/expense/fakes.dart`.

Every `watch*` stream re-emits after any write to `transactions`, `categories`, or `accounts`
(FR-008). Every method that can fail returns or throws only the typed errors listed here. Data
implementations translate `SqliteException` into `ExpenseStorageFailure`.

## TransactionRepository

```dart
abstract interface class TransactionRepository {
  /// Rows matching [query], newest first (occurredAt, createdAt, id DESC),
  /// at most [limit]. Excludes deleted rows. (R4)
  Stream<List<TransactionView>> watchPage(TxnQuery query, {required int limit});

  /// Income/expense/net and per-local-day totals for ALL rows matching
  /// [query]; transfers excluded from every total. (R4, FR-018)
  Stream<PeriodLedger> watchLedger(TxnQuery query);

  Stream<TransactionView?> watchById(String id);           // EXP-03; null if missing or deleted
  Future<TransactionView?> findById(String id);            // EXP-02 edit, duplicate

  /// Spent today and this month in local time (expenses only). (FR-030)
  Stream<TodayAndMonthSpend> watchTodayAndMonthSpend(DateTime nowLocal);

  /// Up to [limit] distinct non-empty notes, most recent first, optionally
  /// filtered by [prefix] (case-insensitive). (EXP-02 note suggestions)
  Future<List<String>> recentNotes({String prefix = '', int limit = 5});

  /// Account of the most recently created non-deleted transaction whose
  /// account is not archived, or null. (R7)
  Future<String?> lastUsedAccountId();

  Future<Transaction> create(TransactionDraft draft);      // validated by caller; id/timestamps assigned here
  Future<Transaction> update(String id, TransactionDraft draft); // throws TransactionNotFound if missing or deleted
  Future<void> restore(Transaction snapshot);              // undo of an edit: rewrites every field (R12)
  Future<void> softDelete(String id);
  Future<void> undelete(String id);

  /// Every non-null receiptPath, INCLUDING soft-deleted rows, so a later
  /// restore keeps its file. Input to ReceiptStore.pruneOrphans. (R8, T059)
  Future<Set<String>> allReceiptPaths();

  /// DEBUG ONLY: inserts [count] varied transactions in batches for the
  /// SC-005 scroll check. Called only behind kDebugMode; the fake is a no-op. (T115)
  Future<void> debugSeed(int count);
}
```

## CategoryRepository

```dart
abstract interface class CategoryRepository {
  /// Non-deleted categories of [type] in sortOrder, with this local month's
  /// total and all-time usage count. Hidden ones included (flagged). (EXP-04)
  Stream<List<CategoryWithStats>> watchByType(CategoryType type, {required Period month});

  /// Non-hidden categories of [type] for EXP-02: usageCount DESC, sortOrder ASC. (Q2, R7)
  Stream<List<Category>> watchPickable(CategoryType type);

  Stream<List<Category>> watchAll();                       // incl. hidden; for row display, search, filters

  Future<Category> create({required String name, required CategoryType type,
      required String iconKey, required String colorHex});
  Future<void> update(String id, {required String name, required String iconKey,
      required String colorHex});                          // type is fixed
  Future<void> setHidden(String id, {required bool hidden});
  Future<void> reorder(CategoryType type, List<String> orderedIds);

  Future<int> transactionCount(String id);                 // non-deleted transactions

  /// Soft-deletes a custom category. If it has transactions, [replacementId]
  /// is required and they are moved first, in one DB transaction.
  /// Throws CategoryDeleteNotAllowed(isDefault | replacementRequired | invalidReplacement).
  Future<void> delete(String id, {String? replacementId});
  Future<void> undelete(String id);
}
```

## AccountRepository

```dart
abstract interface class AccountRepository {
  /// Non-deleted accounts in sortOrder with derived balance (data-model §3.3).
  Stream<List<AccountWithBalance>> watchAllWithBalances();
  Stream<int> watchTotalBalance();                         // non-archived only

  Stream<List<Account>> watchPickable();                   // non-deleted, non-archived, sortOrder

  Future<Account> create({required String name, required AccountType type,
      required int openingBalanceMinor, required String iconKey, required String colorHex});
  Future<void> update(String id, {required String name, required AccountType type,
      required int openingBalanceMinor, required String iconKey, required String colorHex});

  /// Throws AccountArchiveNotAllowed.lastActive. (Q3)
  Future<void> setArchived(String id, {required bool archived});

  /// Throws AccountDeleteNotAllowed(hasTransactions | lastActive).
  Future<void> delete(String id);
  Future<void> undelete(String id);
}
```

## Receipts

```dart
enum ReceiptSource { camera, gallery }

abstract interface class ReceiptPicker {
  /// Picks, downsizes (longest side ≤ 1280), re-encodes JPEG q80 without EXIF,
  /// stores under receipts/, and returns the RELATIVE path, or null if the
  /// user cancelled. Throws ReceiptFailure on I/O or codec errors. (R8)
  Future<String?> pick(ReceiptSource source);
}

abstract interface class ReceiptStore {
  /// Absolute path for display, or null if the file no longer exists.
  Future<String?> resolve(String relativePath);

  /// Deletes unreferenced files older than 24 h. Returns the count. (R8)
  Future<int> pruneOrphans(Set<String> referencedRelativePaths);
}
```

## Localization port (core)

```dart
// lib/core/l10n/default_name_catalog.dart (pure Dart; imported by expense domain)
/// All translations (en, hi, gu) of a default name key. (R9)
abstract interface class DefaultNameCatalog {
  Set<String> namesFor(String key);
}
```

Implementation: `lib/core/l10n/default_name_catalog_impl.dart` (`lookupAppLocalizations`). Both files
live in core, which features may import and core never imports features. Habit templates can reuse them.

## Sharing port (core)

```dart
// lib/core/share/text_sharer.dart
abstract interface class TextSharer { Future<void> shareText(String text, {String? subject}); }
```

Implementation: `SharePlusTextSharer` (`share_plus`). The fake records calls.

## Clock

```dart
// lib/core/utils/clock.dart
abstract interface class Clock { DateTime now(); }   // SystemClock; FixedClock in tests
```

Used for "now" defaults, Today/Yesterday, the current month, and pruning age. This makes date
behavior testable.

## Errors

| Type | Cases |
| --- | --- |
| `ExpenseStorageFailure` | Any DB failure (screens show the error state or keep the form open, per the spec edge cases) |
| `TransactionNotFound` | Update or restore of a missing or deleted row (spec edge case "Edit an entry deleted elsewhere") |
| `CategoryDeleteNotAllowed` | `isDefault`, `replacementRequired`, `invalidReplacement` |
| `AccountDeleteNotAllowed` | `hasTransactions`, `lastActive` |
| `AccountArchiveNotAllowed` | `lastActive` |
| `ReceiptFailure` | Pick, compress, or write failed |
