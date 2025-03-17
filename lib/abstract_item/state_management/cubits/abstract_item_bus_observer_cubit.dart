import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemBusObserverCubit<S extends AbstractItemState>
    extends AbstractItemCubit<S> {
  StreamSubscription? _eventBusStreamSubscription;

  AbstractItemBusObserverCubit(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
