import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class that acts as a bloc observer for listening to events from an event bus.
/// This allows the bloc to react to external events outside its normal flow.
abstract class AbstractListBusObserverBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  // Stream subscription for listening to events coming from the event bus
  StreamSubscription? _eventBusStreamSubscription;

  /// Constructor that initializes the bloc and sets up subscription for the event bus.
  AbstractListBusObserverBloc(super.initialState) {
    // Listen for events on the event bus and call the observe method
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// An abstract method that must be implemented in the subclasses to handle observed events.
  void observe(Object event);

  @override

  /// Override the close method to cancel the event bus subscription when the bloc is closed.
  Future<void> close() async {
    // Cancel the event bus stream subscription if it exists
    _eventBusStreamSubscription?.cancel();

    // Call the superclass close method to handle other cleanup tasks
    super.close();
  }
}
