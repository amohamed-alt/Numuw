import '../models/child_profile.dart';
import '../models/weekly_child_summary.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/growth_repository.dart';

class WeeklySummaryService {
  WeeklySummaryService({
    CareEventRepository? careEventRepository,
    GrowthRepository? growthRepository,
    WeeklySummaryCalculator? calculator,
  }) : _careEventRepository = careEventRepository ?? CareEventRepository(),
       _growthRepository = growthRepository ?? GrowthRepository(),
       _calculator = calculator ?? const WeeklySummaryCalculator();

  final CareEventRepository _careEventRepository;
  final GrowthRepository _growthRepository;
  final WeeklySummaryCalculator _calculator;

  Future<WeeklyChildSummary> buildForChild(
    ChildProfile child, {
    DateTime? now,
  }) async {
    final end = (now ?? DateTime.now()).toLocal();
    final start = end.subtract(const Duration(days: 14));
    final events = await _careEventRepository.fetchBetween(
      child.id,
      start,
      end,
    );
    final growthMeasurements = await _growthRepository.fetch(child.id);
    return _calculator.calculate(
      childId: child.id,
      childName: child.name,
      now: end,
      events: events,
      growthMeasurements: growthMeasurements,
    );
  }
}
