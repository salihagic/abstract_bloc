import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class that observes events from an event bus in the context of an item Cubit.
///
/// This class listens for events from the event bus and allows subclasses to define specific
/// behavior for handling those events.
abstract class AbstractItemBusObserverCubit<S extends AbstractItemState>
    extends AbstractItemCubit<S> {
  /// Subscription to listen for events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Initializes the Cubit and sets up the event bus listener.
  AbstractItemBusObserverCubit(super.initialState) {
    // Start listening to the event bus and call observe when an event is received
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Method to handle events received from the event bus.
  ///
  /// Subclasses must implement this method to define their specific behavior
  /// when an event is observed.
  void observe(Object event);

  /// Cancels the event bus subscription when closing the Cubit.
  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
