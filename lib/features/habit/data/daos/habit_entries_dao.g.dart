// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_entries_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitEntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $HabitEntriesTable get habitEntries => attachedDatabase.habitEntries;
  HabitEntriesDaoManager get managers => HabitEntriesDaoManager(this);
}

class HabitEntriesDaoManager {
  final _$HabitEntriesDaoMixin _db;
  HabitEntriesDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$HabitEntriesTableTableManager get habitEntries =>
      $$HabitEntriesTableTableManager(_db.attachedDatabase, _db.habitEntries);
}
