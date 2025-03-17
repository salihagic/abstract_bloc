import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// A BLoC that publishes its state updates to an event bus.
/// - Extends `AbstractFormBloc` to handle form-related logic.
/// - Attaches the state stream to the event bus for global access.
abstract class AbstractFormBusPublisherBloc<S extends AbstractFormState>
    extends AbstractFormBloc<S> {
  /// Subscription to propagate state changes to the event bus.
  StreamSubscription? _stateStreamSubscription;

  /// Constructor initializes the state and attaches the state stream to the event bus.
  AbstractFormBusPublisherBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
  }

  /// Ensures that the event bus subscription is properly cleaned up when the BLoC is closed.
  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();

    // Call the superclass close method to handle additional cleanup.
    super.close();
  }
}
