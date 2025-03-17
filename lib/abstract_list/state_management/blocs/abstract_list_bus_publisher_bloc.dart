import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc_event_bus/bus/event_but_stream_extensions.dart';

abstract class AbstractListBusPublisherBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  StreamSubscription? _stateStreamSubscription;

  AbstractListBusPublisherBloc(super.initialState) {
    _stateStreamSubscription = stream.attachToEventBus();
  }

  @override
  Future<void> close() async {
    _stateStreamSubscription?.cancel();

    super.close();
  }
}
