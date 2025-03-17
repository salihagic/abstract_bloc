import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

abstract class AbstractItemBusPublisherCubit<S extends AbstractItemState>
    extends AbstractItemCubit<S> {
  StreamSubscription? _stateStreamSubscription;

  AbstractItemBusPublisherCubit(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
  }

  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();

    super.close();
  }
}
