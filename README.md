# abstract_bloc

A powerful Flutter package that provides abstract base classes for implementing the BLoC pattern with built-in support for **lists with pagination**, **single items**, and **forms with validation**. It eliminates boilerplate code and standardizes state management for common use cases like fetching data from APIs with cache-first strategies.

[![pub package](https://img.shields.io/pub/v/abstract_bloc.svg)](https://pub.dev/packages/abstract_bloc)

## Features

- **AbstractList** - Paginated lists with load, refresh, and load-more functionality
- **AbstractItem** - Single item loading with cache support
- **AbstractForm** - Form handling with validation and offline fallback
- **Cache-First Strategy** - Seamless cache + network data flow
- **Built-in Widgets** - Ready-to-use UI components for all states (loading, error, empty, cached)
- **Snapshot/Revert** - Filter dialog pattern with undo support
- **Event Bus Integration** - Cross-component communication

<p style="display: flex; justify-content: space-between; width: 100vw;">
  <img src="https://user-images.githubusercontent.com/24563963/167363480-af2e712d-ec7f-46c1-b6f0-51be23d3e8db.gif" width="250" height="500"/>
  <img src="https://user-images.githubusercontent.com/24563963/167363508-cf5e2430-de2c-4aef-ab90-0bafef0c21b4.gif" width="250" height="500"/>
  <img src="https://user-images.githubusercontent.com/24563963/167363517-782b9639-0541-4503-bbcf-30164e2a009c.gif" width="250" height="500"/>
</p>

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  abstract_bloc: ^2.2.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Define Your Model

```dart
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name']);
  }
}
```

### 2. Create a Search Model (for filtering/pagination)

```dart
class UsersSearchModel extends Pagination {
  final String? nameFilter;

  UsersSearchModel({this.nameFilter});

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    if (nameFilter != null) 'name': nameFilter,
  };
}
```

### 3. Create the State

```dart
class UsersState extends AbstractListFilterablePaginatedState<UsersSearchModel, User> {
  UsersState({
    required super.resultStatus,
    required super.searchModel,
    required super.result,
  });

  @override
  UsersState copyWith({
    ResultStatus? resultStatus,
    UsersSearchModel? searchModel,
    GridResult<User>? result,
  }) => UsersState(
    resultStatus: resultStatus ?? this.resultStatus,
    searchModel: searchModel ?? this.searchModel,
    result: result ?? this.result,
  );
}
```

### 4. Create the Cubit/Bloc

```dart
// Using Cubit (simpler)
class UsersCubit extends AbstractListCubit<UsersState> {
  final UsersRepository _repository;

  UsersCubit(this._repository) : super(_initialState());

  static UsersState _initialState() => UsersState(
    resultStatus: ResultStatus.loading,
    searchModel: UsersSearchModel(),
    result: GridResult<User>(),
  );

  @override
  UsersState initialState() => _initialState();

  @override
  Future<Result<GridResult<User>>> resolveData() {
    return _repository.getUsers(state.searchModel);
  }

  // Optional: Add cache fallback
  @override
  Stream<Result<GridResult<User>>> resolveStreamData() {
    return _repository.getUsersStreamed(state.searchModel);
  }
}

// Using Bloc (event-driven)
class UsersBloc extends AbstractListBloc<UsersState> {
  final UsersRepository _repository;

  UsersBloc(this._repository) : super(_initialState());

  // ... same implementation
}
```

### 5. Use in Your Widget

```dart
class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AbstractListBuilder<UsersCubit, UsersState>(
      // Built-in provider - no need for separate BlocProvider
      provider: (context) => UsersCubit(context.read<UsersRepository>()),
      // onInit is optional - defaults to calling load() automatically
      itemBuilder: (context, state, index) => ListTile(
        title: Text(state.items[index].name),
      ),
    );
  }
}
```

That's it! You get pull-to-refresh, pagination, loading states, error handling, and cached data indicators out of the box.

## Core Concepts

### State Classes

| State Class | Use Case |
|-------------|----------|
| `AbstractListState<T>` | Simple list without filtering |
| `AbstractListFilterableState<S, T>` | List with search/filter model |
| `AbstractListFilterablePaginatedState<S, T>` | List with filtering and pagination |
| `AbstractItemState<T>` | Single item loading |
| `AbstractItemFilterableState<S, T>` | Single item with search model |
| `AbstractFormBaseState` | Form with status only |
| `AbstractFormBasicState<T>` | Form with model |
| `AbstractFormState<T, V>` | Form with model and validator |

### Result Status

```dart
enum ResultStatus {
  loading,      // Data is being fetched
  loaded,       // Data loaded from network
  loadedCached, // Data loaded from cache
  error,        // Error occurred
}
```

### GridResult

Container for paginated list results:

```dart
GridResult<User>(
  items: users,
  hasMoreItems: true,
  currentPage: 1,
  pageCount: 10,
)
```

## AbstractList - Paginated Lists

### Basic Usage

```dart
class ProductsCubit extends AbstractListCubit<ProductsState> {
  final ProductsRepository _repository;

  ProductsCubit(this._repository) : super(ProductsState.initial());

  @override
  ProductsState initialState() => ProductsState.initial();

  @override
  Future<Result<GridResult<Product>>> resolveData() {
    return _repository.getProducts(state.searchModel);
  }
}
```

### Available Methods

| Method | Description |
|--------|-------------|
| `load()` | Load/reload data (replaces existing items) |
| `refresh()` | Refresh data (typically from pull-to-refresh) |
| `loadMore()` | Load next page (appends to existing items) |
| `update(searchModel)` | Update search/filter parameters |
| `snapshot()` | Save current state (for filter dialogs) |
| `revert()` | Restore to snapshot state |
| `reset()` | Reset to initial state |

### Cache-First Strategy

Implement `resolveStreamData()` to enable cache-first loading:

```dart
@override
Stream<Result<GridResult<User>>> resolveStreamData() {
  // First emits cached data, then network data
  return _repository.getUsersStreamed(state.searchModel);
}
```

The widget will show cached data immediately while loading fresh data from the network.

### Filter Dialog Pattern

```dart
// When opening filter dialog
cubit.snapshot(); // Save current state

// User modifies filters
cubit.update(newSearchModel);

// User confirms
cubit.load(); // Apply filters

// User cancels
cubit.revert(); // Restore previous state
```

### AbstractListBuilder Widget

```dart
AbstractListBuilder<UsersCubit, UsersState>(
  // Built-in provider options (choose one)
  provider: (context) => UsersCubit(repository),  // Creates new instance
  providerValue: existingCubit,                   // Use existing instance

  // Required
  itemBuilder: (context, state, index) => UserCard(user: state.items[index]),

  // Optional - defaults to calling load() automatically
  onInit: (context) => context.read<UsersCubit>().load(),

  // Optional customization
  columns: 2,                          // Grid columns (1 = ListView)
  height: 200,                         // Fixed item height for grid
  padding: EdgeInsets.all(16),
  separatorBuilder: (context, index) => Divider(),

  // Headers and footers
  header: SearchBar(),
  footer: LoadMoreButton(),
  fixedHeader: true,                   // Keep header visible while scrolling
  fixedFooter: false,

  // State builders
  loaderBuilder: (context) => CustomLoader(),
  errorBuilder: (context, onRetry) => ErrorWidget(onRetry: onRetry),
  noDataBuilder: (context, onRetry) => EmptyState(onRetry: onRetry),

  // Callbacks
  onRefresh: (context) => context.read<UsersCubit>().refresh(),
  onLoadMore: (context) => context.read<UsersCubit>().loadMore(),
)
```

## AbstractItem - Single Items

For loading individual items (e.g., detail pages):

```dart
class UserDetailsState extends AbstractItemFilterableState<UserDetailsSearchModel, UserDetails> {
  UserDetailsState({
    required super.resultStatus,
    required super.searchModel,
    super.item,
  });

  @override
  UserDetailsState copyWith({
    ResultStatus? resultStatus,
    UserDetailsSearchModel? searchModel,
    UserDetails? item,
  }) => UserDetailsState(
    resultStatus: resultStatus ?? this.resultStatus,
    searchModel: searchModel ?? this.searchModel,
    item: item ?? this.item,
  );
}

class UserDetailsCubit extends AbstractItemCubit<UserDetailsState> {
  final UsersRepository _repository;

  UserDetailsCubit(this._repository) : super(UserDetailsState.initial());

  @override
  Future<Result<UserDetails>> resolveData() {
    return _repository.getUserDetails(state.searchModel.id);
  }
}
```

### AbstractItemBuilder Widget

```dart
AbstractItemBuilder<UserDetailsCubit, UserDetailsState>(
  // Built-in provider - no need for separate BlocProvider
  provider: (context) => UserDetailsCubit(context.read<UsersRepository>()),
  onInit: (context) => context.read<UserDetailsCubit>().load(
    UserDetailsSearchModel(id: userId),
  ),
  builder: (context, state) => Column(
    children: [
      Text(state.item?.name ?? ''),
      Text(state.item?.email ?? ''),
    ],
  ),
)
```

## AbstractForm - Forms with Validation

### Define a Validator

```dart
class UserFormValidator extends ModelValidator {
  @override
  bool validate(dynamic model) {
    if (model is! UserFormModel) return false;
    return model.name.isNotEmpty &&
           model.email.contains('@') &&
           model.age >= 18;
  }

  @override
  Map<String, String> messages(dynamic model) {
    final errors = <String, String>{};
    if (model is! UserFormModel) return errors;

    if (model.name.isEmpty) errors['name'] = 'Name is required';
    if (!model.email.contains('@')) errors['email'] = 'Invalid email';
    if (model.age < 18) errors['age'] = 'Must be 18 or older';

    return errors;
  }
}
```

### Create Form State and Cubit

```dart
class UserFormState extends AbstractFormState<UserFormModel, UserFormValidator> {
  UserFormState({
    required super.formResultStatus,
    super.model,
    super.modelValidator,
    super.autovalidate,
  });

  factory UserFormState.initial() => UserFormState(
    formResultStatus: FormResultStatus.initializing,
    modelValidator: UserFormValidator(),
  );

  @override
  UserFormState copyWith({
    FormResultStatus? formResultStatus,
    UserFormModel? model,
    UserFormValidator? modelValidator,
    bool? autovalidate,
  }) => UserFormState(
    formResultStatus: formResultStatus ?? this.formResultStatus,
    model: model ?? this.model,
    modelValidator: modelValidator ?? this.modelValidator,
    autovalidate: autovalidate ?? this.autovalidate,
  );
}

class UserFormCubit extends AbstractFormCubit<UserFormState> {
  final UsersRepository _repository;

  UserFormCubit(this._repository) : super(UserFormState.initial());

  @override
  Future<Result> initModelEmpty() async {
    return Result.success(data: UserFormModel.empty());
  }

  @override
  Future<Result> initModel(dynamic model) async {
    // Load existing user for editing
    return _repository.getUser(model as int);
  }

  @override
  Future<Result> onSubmit(dynamic model) async {
    return _repository.saveUser(model as UserFormModel);
  }

  // Optional: Offline fallback
  @override
  Future<Result> onSubmitLocal(dynamic model) async {
    return _localStorage.saveUserForSync(model as UserFormModel);
  }
}
```

### Form Result Status

```dart
enum FormResultStatus {
  initializing,           // Loading form data
  initialized,            // Ready for input
  submitting,             // Submitting to server
  submittingSuccess,      // Submission successful
  submittingLocalSuccess, // Saved locally (offline)
  error,                  // Initialization error
  submittingError,        // Submission error
  submittingLocalError,   // Local save error
  validationError,        // Validation failed
}
```

### AbstractFormBuilder Widget

```dart
AbstractFormBuilder<UserFormCubit, UserFormState>(
  onInit: (context) => context.read<UserFormCubit>().init(), // or .init(userId) for edit

  builder: (context, state) => Form(
    autovalidateMode: state.autovalidateMode,
    child: Column(
      children: [
        TextFormField(
          initialValue: state.model?.name,
          onChanged: (value) => context.read<UserFormCubit>().update(
            state.model?.copyWith(name: value),
          ),
          validator: (value) => state.modelValidator?.messages(state.model)['name'],
        ),
        // ... more fields
        ElevatedButton(
          onPressed: state.isSubmitting ? null : () {
            context.read<UserFormCubit>().submit();
          },
          child: state.isSubmitting
            ? CircularProgressIndicator()
            : Text('Save'),
        ),
      ],
    ),
  ),

  onSubmitSuccess: (context) => Navigator.of(context).pop(),
  onSubmitError: (context) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error saving')),
  ),
)
```

## Global Configuration

Configure default widgets and pagination globally:

```dart
MaterialApp(
  builder: (context, child) {
    return AbstractConfiguration(
      // Custom loading indicator
      loaderBuilder: (context) => Center(
        child: CircularProgressIndicator(),
      ),

      // Custom error widget for lists
      abstractListErrorBuilder: (context, onRetry) => Center(
        child: Column(
          children: [
            Text('An error occurred'),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ),
      ),

      // Custom empty state for lists
      abstractListNoDataBuilder: (context, onRetry) => Center(
        child: Text('No items found'),
      ),

      // Same for items
      abstractItemErrorBuilder: (context, onRetry) => ...,
      abstractItemNoDataBuilder: (context, onRetry) => ...,

      // Cached data indicator
      cachedDataWarningIconBuilder: (context, onTap) => IconButton(
        icon: Icon(Icons.cloud_off),
        onPressed: onTap,
      ),

      // Pagination configuration
      paginationConfiguration: PaginationConfiguration(
        initialPage: 1,
        pageSize: 20,
        toJson: (pagination) => {
          'page': pagination.page,
          'limit': pagination.take,
        },
      ),

      child: child!,
    );
  },
  home: HomePage(),
)
```

## Pagination

### Offset-based Pagination

```dart
class MySearchModel extends Pagination {
  final String? query;

  MySearchModel({this.query});

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(), // Includes page, skip, take
    if (query != null) 'q': query,
  };
}
```

### Cursor-based Pagination

```dart
class MySearchModel extends CursorPagination {
  final String? filter;

  MySearchModel({this.filter});

  @override
  Map<String, dynamic> toJson() => {
    'cursor': cursor,
    if (filter != null) 'filter': filter,
  };
}
```

## Event Bus Integration

For cross-component communication:

```dart
// Publisher - emits state changes to the bus
class UsersCubit extends AbstractListBusPublisherCubit<UsersState> { ... }

// Observer - reacts to events from the bus
class UserCountCubit extends AbstractListBusObserverCubit<UserCountState> { ... }

// Bridge - both publishes and observes
class UsersSyncCubit extends AbstractListBusBridgeCubit<UsersSyncState> { ... }
```

## Lifecycle Hooks

Override these methods for custom behavior:

```dart
class UsersCubit extends AbstractListCubit<UsersState> {
  @override
  void onBeforeLoad() {
    // Called before loading starts
    analytics.trackListLoading();
  }

  @override
  void onAfterLoad() {
    // Called after loading completes
    analytics.trackListLoaded(state.items.length);
  }

  @override
  void onBeforeRefresh() { ... }

  @override
  void onAfterRefresh() { ... }

  @override
  void onBeforeLoadMore() { ... }

  @override
  void onAfterLoadMore() { ... }
}
```

## Dependencies

This package builds on:
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - BLoC pattern implementation
- [rest_api_client](https://pub.dev/packages/rest_api_client) - REST API utilities with caching
- [provider](https://pub.dev/packages/provider) - Dependency injection

## Example

See the [example project](https://github.com/salihagic/abstract_bloc/tree/main/example) for a complete implementation with:
- User list with pagination
- User details page
- Cache-first data loading
- Global configuration

## License

MIT License - see [LICENSE](LICENSE) for details.
