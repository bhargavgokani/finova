import 'package:equatable/equatable.dart';

import 'analytics_state.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}

class ChangeDateRange extends AnalyticsEvent {
  final AnalyticsDateRange dateRange;

  const ChangeDateRange(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}
