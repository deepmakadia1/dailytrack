import 'package:dailytrack/features/habit/domain/entities/habit_template.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';

/// Starter habits on the empty HAB-01 (research R16, FR-022), all daily.
/// Names and units are ARB keys; icon keys come from the shared icon set
/// and colors from the shared 16-color palette (`AppColors.palette`).
const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    id: 'drinkWater',
    nameKey: 'habit_template_drinkWater',
    iconKey: 'water_drop',
    colorHex: '#2B7ACA',
    kind: HabitKind.count,
    target: 8,
    unitKey: 'habit_unit_glasses',
  ),
  HabitTemplate(
    id: 'read',
    nameKey: 'habit_template_read',
    iconKey: 'menu_book',
    colorHex: '#AD6925',
    kind: HabitKind.count,
    target: 20,
    unitKey: 'habit_unit_pages',
  ),
  HabitTemplate(
    id: 'walk',
    nameKey: 'habit_template_walk',
    iconKey: 'directions_walk',
    colorHex: '#1D8B39',
    kind: HabitKind.count,
    target: 30,
    unitKey: 'habit_unit_minutes',
  ),
  HabitTemplate(
    id: 'meditate',
    nameKey: 'habit_template_meditate',
    iconKey: 'self_improvement',
    colorHex: '#7B68DF',
    kind: HabitKind.count,
    target: 10,
    unitKey: 'habit_unit_minutes',
  ),
  HabitTemplate(
    id: 'wakeUpEarly',
    nameKey: 'habit_template_wakeUpEarly',
    iconKey: 'alarm',
    colorHex: '#CA532B',
    kind: HabitKind.yesNo,
    target: 1,
  ),
  HabitTemplate(
    id: 'study',
    nameKey: 'habit_template_study',
    iconKey: 'school',
    colorHex: '#4E71DA',
    kind: HabitKind.count,
    target: 60,
    unitKey: 'habit_unit_minutes',
  ),
];

/// The template with [id], or null.
HabitTemplate? habitTemplateById(String? id) {
  for (final t in habitTemplates) {
    if (t.id == id) return t;
  }
  return null;
}
