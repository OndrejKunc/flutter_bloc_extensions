import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// Signature for the builder function which takes the [BuildContext] and converted state
/// and is responsible for returning a [Widget] which is to be rendered.
typedef ViewModelBuilder<ViewModel> = Widget Function(
  BuildContext context,
  ViewModel viewModel,
);

/// Signature for the converter function which convertc bloc state into the
/// new ViewModel object
typedef StateConverter<S, ViewModel> = ViewModel Function(
  S state,
);

/// A Flutter widget slightly more powerful than [BlocBuilder]. The main
/// difference is the additional [StateConverter] `converter` parameter which
/// is responsible for listening on changes only on the subset of the state.
///
/// Widget is then built using [ViewModelBuilder] `builder` function
/// which contains converted state.
///
/// As a performance optimization, the Widget can be rebuilt only when
/// the [ViewModel] changes. In order for this to work correctly, you
/// must implement [==] and [hashCode] for the [ViewModel], and keep
/// the [distinct] option set to true when creating [BlocProjectionBuilder].
/// When distinct is set to false, rebuild will be called on each
/// state change.
class BlocProjectionBuilder<E, S, ViewModel>
    extends BlocProjectionBuilderBase<E, S, ViewModel> {
  final Bloc<E, S> bloc;
  final StateConverter<S, ViewModel> converter;
  final ViewModelBuilder<ViewModel> builder;
  final bool distinct;

  const BlocProjectionBuilder({
    Key key,
    @required this.bloc,
    @required this.converter,
    @required this.builder,
    this.distinct = true,
  })  : assert(bloc != null),
        assert(builder != null),
        assert(converter != null),
        super(key: key, bloc: bloc);

  @override
  Widget build(BuildContext context, ViewModel viewModel) =>
      builder(context, viewModel);
}

/// A base class for widgets that build themselves based on interaction with
/// a specified [Bloc].
///
/// A [BlocProjectionBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
abstract class BlocProjectionBuilderBase<E, S, ViewModel>
    extends StatefulWidget {
  const BlocProjectionBuilderBase(
      {Key key, this.bloc, this.converter, this.distinct})
      : super(key: key);

  final Bloc<E, S> bloc;
  final StateConverter<S, ViewModel> converter;
  final bool distinct;

  Widget build(BuildContext context, ViewModel viewModel);

  @override
  State<BlocProjectionBuilderBase<E, S, ViewModel>> createState() =>
      _BlocProjectionBuilderBaseState<E, S, ViewModel>();
}

class _BlocProjectionBuilderBaseState<E, S, ViewModel>
    extends State<BlocProjectionBuilderBase<E, S, ViewModel>> {
  StreamSubscription<ViewModel> _subscription;
  ViewModel _state;

  @override
  void initState() {
    super.initState();
    _state = widget.converter(widget.bloc.currentState);
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocProjectionBuilderBase<E, S, ViewModel> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc.state != widget.bloc.state) {
      if (_subscription != null) {
        _unsubscribe();
        _state = widget.converter(widget.bloc.currentState);
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.bloc.state != null) {
      var stream =
          widget.bloc.state.skip(1).map((state) => widget.converter(state));

      // Don't use `Stream.distinct` because it cannot capture the initial
      // ViewModel produced by the `converter`.
      if (widget.distinct) {
        stream = stream.where((vm) {
          final isDistinct = vm != _state;
          return isDistinct;
        });
      }

      _subscription = stream.listen((ViewModel state) {
        setState(() {
          _state = state;
        });
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
