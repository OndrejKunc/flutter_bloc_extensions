# flutter_bloc_extensions

[![pub package](https://img.shields.io/pub/v/flutter_bloc_extensions.svg)](https://pub.dartlang.org/packages/flutter_bloc_extensions)

Collection of helper objects built on top of awesome library by Felix Angelov `flutter_bloc` : https://github.com/felangel/bloc/

## Features
1. [BlocProjectionBuilder](#blocProjectionBuilder)
A Flutter widget slightly more powerful than `BlocBuilder`. The main difference is the additional `converter` parameter which is responsible for listening on changes only on the subset of the state. This can bring some performance benefits since each widget can listen only to the relevant part of the bloc state and the number of widget rebuilds can be greatly reduced (in some cases). 

2. [DisposableBlocProvider](#disposableBlocProvider)
A simple wrapper widget around `BlocProvider` which also handles calling the dispose method on the `bloc`. Bloc must be created using `blocFactory` parameter so you can create the bloc directly inside the build function of parent widget and prevent multiple instances to be created on each build.

More features like special purpose blocs for loading data with progress indicator or bloc suitable for complex forms with many states coming soon....

## Why does this exist?
While developing apps with `flutter_bloc` library I came up with a bunch of bloc-related general purpose objects. Those objects are often useful only in special use cases so it doesn't make much sense to have them in the original library. For more info why this library was created see this thread: https://github.com/felangel/bloc/issues/174

## Usage

### BlocProjectionBuilder
Example of the builder listening only to the single value from the state. It won't be rebuild every time new state is emitted but only when this value is changed:
```dart
BlocProjectionBuilder<LoginEvent, LoginState, bool>(
    bloc: bloc,
    converter: (state) => state.hasAgreed,
    builder: (context, hasAgreed) {
        return RaisedButton(
            onPressed: hasAgreed ? () => _showDialog(context) : null,
            child: Text("Login"),
        );
    },
)
```
Converter doesn't have to return just single value as in the example above, it can be more complex custom object composed of multiple properties from the bloc:
```dart
converter: (state) => 
    MyViewModel(property1: state.property1, property2: state.property2),
```
In order for this to work correctly, you must implement `==` and `hashCode` in your `ViewModel` so the builder will correctly detect when your `ViewModel` has changed.

### DisposableBlocProvider
Whenever you create a bloc instance you are also responsible for disposing it. Good rule of thumb is to dispose it in the same place/widget where you created it. `BlocProvider` is not responsible for disposing your bloc object because it could be surprising behavior for many users. That's why `DisposableBlocProvider` exists. Its name already indicates that the bloc will be disposed together with the `DisposableBlocProvider` widget.

```dart
//Inside build method
DisposableBlocProvider(
    blocFactory: () => MyBloc(),
    child: MyPage(),
)

//Inside MyPage
Widget build(BuildContext context) {
    var bloc = BlocProvider.of<LoginBloc>(context);
    //...
}
```
Since `DisposableBlocProvider` creates `BlocProvider` under the hood you can retrieve the instance via `BlocProvider.of` as you would do with regular `BlocProvider`.

