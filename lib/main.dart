import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:dart_tolk/dart_tolk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'decade.dart' as decade;

/// Game title.
const String gameTitle = 'Tree Tagger';

/// Run the program.
///
/// All keyboard events should be captured and spoken, until I can do something
/// more useful.
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
      ),
      body: GameWidget(),
    ),
  ));
}

/// The widget to display the game.
class GameWidget extends StatefulWidget {
  /// Create state for this widget.
  @override
  _GameWidgetState createState() => _GameWidgetState();
}

/// State for [GameWidget].
class _GameWidgetState extends State<GameWidget> {
  /// The game.
  decade.Game? _game;

  /// The focus nose.
  FocusNode? _focusNode;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    var focusNode = _focusNode;
    if (focusNode == null) {
      focusNode = FocusNode(debugLabel: 'Keyboard focus');
      FocusScope.of(context).requestFocus(focusNode);
      _focusNode = focusNode;
    }
    var game = _game;
    if (game == null) {
      game = decade.Game(
          gameTitle,
          Tolk.windows()
            ..load()
            ..trySapi(true),
          decade.AudioFactory(Synthizer.fromPath('synthizer.dll')..initialize())
            ..init(),
          [])
        ..musicChannel.gain = 0.4;
      game.musicChannel
          .loadFile(File('sounds/music/main_theme.wav'), stream: true)
            ..generator.looping = true;
      game.pushLevel(MainMenu(game));
      _game = game;
      _game = game;
    }
    return Focus(
      child: RawKeyboardListener(
        child: Text('Keyboard focus goes here.'),
        focusNode: focusNode,
        onKey: game.handleKey,
      ),
      autofocus: true,
    );
  }

  /// Dispose of the various subsystems.
  @override
  void dispose() {
    super.dispose();
    _focusNode?.dispose();
    _game?.tts.unload();
    _game?.audioFactory.destroy();
    _game?.audioFactory.synthizer.shutdown();
  }
}

/// The main menu.
///
/// This menu will always be shown, because there is currently no way to exit a
/// Flutter desktop app.
class MainMenu extends decade.Menu {
  /// Create a main menu.
  MainMenu(decade.Game game)
      : super(
            game,
            'Main Menu',
            [
              decade.MenuItem(
                  title: 'Play',
                  func: () {
                    final zone = decade.Zone(
                        game,
                        'forest',
                        decade.Terrain(game.audioFactory,
                            Directory('sounds/footsteps/dirt')),
                        {},
                        Point<int>(0, 0),
                        Point<int>(100, 100),
                        actions: [
                          decade.Action('Return to main menu',
                              decade.Hotkey(PhysicalKeyboardKey.escape),
                              triggerFunc: () {
                            final m = decade.Menu(
                                game, 'Are you sure you want to quit?', [
                              decade.MenuItem(
                                  title: 'Yes',
                                  func: () {
                                    game..popLevel()..popLevel();
                                  }),
                              decade.MenuItem(
                                  title: 'No',
                                  func: () {
                                    game
                                      ..popLevel()
                                      ..output('Cancelled.');
                                  })
                            ]);
                            game.pushLevel(m);
                          })
                        ]);
                    game.pushLevel(zone);
                  }),
              decade.MenuItem(
                  title: 'Debug help mode',
                  func: () {
                    game
                      ..helpMode = true
                      ..output('Debug mode enabled. Disabling in 5 seconds.');
                    Timer(Duration(seconds: 5), () {
                      game
                        ..helpMode = false
                        ..output('Debug mode disabled.');
                    });
                  })
            ],
            selectSound: File('sounds/interface/beep.wav'));

  /// Reset focus.
  @override
  void onCover(decade.Level by) {
    super.onCover(by);
    position = null;
  }
}
