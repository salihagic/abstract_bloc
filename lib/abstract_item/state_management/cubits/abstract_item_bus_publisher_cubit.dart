import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that publishes state changes to an event bus in the context of an item Cubit.
///
/// This class automatically attaches the Cubit's state stream to the event bus, allowing
/// external components to listen for state updates.
abstract class AbstractItemBusPublisherCubit<S extends AbstractItemState>
    extends AbstractItemCubit<S> {
  /// Subscription to listen for state changes from the Cubit.
  StreamSubscription? _stateStreamSubscription;

  /// Initializes the Cubit with state publishing to the event bus.
  AbstractItemBusPublisherCubit(super.initialState) {
    // Attach the stream to the event bus for publishing state changes
    _stateStreamSubscription = stream.attachToEventBus();
  }

  /// Cancels the state stream subscription when closing the Cubit.
  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();

    super.close();
  }
}
