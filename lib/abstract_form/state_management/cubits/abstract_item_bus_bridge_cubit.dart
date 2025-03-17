import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// A base cubit class that bridges state changes and events between a cubit and an event bus.
/// This class extends [AbstractItemCubit] and listens to both state changes and events from an event bus.
abstract class AbstractItemBusBridgeCubit<S extends AbstractItemState>
    extends AbstractItemCubit<S> {
  StreamSubscription? _stateStreamSubscription;
  StreamSubscription? _eventBusStreamSubscription;

  /// Creates an [AbstractItemBusBridgeCubit].
  /// - [initialState]: The initial state of the cubit.
  /// Automatically attaches the cubit's state stream to the event bus and listens for events.
  AbstractItemBusBridgeCubit(super.initialState) {
    // Attach the cubit's state stream to the event bus
    _stateStreamSubscription = stream.attachToEventBus();
    // Listen to the event bus for incoming events
    _eventBusStreamSubscription = eventBus.stream.listen(onEvent);
  }

  /// Handles incoming events from the event bus.
  /// Must be implemented by subclasses to define specific event handling logic.
  void onEvent(Object event);

  @override
  Future<void> close() async {
    // Cancel the state stream subscription to avoid memory leaks
    _stateStreamSubscription?.cancel();
    // Cancel the event bus subscription to avoid memory leaks
    _eventBusStreamSubscription?.cancel();

    // Close the cubit
    super.close();
  }
}
