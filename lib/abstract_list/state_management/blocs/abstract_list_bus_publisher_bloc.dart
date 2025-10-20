import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that enables publishing state changes to an event bus.
/// This allows other parts of the application to react to state changes in this bloc.
abstract class AbstractListBusPublisherBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  // Stream subscription that connects the bloc's state changes to the event bus
  StreamSubscription? _stateStreamSubscription;

  /// Constructor that initializes the bloc and attaches the state stream to the event bus.
  AbstractListBusPublisherBloc(super.initialState) {
    // Attach the bloc's state stream to the event bus
    _stateStreamSubscription = stream.attachToEventBus();
  }

  @override
  /// Override the close method to cancel the state stream subscription when the bloc is closed.
  Future<void> close() async {
    // Cancel the subscription to avoid memory leaks
    _stateStreamSubscription?.cancel();

    // Call the superclass close method to perform additional cleanup
    super.close();
  }
}
