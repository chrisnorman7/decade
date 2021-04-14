/// Provides the [DecadeGame] class.
library game;

import 'package:flutter/services.dart';

import 'action.dart';
import 'level.dart';
import 'mixins.dart';

/// This class is the top level object.
///
/// Instances of this class hold a stack of [DecadeLevel] instances.
///
/// You should subclass to provide text [DecadeGame.output], and the playing of
/// sounds with [DecadeGame.playSound].
class DecadeGame extends TitleMixin {
  /// Create a new game.
  DecadeGame(this.title);

  /// The title of this game.
  @override
  final String title;

  /// The levels stack.
  ///
  /// This list will be empty until [pushLevel] is used, and may be empty again
  /// if [popLevel] is used enough times.
  ///
  /// You should not use this value directly unless you have to, but instead
  /// rely upon the [level] attribute.
  final List<DecadeLevel> levels = [];

  /// Get the current level.
  ///
  /// This value will be `null` if no level has been pushed yet.
  DecadeLevel? get level {
    if (levels.isEmpty) {
      return null;
    }
    return levels.last;
  }

  /// Output some text.
  ///
  /// This method should be overridden depending on your application.
  void output(

          /// The text to output.
          String text) =>
      // ignore: avoid_print
      print(text);

  /// Play a sound.
  ///
  /// This method will be updated when the sound system has been written, and
  /// should be overridden depending on your application.
  void playSound(

          /// The URL where the sound file resides.
          String url) =>
      // ignore: avoid_print
      print('Play sound $url.');

  /// Push a level onto the stack.
  ///
  /// The new level will have its [DecadeLevel.onPush] method called.
  ///
  /// If the new level is covering a level already in the stack, then that
  /// level will have its [DecadeLevel.onCover] method called.
  void pushLevel(

      /// The level which should be pushed onto the stack.
      DecadeLevel level) {
    if (levels.isNotEmpty) {
      levels.last.onCover(level);
    }
    level.onPush();
    levels.add(level);
  }

  /// Pop a level from the stack.
  ///
  /// The level will have its [DecadeLevel.onPop] method called.
  ///
  /// If there are levels remaining in the stack after popping, the next
  /// current level will have its [DecadeLevel.onReveal] method called.
  void popLevel() {
    if (levels.isEmpty) {
      return null;
    }
    final old = levels.removeLast()..onPop();
    if (levels.isNotEmpty) {
      levels.last.onReveal(old);
    }
  }

  /// Press a key combination.
  ///
  /// If [level is `null`, this method does nothing. Otherwise, the level's
  /// [DecadeLevel.actions] are iterated over, and any which have the correct
  /// hotkey have their [DecadeAction.start] method called.
  void keyDown(RawKeyDownEvent event) => level?.keyDown(event);

  /// Release a key combination.
  ///
  /// If [level is `null`, this method does nothing. Otherwise, the level's
  /// [DecadeLevel.actions] are iterated over, and any which have the correct
  /// hotkey have their [DecadeAction.stop] method called.
  void keyUp(RawKeyUpEvent event) => level?.keyUp(event);

  /// Handle any type of key.
  ///
  /// If [event] is a [RawKeyDownEvent], then [keyDown] is used.
  ///
  /// If [event] is a [RawKeyUpEvent], then [keyUp] will be used.
  void handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      keyDown(event);
    } else if (event is RawKeyUpEvent) {
      keyUp(event);
    } else {
      throw Exception('Invalid event: $event.');
    }
  }
}
