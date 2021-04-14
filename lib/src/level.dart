/// Provides the [DecadeLevel] class.
library level;

import 'package:flutter/services.dart';

import 'action.dart';
import 'game.dart';
import 'mixins.dart';

/// This class represents a level in a game.
///
/// Actions can be bound to levels to provide functionality.
class DecadeLevel extends TitleMixin {
  /// Create a level.
  DecadeLevel(this.game, this.title, {List<DecadeAction>? actionList})
      : actions = actionList ?? [];

  /// The game this level is bound to.
  ///
  /// Levels can be bound to one game at a time.
  final DecadeGame game;

  /// The title of this level.
  @override
  final String title;

  /// The actions which can be triggered on this level.
  final List<DecadeAction> actions;

  /// The currently running actions.
  List<DecadeAction> get runningActions =>
      actions.where((element) => element.running).toList();

  /// This level has been pushed.
  void onPush() {}

  /// This level has been popped from the level stack.
  void onPop() {}

  /// This level has been covered.
  void onCover(

      /// The level which has covered this level.
      DecadeLevel by) {}

  /// This level has been revealed.
  ///
  /// This method is called when [DecadeGame.popLevel] is used, and there is a
  /// [DecadeLevel] instance remaining on the stack after popping.
  void onReveal(

      /// The level which was popped, thus revealing this level.
      DecadeLevel by) {}

  /// Handle a key being pressed.
  void keyDown(RawKeyDownEvent event) {
    for (final a in actions) {
      if (a.hotkey.matches(event)) {
        a.start();
      }
    }
  }

  /// Handle a key being released.
  void keyUp(RawKeyUpEvent event) {
    for (final a in runningActions) {
      if (a.hotkey.matches(event, includeModifiers: false)) {
        a.stop();
      }
    }
  }
}
