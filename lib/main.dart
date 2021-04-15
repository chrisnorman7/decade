import 'package:dart_tolk/dart_tolk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'decade.dart';

/// Run the program.
///
/// All keyboard events should be captured and spoken, until I can do something
/// more useful.
void main() {
  runApp(MyApp());
}

/// The top-level app class.
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Decade Experiment',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: KeyboardHandlerWidget(),
      );
}

/// A widget which processes keyboard events.
class KeyboardHandlerWidget extends StatefulWidget {
  /// Create state for this widget.
  @override
  _KeyboardHandlerWidgetState createState() => _KeyboardHandlerWidgetState();
}

/// State for [KeyboardHandlerWidget].
class _KeyboardHandlerWidgetState extends State<KeyboardHandlerWidget> {
  /// The speech subsystem.
  final Tolk tts = Tolk.windows();

  /// The game to add actions and levels to.
  final DecadeGame game = DecadeGame('Decade Example');

  /// Initialise [tts].
  @override
  void initState() {
    super.initState();
    tts
      ..load()
      ..trySapi(true);
    final l = DecadeLevel(game, 'First Level')
      ..actions.addAll(<DecadeAction>[
        DecadeAction('Move up', DecadeHotkey(LogicalKeyboardKey.arrowUp),
            triggerFunc: () => tts.output('Up arrow.')),
        DecadeAction('Move down', DecadeHotkey(LogicalKeyboardKey.arrowDown),
            triggerFunc: () => tts.output('Down arrow.')),
        DecadeAction('Fire', DecadeHotkey(LogicalKeyboardKey.space),
            // ignore: avoid_print
            triggerFunc: () => print(new String.fromCharCodes([0x07])),
            stopFunc: () => tts.output('Stop firing.'),
            interval: Duration(seconds: 2))
      ]);
    game.pushLevel(l);
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    return Scaffold(
        appBar: AppBar(title: Text('Decade')),
        body: Focus(
            child: RawKeyboardListener(
          focusNode: focusNode,
          onKey: game.handleKey,
          child: Center(child: Text('Keyboard focus goes here.')),
        )));
  }
}
