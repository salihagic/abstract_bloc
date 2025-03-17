import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractListBusObserverCubit<S extends AbstractListState>
    extends AbstractListCubit<S> {
  StreamSubscription? _eventBusStreamSubscription;

  AbstractListBusObserverCubit(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
