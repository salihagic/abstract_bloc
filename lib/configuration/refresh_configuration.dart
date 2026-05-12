import 'package:flutter/widgets.dart';

/// Configuration for the pull-to-refresh indicator used by [AbstractListBuilder].
///
/// When supplied (either on [AbstractConfiguration] for a global default or on
/// [AbstractListBuilder] for a per-list override), the default Material
/// `RefreshIndicator` is replaced by `AbstractRefreshIndicator` and the values
/// here drive its appearance and behaviour.
///
/// New override points (e.g. trigger distance, drag damping, spin duration)
/// should be added here rather than as new top-level fields on
/// [AbstractConfiguration].
class RefreshConfiguration {
  /// Icon rendered by `AbstractRefreshIndicator`. Typically an [Icon] or
  /// [SvgPicture] around 24-32 logical pixels.
  final Widget icon;

  const RefreshConfiguration({required this.icon});
}
