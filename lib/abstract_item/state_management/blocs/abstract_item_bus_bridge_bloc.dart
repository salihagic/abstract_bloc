import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that serves as a bridge between an event bus and the Item BLoC.
abstract class AbstractItemBusBridgeBloc<S extends AbstractItemState>
    extends AbstractItemBloc<S> {
  /// Subscription for state stream connected to the event bus.
  StreamSubscription? _stateStreamSubscription;

  /// Subscription for the event bus stream.
  StreamSubscription? _eventBusStreamSubscription;

  /// Initializes the BLoC and sets up subscriptions to the event bus and state stream.
  AbstractItemBusBridgeBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Reacts to events from the event bus.
  /// Implement this method in subclasses to define specific behaviors.
  void observe(Object event);

  /// Cancels the subscriptions when closing the BLoC.
  @override
  Future<void> close() async {
    await _stateStreamSubscription?.cancel();
    await _eventBusStreamSubscription?.cancel();
    super.close();
  }
}
