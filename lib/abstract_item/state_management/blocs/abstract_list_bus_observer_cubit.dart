import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class that allows observing events from an event bus.
///
/// This class extends the basic list BLoC to include event bus observation functionality.
abstract class AbstractListBusObserverBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  /// Subscription to listen for events from the event bus.
  StreamSubscription? _eventBusStreamSubscription;

  /// Initializes the BLoC and sets up the event bus listener.
  AbstractListBusObserverBloc(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  /// Called when an event is received from the event bus.
  void observe(Object event);

  /// Cancels the event bus subscription when closing the BLoC.
  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
