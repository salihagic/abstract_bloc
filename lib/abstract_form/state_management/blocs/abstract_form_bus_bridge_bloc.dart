import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// A bridge between a form BLoC (`AbstractFormBloc`) and an event bus.
/// - Listens to events from an external event bus.
/// - Sends state updates to the event bus.
/// - Useful for integrating forms with global event-driven architectures.
abstract class AbstractFormBusBridgeBloc<S extends AbstractFormState>
    extends AbstractFormBloc<S> {
  /// Subscription to listen for state changes and propagate them to the event bus.
  StreamSubscription? _stateStreamSubscription;

  /// Subscription to listen for external events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor initializes state and connects the BLoC to the event bus.
  AbstractFormBusBridgeBloc(super.initialState) {
    // Attach the BLoC state stream to the event bus.
    _stateStreamSubscription = stream.attachToEventBus();

    // Listen for external events from the event bus.
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Abstract method that child classes must implement to handle observed events.
  void observe(Object event);

  /// Ensures that subscriptions are canceled when the BLoC is closed.
  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to properly clean up the BLoC.
    super.close();
  }
}
