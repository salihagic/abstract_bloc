import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class that observes events from an event bus and interacts with an Item BLoC.
abstract class AbstractItemBusObserverBloc<S extends AbstractItemState>
    extends AbstractItemBloc<S> {
  /// Subscription to listen for events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Initializes the BLoC and sets up the event bus subscription.
  AbstractItemBusObserverBloc(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Observes events from the event bus.
  /// Implement this method in subclasses to handle specific events.
  void observe(Object event);

  /// Cancels the event bus subscription when closing the BLoC.
  @override
  Future<void> close() async {
    await _eventBusStreamSubscription?.cancel();
    super.close();
  }
}
