import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_extensions/flutter_bloc_extensions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter bloc extensions example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DisposableBlocProvider(
        blocFactory: () => LoginBloc(),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            BlocProjectionBuilder<LoginEvent, LoginState, String>(
              bloc: bloc,
              converter: (state) => state.nameError,
              builder: (_, nameError) {
                return TextField(
                  decoration:
                      InputDecoration(labelText: "Name", errorText: nameError),
                  onChanged: (name) => bloc.dispatch(ChangeNameEvent(name)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: <Widget>[
                  BlocProjectionBuilder<LoginEvent, LoginState, bool>(
                    bloc: bloc,
                    converter: (state) => state.hasAgreed,
                    builder: (_, hasAgreed) {
                      return Checkbox(
                        onChanged: (value) =>
                            bloc.dispatch(ChangeAgreement(value)),
                        value: hasAgreed,
                      );
                    },
                  ),
                  Text("Agree to license")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: BlocProjectionBuilder<LoginEvent, LoginState, bool>(
                bloc: bloc,
                converter: (state) => state.hasAgreed,
                builder: (context, hasAgreed) {
                  return RaisedButton(
                    onPressed: hasAgreed ? () => _showDialog(context) : null,
                    child: Text("Login"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Done"),
          content: new Text("Login successful"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => LoginState();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is ChangeNameEvent) {
      if (event.name.length < 3) {
        yield currentState.copyWith(
            name: event.name, nameError: "Name is too short.");
        return;
      }
      yield currentState.copyWith(name: event.name, nameError: null);
      return;
    }
    if (event is ChangeAgreement) {
      yield currentState.copyWith(hasAgreed: event.hasAgreed);
    }
  }
}

abstract class LoginEvent {}

class ChangeNameEvent extends LoginEvent {
  final String name;

  ChangeNameEvent(this.name);
}

class ChangeAgreement extends LoginEvent {
  final bool hasAgreed;

  ChangeAgreement(this.hasAgreed);
}

class LoginState {
  final String name;
  final String nameError;
  final bool hasAgreed;

  LoginState({this.name = "", this.nameError, this.hasAgreed = false});

  LoginState copyWith({String name, String nameError, bool hasAgreed}) {
    return LoginState(
        name: name ?? this.name,
        nameError: nameError,
        hasAgreed: hasAgreed ?? this.hasAgreed);
  }
}
