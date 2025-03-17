import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// An abstract class that publishes state changes to an event bus from an Item BLoC.
abstract class AbstractItemBusPublisherBloc<S extends AbstractItemState>
    extends AbstractItemBloc<S> {
  /// Subscription to listen for changes in the BLoC's state and publish them to the event bus.
  StreamSubscription? _stateStreamSubscription;

  /// Initializes the BLoC and attaches the state stream to the event bus.
  AbstractItemBusPublisherBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
  }

  /// Cancels the subscription to the state stream when closing the BLoC.
  @override
  Future<void> close() async {
    await _stateStreamSubscription?.cancel();
    super.close();
  }
}
