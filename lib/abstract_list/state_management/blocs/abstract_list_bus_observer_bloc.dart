import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractListBusObserverBloc<S extends AbstractListState>
    extends AbstractListBloc<S> {
  StreamSubscription? _eventBusStreamSubscription;

  AbstractListBusObserverBloc(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
