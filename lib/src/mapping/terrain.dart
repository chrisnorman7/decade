/// Provides the [Terrain] class.
import 'dart:io';

import '../sound/audio_factory.dart';
import 'zone.dart';

/// A piece of a [Zone].
///
/// This class can be thought of as a tile on a map.
class Terrain {
  /// Create some terrain.
  Terrain(this.factory, this.footstepSound, {this.ambiance});

  /// The audio factory used by this terrain.
  final AudioFactory factory;

  /// The footstep sound which will be heard when walking on this terrain.
  final FileSystemEntity footstepSound;

  /// The sound which denotes this terrain on the map.
  final FileSystemEntity? ambiance;

  /// The method which is called when entering this terrain.
  void onEnter() {}

  /// The method which is called when pressing the enter key in this terrain.
  void onActivate() {}
}
