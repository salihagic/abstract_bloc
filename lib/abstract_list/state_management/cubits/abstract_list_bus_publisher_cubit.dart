import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that enables a cubit to publish its state to an event bus.
/// This allows other components to react to state changes outside the cubit.
abstract class AbstractListBusPublisherCubit<S extends AbstractListState>
    extends AbstractListCubit<S> {
  // Subscription to manage the state stream on the event bus
  StreamSubscription? _stateStreamSubscription;

  /// Constructor that initializes the cubit and sets up the state stream publishing.
  AbstractListBusPublisherCubit(super.initialState) {
    // Attach the cubit's state stream to the event bus for broadcasting state changes
    _stateStreamSubscription = stream.attachToEventBus();
  }

  @override
  /// Override the close method to cancel the state stream subscription when the cubit is closed.
  Future<void> close() async {
    // Cancel the state stream subscription to prevent memory leaks
    _stateStreamSubscription?.cancel();

    // Call the superclass close method to perform any additional cleanup needed
    super.close();
  }
}
