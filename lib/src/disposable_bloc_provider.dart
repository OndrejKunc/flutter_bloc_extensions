import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A simple wrapper around [BlocProvider] which also
/// handles calling the dispose method on the [bloc].
///
/// Bloc must be created using `blocFactory` so you can
/// create it directly inside build function and prevent
/// multiple instances to be created on each build.
class DisposableBlocProvider<T extends Bloc<dynamic, dynamic>>
    extends StatefulWidget {
  final Widget child;
  final T Function() blocFactory;

  DisposableBlocProvider({
    Key key,
    @required this.child,
    @required this.blocFactory,
  }) : super(key: key);

  @override
  _DisposableBlocProviderState createState() =>
      _DisposableBlocProviderState<T>();
}

class _DisposableBlocProviderState<T extends Bloc<dynamic, dynamic>>
    extends State<DisposableBlocProvider<T>> {
  T _bloc;

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _bloc = widget.blocFactory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: widget.child,
      bloc: _bloc,
    );
  }
}
