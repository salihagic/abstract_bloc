# abstract_bloc

`abstract_bloc` is a Flutter package that provides a set of abstract base classes to implement the BLoC (Business Logic Component) pattern. It allows for a structured approach to state management, simplifies the creation of reusable components, and promotes maintainable code practices.

## 📌 Why Use abstract_bloc?

- ✅ **Abstract Base Classes** – Standardizes the implementation of Cubits and Blocs, encouraging best practices.
- ✅ **Flexible Components** – Easily create flexible and reusable components for managing application state.
- ✅ **Decoupled State Management** – Clearly separate presentation logic from business logic for better maintainability.
- ✅ **Rich Functionality** – Streamlines handling of common use cases, such as lists and forms.

## 🚀 Getting Started

### 1️⃣ Install the Package

Add the package to your `pubspec.yaml`:

dependencies:
  abstract_bloc: latest_version

Run:
```sh
flutter pub get
```
# Features
- Load, Refresh and Load more data from cache + network with seamless flow
- Show error widget when network error occures and allow the user to reload the data
- Show info icon telling the user that cached data is being shown and allow them to reload the data

Please refer to the [example project](https://github.com/salihagic/abstract_bloc/tree/main/example/lib) for more detailed insight into the usage of AbstractBloc

<p style="display: flex; justify-content: space-between; width: 100vw;">
  <img src="https://user-images.githubusercontent.com/24563963/167363480-af2e712d-ec7f-46c1-b6f0-51be23d3e8db.gif" width="250" height="500"/>
  <img src="https://user-images.githubusercontent.com/24563963/167363508-cf5e2430-de2c-4aef-ab90-0bafef0c21b4.gif" width="250" height="500"/>
  <img src="https://user-images.githubusercontent.com/24563963/167363517-782b9639-0541-4503-bbcf-30164e2a009c.gif" width="250" height="500"/>
</p>

## 🛠️ Advanced Use Cases

- **Nested BLoCs**: Create nested BLoCs or Cubits to manage complex states in larger applications.
- **Reactive Forms**: Enhance form handling with reactive state management, leveraging the `AbstractFormCubit`.
- **Global State Management**: Implement a globally accessible state using a combination of Cubits and Blocs.

## 🏆 Conclusion

The `abstract_bloc` package provides a foundation for building robust and scalable applications using the BLoC pattern. By leveraging abstract classes tailored for various use cases, you can effectively manage state and encapsulate business logic in your Flutter applications.

---

### 📜 License

MIT License

---

Happy coding! 🚀
