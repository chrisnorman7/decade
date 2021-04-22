/// Provides the [Game] class.
library game;

import 'dart:async';
import 'dart:io';

import 'package:dart_tolk/dart_tolk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'action.dart' as decadeActions;
import 'level.dart';
import 'mixins.dart';
import 'sound/audio_channel.dart';
import 'sound/audio_factory.dart';

/// This class is the top level object.
///
/// Instances of this class hold a stack of [Level] instances.
///
/// You should subclass to provide text [Game.output], and the playing of
/// sounds with [Game.playSound].
class Game implements TitleMixin {
  /// Create a new game.
  Game(this.title, this.tts, this.audioFactory,
      {List<decadeActions.Action>? actions})
      : globalActions = actions ?? <decadeActions.Action>[],
        interfaceSoundsChannel = audioFactory.createUnpannedChannel(),
        musicChannel = audioFactory.createUnpannedChannel() {
    setup();
  }

  /// The title of this game.
  @override
  final String title;

  /// The speech subsystem.
  final Tolk tts;

  /// The audio subsystem.
  final AudioFactory audioFactory;

  /// Global actions that can be triggered, regardless of pushed level.
  final List<decadeActions.Action> globalActions;

  /// The channel for playing interface sounds through.
  final AudioChannel interfaceSoundsChannel;

  /// The channel for playing music through.
  final AudioChannel musicChannel;

  /// The levels stack.
  ///
  /// This list will be empty until [pushLevel] is used, and may be empty again
  /// if [popLevel] is used enough times.
  ///
  /// You should not use this value directly unless you have to, but instead
  /// rely upon the [level] attribute.
  final List<Level> levels = [];

  /// Get the current level.
  ///
  /// This value will be `null` if no level has been pushed yet.
  Level? get level {
    if (levels.isEmpty) {
      return null;
    }
    return levels.last;
  }

  /// Whether or not to speak incoming keys.
  bool helpMode = false;

  /// Finish setting up the game.
  @mustCallSuper
  void setup() {}

  /// Output some text.
  ///
  /// This method will speak [text] using [tts].
  void output(String text, {Duration? when}) =>
      Timer(when ?? Duration(milliseconds: 1), () => tts.output(text));

  /// Play a sound.
  ///
  ///This method uses the [interfaceSoundsChannel] to play [file].
  void playSound(FileSystemEntity file) =>
      interfaceSoundsChannel.playSound(file);

  /// Actually push a level.
  void _pushLevel(Level level) {
    if (levels.isNotEmpty) {
      levels.last.onCover(level);
    }
    level.onPush();
    levels.add(level);
  }

  /// Push a level onto the stack.
  ///
  /// The new level will have its [Level.onPush] method called.
  ///
  /// If the new level is covering a level already in the stack, then that
  /// level will have its [Level.onCover] method called.
  ///
  /// If [when] is not `null`, then a timer will start to push [level] after
  /// [when] has elapsed.
  void pushLevel(Level level, {Duration? when}) {
    if (when == null) {
      _pushLevel(level);
    } else {
      Timer(when, () => _pushLevel(level));
    }
  }

  /// Actually pop a level.
  void _popLevel() {
    if (levels.isEmpty) {
      return null;
    }
    final old = levels.removeLast()..onPop();
    if (levels.isNotEmpty) {
      levels.last.onReveal(old);
    }
  }

  /// Pop a level from the stack.
  ///
  /// The level will have its [Level.onPop] method called.
  ///
  /// If there are levels remaining in the stack after popping, the next
  /// current level will have its [Level.onReveal] method called.
  ///
  /// If [when] is not `null`, set a timer that will push [level] after [when]
  /// has elapsed.
  void popLevel({Duration? when}) {
    if (when == null) {
      _popLevel();
    } else {
      Timer(when, _popLevel);
    }
  }

  /// Pop all levels.
  void popAll() {
    while (levels.isNotEmpty) {
      popLevel();
    }
  }

  /// Handle a pressed key combination.
  ///
  /// If [level is `null`, this method does nothing. Otherwise, the level's
  /// [Level.actions] are iterated over, and any which have the correct
  /// hotkey have their [actions.Action.start] method called.
  void keyDown(RawKeyDownEvent event) {
    for (final a in globalActions) {
      if (a.hotkey.matches(event.data)) {
        a.start();
      }
    }
    level?.keyDown(event);
  }

  /// Release a key combination.
  ///
  /// If [level is `null`, this method does nothing. Otherwise, the level's
  /// [Level.actions] are iterated over, and any which have the correct
  /// hotkey have their [actions.Action.stop] method called.
  void keyUp(RawKeyUpEvent event) {
    for (final a in globalActions) {
      if (a.hotkey.matches(event.data)) {
        a.stop();
      }
    }
    level?.keyUp(event);
  }

  /// Handle any type of key.
  ///
  /// If [event] is a [RawKeyDownEvent], then [keyDown] is used.
  ///
  /// If [event] is a [RawKeyUpEvent], then [keyUp] will be used.
  void handleKey(RawKeyEvent event) {
    if (helpMode) {
      if (event is RawKeyUpEvent) {
        return;
      }
      final List<String> keys = [];
      void getModifierSide(String name, ModifierKey modifier) {
        final side = event.data.getModifierSide(modifier);
        switch (side) {
          case null:
            break;
          case KeyboardSide.any:
            keys.add(name);
            break;
          case KeyboardSide.left:
            keys.add('Left_$name');
            break;
          case KeyboardSide.right:
            keys.add('Right_$name');
            break;
          case KeyboardSide.all:
            keys.add('Both_$name');
            break;
        }
      }

      getModifierSide('Control', ModifierKey.controlModifier);
      getModifierSide('Shift', ModifierKey.shiftModifier);
      getModifierSide('Alt', ModifierKey.altModifier);
      keys.add(event.physicalKey.debugName ??
          'Logical+${event.logicalKey.keyLabel}');
      output(keys.join('+'));
      return;
    }
    if (event is RawKeyDownEvent) {
      keyDown(event);
    } else if (event is RawKeyUpEvent) {
      keyUp(event);
    } else {
      throw Exception('Invalid event: $event.');
    }
  }

  /// Turn the music up a little.
  void musicVolumeUp() => musicChannel.adjustGain(0.05);

  /// Turn the music volume down a little.
  void musicVolumeDown() => musicChannel.adjustGain(-0.05);

  /// Turn interface sounds up a little bit.
  void interfaceSoundsVolumeUp() => interfaceSoundsChannel.adjustGain(0.05);

  /// Turn interface sounds down a little.
  void interfaceSoundsVolumeDown() => interfaceSoundsChannel.adjustGain(-0.05);
}
