import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemEvent extends Object {}

class AbstractItemLoadEvent<TSearchModel extends Pagination>
    extends AbstractItemEvent {
  TSearchModel? searchModel;

  AbstractItemLoadEvent({this.searchModel});
}
