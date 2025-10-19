import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Extension methods for the [RefreshController] class.
extension RefreshControllerExtension on RefreshController {
  /// Completes the current loading or refreshing action.
  ///
  /// If the controller is currently loading, it calls [loadComplete] to
  /// indicate that loading has finished.
  /// If the controller is currently refreshing, it calls [refreshCompleted]
  /// to indicate that the refresh has finished.
  void complete() {
    if (isLoading) {
      footerMode!.value = LoadStatus.idle;
      loadComplete(); // Call to mark loading as complete
    } else if (isRefresh) {
      refreshCompleted(); // Call to mark refreshing as complete
    }
  }
}
