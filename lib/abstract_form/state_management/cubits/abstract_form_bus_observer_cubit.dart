import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormBusObserverCubit<S extends AbstractFormBaseState>
    extends AbstractFormCubit<S> {
  StreamSubscription? _eventBusStreamSubscription;

  AbstractFormBusObserverCubit(super.initialState, [super.modelValidator]) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
