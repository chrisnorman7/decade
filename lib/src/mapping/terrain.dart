/// Provides the [Terrain] class.
import 'dart:io';

import '../game.dart';
import 'zone.dart';

/// A piece of a [Zone].
///
/// This class can be thought of as a tile on a map.
class Terrain<T> {
  /// Create some terrain.
  Terrain(this.game, this.footstepSound,
      {this.ambiance, this.ambianceGain = 0.5, this.data});

  /// The game this terrain is part of.
  final Game game;

  /// The footstep sound which will be heard when walking on this terrain.
  final FileSystemEntity footstepSound;

  /// The sound which denotes this terrain on the map.
  final FileSystemEntity? ambiance;

  /// The gain of [ambiance].
  final double ambianceGain;

  /// The data associated with this terrain.
  final T? data;

  /// The method which is called when entering this terrain.
  void onEnter() {}

  /// The method which is called when exiting this terrain.
  void onExit() {}

  /// The method which is called when pressing the enter key in this terrain.
  void onActivate() {}
}
