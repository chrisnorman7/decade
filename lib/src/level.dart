/// Provides the [Level] class.
library level;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'action.dart' as decadeActions;
import 'game.dart';
import 'mixins.dart';

/// This class represents a level in a game.
///
/// Actions can be bound to levels to provide functionality.
class Level extends TitleMixin {
  /// Create a level.
  Level(this.game, this.title, this.actions, {this.cancellable = false}) {
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

  /// Whether or not the [cancel] method can be used on this instance.
  final bool cancellable;

  /// Finish setting up this level.
  @mustCallSuper
  void setup() {}

  /// This level has been pushed.
  void onPush() {}

  /// This level has been popped from the level stack.
  void onPop() {}

  /// This level has been covered.
  void onCover(

      /// The level which has covered this level.
      Level by) {}

  /// This level has been revealed.
  ///
  /// This method is called when [Game.popLevel] is used, and there is a
  /// [Level] instance remaining on the stack after popping.
  void onReveal(

      /// The level which was popped, thus revealing this level.
      Level by) {}

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
      if (a.hotkey.matches(event.data)) {
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
}
