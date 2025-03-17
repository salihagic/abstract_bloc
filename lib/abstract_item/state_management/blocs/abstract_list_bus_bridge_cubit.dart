import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that bridges a list BLoC with an event bus.
///
/// This class listens for state changes and event bus events.
abstract class AbstractListBusBridgeBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  /// Subscription to listen for changes in the BLoC's state.
  StreamSubscription? _stateStreamSubscription;

  /// Subscription to listen for events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Initializes the BLoC and attaches the state stream and event bus listener.
  AbstractListBusBridgeBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Called when an event is received from the event bus.
  void observe(Object event);

  /// Cancels both state and event bus subscriptions when closing the BLoC.
  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
