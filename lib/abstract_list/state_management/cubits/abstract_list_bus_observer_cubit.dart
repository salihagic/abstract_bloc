import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class that allows a cubit to observe events from an event bus.
/// Subclasses must implement logic to handle these events.
abstract class AbstractListBusObserverCubit<S extends AbstractListState>
    extends AbstractListCubit<S> {
  // Stream subscription for listening to events on the event bus
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor that initializes the cubit and sets up the event bus subscription.
  AbstractListBusObserverCubit(super.initialState) {
    // Listen for events on the event bus and delegate to the observe method
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// An abstract method that must be implemented to handle incoming events.
  void observe(Object event);

  @override
  /// Override the close method to cancel the event bus subscription when the cubit is closed.
  Future<void> close() async {
    // Cancel the event bus stream subscription to prevent memory leaks
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to perform any additional cleanup needed
    super.close();
  }
}
