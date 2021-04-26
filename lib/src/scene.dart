/// Provides the [Scene], and [SceneLevel] classes.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'action.dart';
import 'game.dart';
import 'level.dart';
import 'sound/sound.dart';

/// A scene in a [SceneLevel].
class Scene {
  /// Create a scene.
  Scene(this.sound, this.text);

  /// The sound that will be heard when this scene is current.
  final FileSystemEntity? sound;

  /// The text that will be scene when this scene is active.
  final String? text;
}

/// A level for showing [Scene] instances.
class SceneLevel extends Level {
  /// Create a scene level.
  SceneLevel(Game game, String title, this.scenes,
      {ActionHotkey? advanceHotkey})
      : super(
          game,
          title,
        ) {
    actions.add(LevelAction('Advance to next scene',
        advanceHotkey ?? ActionHotkey(PhysicalKeyboardKey.enter),
        triggerFunc: advance));
  }

  /// The scenes that this level will use.
  final List<Scene> scenes;

  /// The current position in the [scenes] list.
  int? _position;

  /// The currently-playing scene [Scene.sound].
  Sound? _sceneSound;

  /// Advance to the next scene.
  @mustCallSuper
  void advance() {
    final p = _position;
    if (p == null) {
      _position = 0;
    } else {
      _position = p + 1;
    }
    showScene();
  }

  /// Show the currently active scene.
  void showScene() {
    final p = _position ?? 0;
    try {
      final s = scenes[p];
      final sound = s.sound;
      final oldSound = _sceneSound;
      if (oldSound != null) {
        game.interfaceSoundsChannel.destroySound(oldSound);
      }
      if (sound != null) {
        _sceneSound = game.interfaceSoundsChannel.loadFile(sound);
      }
      final text = s.text;
      if (text != null) {
        game.output(text);
      }
    } on RangeError {
      onDone();
    }
  }

  /// This level has been pushed, call [advance].
  @override
  void onPush() {
    super.onPush();
    advance();
  }

  /// The method to call when this level has exhausted all of its scenes.
  @mustCallSuper
  void onDone() {
    final sound = _sceneSound;
    if (sound != null) {
      game.interfaceSoundsChannel.destroySound(sound);
    }
  }
}
