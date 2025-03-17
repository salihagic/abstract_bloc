import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// A BLoC that bridges an item state with an event bus.
/// - Extends `AbstractItemBloc` to manage item-related state.
/// - Listens to external events from the event bus.
/// - Publishes state changes to the event bus.
abstract class AbstractItemBusBridgeBloc<S extends AbstractItemState>
    extends AbstractItemBloc<S> {
  /// Subscription to propagate state changes to the event bus.
  StreamSubscription? _stateStreamSubscription;

  /// Subscription to listen for external events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor initializes the state and sets up event bus connections.
  AbstractItemBusBridgeBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Abstract method that subclasses must implement to handle observed events.
  void observe(Object event);

  /// Ensures that event bus subscriptions are properly cleaned up when the BLoC is closed.
  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to handle additional cleanup.
    super.close();
  }
}
