import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that bridges the list bloc with an event bus.
/// It listens to events on the event bus and allows for state changes based on those events.
abstract class AbstractListBusBridgeBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  // Stream subscription for listening to state changes
  StreamSubscription? _stateStreamSubscription;

  // Stream subscription for listening to event bus events
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor that initializes the bloc and sets up subscriptions for the event bus.
  AbstractListBusBridgeBloc(super.initialState) {
    // Attach the bloc's state stream to the event bus
    _stateStreamSubscription = stream.attachToEventBus();

    // Listen to events from the event bus and trigger the observe method
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// A method that must be implemented by subclasses to define how to handle events from the event bus.
  void observe(Object event);

  @override

  /// Override the close method to cancel the event bus subscriptions when the bloc is closed.
  Future<void> close() async {
    // Cancel state stream subscription if it exists
    _stateStreamSubscription?.cancel();

    // Cancel event bus subscription if it exists
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close to handle other cleanup tasks
    super.close();
  }
}
