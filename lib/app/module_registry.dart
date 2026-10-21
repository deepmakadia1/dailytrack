import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:dailytrack/features/habit/habit_module.dart';

/// The only file that imports concrete modules. Adding a tracker (Water,
/// Period) means one new folder plus one entry here.
/// `production_overrides.dart` overrides `moduleRegistryProvider` with
/// `ModuleRegistry(registeredModules)`.
const List<TrackerModule> registeredModules = [ExpenseModule(), HabitModule()];
