import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormBusObserverBloc<S extends AbstractFormState>
    extends AbstractFormBloc<S> {
  StreamSubscription? _eventBusStreamSubscription;

  AbstractFormBusObserverBloc(super.initialState) {
    _eventBusStreamSubscription = eventBus.stream.listen(observe);
  }

  void observe(Object event);

  @override
  Future<void> close() async {
    _eventBusStreamSubscription?.cancel();

    super.close();
  }
}
