import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that acts as a bridge for integrating the cubit with an event bus.
/// It allows the cubit to publish its state and also to listen for events from the event bus.
abstract class AbstractListBusBridgeCubit<S extends AbstractListState>
    extends AbstractListCubit<S> {
  // Stream subscriptions for managing event bus interactions
  StreamSubscription?
  _stateStreamSubscription; // Publishes state changes to event bus
  StreamSubscription?
  _eventBusStreamSubscription; // Listens for events from the event bus

  /// Constructor that initializes the cubit and sets up subscriptions.
  AbstractListBusBridgeCubit(super.initialState) {
    // Attach the cubit's state stream to the event bus for broadcasting state changes
    _stateStreamSubscription = stream.attachToEventBus();
    // Listen for events on the event bus and delegate handling to the observe method
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// An abstract method that needs to be implemented to handle events from the event bus.
  void observe(Object event);

  @override
  /// Override the close method to cancel both subscriptions when the cubit is closed.
  Future<void> close() async {
    // Cancel the state stream subscription to prevent memory leaks
    _stateStreamSubscription?.cancel();
    // Cancel the event bus stream subscription to prevent memory leaks
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to perform any additional cleanup
    super.close();
  }
}
