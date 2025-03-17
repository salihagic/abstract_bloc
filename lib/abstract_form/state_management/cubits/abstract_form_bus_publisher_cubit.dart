import 'dart:async';
import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

/// A base cubit class for publishing state changes to an event bus.
/// This class extends [AbstractFormCubit] and automatically publishes
/// its state changes to a global event bus using [attachToEventBus].
abstract class AbstractFormBusPublisherCubit<S extends AbstractFormBaseState>
    extends AbstractFormCubit<S> {
  StreamSubscription? _stateStreamSubscription;

  /// Creates an [AbstractFormBusPublisherCubit].
  /// - [initialState]: The initial state of the cubit.
  /// - [modelValidator]: An optional validator for the model (can be null).
  /// Automatically attaches the cubit's state stream to the event bus.
  AbstractFormBusPublisherCubit(super.initialState, [super.modelValidator]) {
    // Attach the cubit's state stream to the event bus
    _stateStreamSubscription = stream.attachToEventBus();
  }

  @override
  Future<void> close() async {
    // Cancel the state stream subscription to avoid memory leaks
    _stateStreamSubscription?.cancel();

    // Close the cubit
    super.close();
  }
}
