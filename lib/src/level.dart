/// Provides the [Level] class.
library level;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'action.dart' as decadeActions;
import 'game.dart';
import 'level_widget.dart';
import 'mixins.dart';
import 'sound/sound.dart';

/// This class represents a level in a game.
///
/// Actions can be bound to levels to provide functionality.
class Level extends TitleMixin {
  /// Create a level.
  Level(this.game, this.title,
      {List<decadeActions.Action>? actionList,
      this.cancellable = false,
      List<FileSystemEntity>? music})
      : actions = actionList ?? <decadeActions.Action>[],
        musicFiles = music ?? <FileSystemEntity>[],
        musicObjects = <Sound>[] {
    setup();
  }

  /// The game this level is bound to.
  ///
  /// Levels can be bound to one game at a time.
  final Game game;

  /// The title of this level.
  @override
  final String title;

  /// The actions which can be triggered on this level.
  final List<decadeActions.Action> actions;

  /// The currently running actions.
  List<decadeActions.Action> get runningActions =>
      actions.where((element) => element.running == true).toList();

  /// Stop all running actions.
  void clearRunningActions() =>
      runningActions.forEach((element) => element.stop());

  /// Whether or not the [cancel] method can be used on this instance.
  final bool cancellable;

  /// A list of files which should be played as music on this level.
  final List<FileSystemEntity> musicFiles;

  /// All the music objects that are playing.
  final List<Sound> musicObjects;

  /// Finish setting up this level.
  @mustCallSuper
  void setup() {}

  /// This level has been pushed.
  @mustCallSuper
  void onPush() {
    musicFiles.forEach((element) {
      musicObjects.add(game.musicChannel.loadFile(element, stream: true)
        ..generator.looping = true);
    });
  }

  /// This level has been popped from the level stack.
  void onPop() {
    musicObjects
      ..forEach((element) {
        element.destroy();
      })
      ..clear();
  }

  /// This level has been covered by [by].
  ///
  /// This method calls the [clearRunningActions] method.
  void onCover(Level by) => clearRunningActions();

  /// This level has been revealed by [by].
  ///
  /// This method is called when [Game.popLevel] is used, and there is a
  /// [Level] instance remaining on the stack after popping.
  void onReveal(Level by) {}

  /// Handle a key being pressed.
  void keyDown(RawKeyDownEvent event) {
    for (final a in actions) {
      if (a.hotkey.matches(event.data)) {
        a.start();
      }
    }
  }

  /// Handle a key being released.
  void keyUp(RawKeyUpEvent event) {
    for (final a in runningActions) {
      if (a.hotkey.matches(event.data, includeModifiers: false)) {
        a.stop();
      }
    }
  }

  /// Pop this menu from [game].
  ///
  /// If [cancellable] is `true`, then [Game.popLevel] will be called.
  @mustCallSuper
  void cancel() {
    if (cancellable) {
      game.popLevel();
    }
  }

  /// A method to enable [LevelWidget] to perform asynchronous processing.
  Future<void> load(State state) async {}
}
