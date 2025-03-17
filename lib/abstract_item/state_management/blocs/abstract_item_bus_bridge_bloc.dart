import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

abstract class AbstractItemBusBridgeBloc<S extends AbstractItemState>
    extends AbstractItemBloc<S> {
  StreamSubscription? _stateStreamSubscription;
  StreamSubscription? _eventBusStreamSubscription;

  AbstractItemBusBridgeBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
