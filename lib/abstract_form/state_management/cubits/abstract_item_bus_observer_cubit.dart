import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';

/// A base cubit class for observing events from an event bus.
/// This class extends [AbstractItemCubit] and listens to a global event bus.
/// Subclasses must implement the [observe] method to handle incoming events.
abstract class AbstractItemBusObserverCubit<S extends AbstractItemState>
    extends AbstractItemCubit<S> {
  StreamSubscription? _eventBusStreamSubscription;

  /// Creates an [AbstractItemBusObserverCubit].
  /// - [initialState]: The initial state of the cubit.
  /// Automatically subscribes to the event bus and listens for events.
  AbstractItemBusObserverCubit(super.initialState) {
    // Subscribe to the event bus stream and call `observe` when an event is received
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Handles observed events from the event bus.
  /// Must be implemented by subclasses to define specific event handling logic.
  void observe(Object event);

  @override
  Future<void> close() async {
    // Cancel the event bus subscription to avoid memory leaks
    _eventBusStreamSubscription?.cancel();

    // Close the cubit
    super.close();
  }
}
