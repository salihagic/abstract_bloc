import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemBusObserverBloc<S extends AbstractItemState>
    extends AbstractItemBloc<S> {
  StreamSubscription? _eventBusStreamSubscription;

  AbstractItemBusObserverBloc(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
