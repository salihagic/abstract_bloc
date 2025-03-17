import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// A Cubit that bridges form state with an event bus.
/// - Extends `AbstractFormCubit` for managing form state.
/// - Listens to external events from the event bus.
/// - Publishes state changes to the event bus.
abstract class AbstractFormBusBridgeCubit<S extends AbstractFormBaseState>
    extends AbstractFormCubit<S> {
  /// Subscription to propagate state changes to the event bus.
  StreamSubscription? _stateStreamSubscription;

  /// Subscription to listen for external events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor initializes the state, sets up event bus connections, and assigns a model validator.
  AbstractFormBusBridgeCubit(super.initialState, [super.modelValidator]) {
    _stateStreamSubscription = stream.attachToEventBus();
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Abstract method that subclasses must implement to handle observed events.
  void observe(Object event);

  /// Ensures that event bus subscriptions are properly cleaned up when the Cubit is closed.
  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to handle additional cleanup.
    super.close();
  }
}
