import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

/// A BLoC that observes events from an event bus and processes them.
/// - Extends `AbstractFormBloc` to handle form-related logic.
/// - Listens to global events and reacts accordingly.
/// - Useful for syncing form state with external events.
abstract class AbstractFormBusObserverBloc<S extends AbstractFormState>
    extends AbstractFormBloc<S> {
  /// Subscription to listen for external events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor initializes the state and starts listening to the event bus.
  AbstractFormBusObserverBloc(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Abstract method that subclasses must implement to handle observed events.
  void observe(Object event);

  /// Ensures that the event bus subscription is properly cleaned up when the BLoC is closed.
  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to handle additional cleanup.
    super.close();
  }
}
