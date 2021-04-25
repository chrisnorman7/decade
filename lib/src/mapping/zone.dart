/// Provides the [Zone] class.
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:flutter/services.dart';

import '../action.dart';
import '../game.dart';
import '../level.dart';
import '../sound/audio_channel.dart';
import '../sound/sound.dart';
import 'terrain.dart';

/// The directions it is possible to move in, in a top-down map.
enum MoveDirections {
  /// North.
  north,

  /// East.
  east,

  /// South
  south,

  /// West.
  west
}

/// A game map.
class Zone<TT extends Terrain<DT>, DT> extends Level {
  /// Create a zone.
  Zone(Game game, String title, this.defaultTerrain,
      {List<FileSystemEntity>? music,
      Map<Point<int>, TT>? terrainList,
      Point<int>? startCoordinates,
      Point<int>? endCoordinates,
      Point<int>? coords,
      List<LevelAction>? actions})
      : terrains = terrainList ?? {},
        terrainChannels = {},
        terrainAmbiances = {},
        start = startCoordinates ?? Point<int>(0, 0),
        end = endCoordinates ?? Point<int>(100, 100),
        coordinates = coords ?? Point<int>(0, 0),
        super(game, title, actionList: actions, music: music);

  /// The lowest coordinates on the map.
  final Point<int> start;

  /// The highest coordinates on the map.
  final Point<int> end;

  /// The current coordinates of the player.
  Point<int> coordinates;

  /// All the terrains on this zone.
  final Map<Point<int>, TT> terrains;

  /// The channels for playing terrain ambiances.
  final Map<Point<int>, AudioChannel> terrainChannels;

  /// All the playing terrain ambiances.
  final Map<Point<int>, Sound> terrainAmbiances;

  /// The default terrain when moving on this map.
  final TT defaultTerrain;

  /// Get the current terrain.
  TT get terrain => terrains[coordinates] ?? defaultTerrain;

  /// Add walking commands.
  @override
  void setup() {
    super.setup();
    actions.addAll([
      LevelAction('Move north', ActionHotkey(PhysicalKeyboardKey.keyW),
          triggerFunc: () => move(MoveDirections.north),
          interval: Duration(milliseconds: 500)),
      LevelAction('Move east', ActionHotkey(PhysicalKeyboardKey.keyD),
          triggerFunc: () => move(MoveDirections.east),
          interval: Duration(milliseconds: 500)),
      LevelAction('Move south', ActionHotkey(PhysicalKeyboardKey.keyS),
          triggerFunc: () => move(MoveDirections.south),
          interval: Duration(milliseconds: 500)),
      LevelAction('Move west', ActionHotkey(PhysicalKeyboardKey.keyA),
          triggerFunc: () => move(MoveDirections.west),
          interval: Duration(milliseconds: 500)),
      LevelAction('Show coordinates', ActionHotkey(PhysicalKeyboardKey.keyC),
          triggerFunc: () => game.output('${coordinates.x}, ${coordinates.y}')),
      LevelAction('Activate terrain', ActionHotkey(PhysicalKeyboardKey.enter),
          triggerFunc: activate)
    ]);
  }

  /// This terrain has been pushed.
  @override
  void onPush() {
    super.onPush();
    startTerrains();
    game.audioFactory.ctx.position =
        Double3(coordinates.x.toDouble(), coordinates.y.toDouble(), 0.0);
    terrain.onEnter();
  }

  /// This terrain has been popped, call [stopTerrains].
  @override
  void onPop() {
    terrain.onExit();
    super.onPop();
    stopTerrains();
  }

  /// Add a new terrain to the [terrains] map.
  void addTerrain(TT t, Point<int> coords) {
    terrains[coords] = t;
    startTerrain(t, coords);
  }

  /// Start a terrain ambiance.
  void startTerrain(TT t, Point<int> coords) {
    final ambiance = t.ambiance;
    final c = game.audioFactory.createThreeDChannel()
      ..position = Double3(coords.x.toDouble(), coords.y.toDouble(), 0.0)
      ..gain = t.ambianceGain;
    if (ambiance != null) {
      terrainAmbiances[coords] = c.loadFile(ambiance)..generator.looping = true;
      terrainChannels[coords] = c;
    }
  }

  /// Start all terrain ambiances playing.
  void startTerrains() =>
      terrains.forEach((key, value) => startTerrain(value, key));

  /// Remove a terrain from the [terrains] map.
  void removeTerrain(TT t, Point<int> coords) {
    stopTerrain(t, coords);
    terrains.remove(coords);
  }

  /// Stop a terrain from playing its ambiance.
  void stopTerrain(TT t, Point<int> coords) {
    final a = terrainAmbiances.remove(coords);
    if (a != null) {
      a.channel.destroySound(a);
    }
  }

  /// Stop all terrain ambiances playing.
  void stopTerrains() =>
      terrains.forEach((key, value) => stopTerrain(value, key));

  /// Move in a direction.
  void move(MoveDirections direction) {
    Point<int> difference;
    switch (direction) {
      case MoveDirections.north:
        difference = Point(0, 1);
        break;
      case MoveDirections.east:
        difference = Point(1, 0);
        break;
      case MoveDirections.south:
        difference = Point(0, -1);
        break;
      case MoveDirections.west:
        difference = Point(-1, 0);
        break;
    }
    final p = coordinates + difference;
    if (p.x >= start.x && p.x <= end.x && p.y >= start.y && p.y <= end.y) {
      final oldTerrain = terrain;
      coordinates = p;
      final newTerrain = terrain;
      if (newTerrain != oldTerrain) {
        oldTerrain.onExit();
        newTerrain.onEnter();
      }
      game
        ..interfaceSoundsChannel.playSound(newTerrain.footstepSound)
        ..audioFactory.ctx.position =
            Double3(p.x.toDouble(), p.y.toDouble(), 0);
    }
  }

  /// Activate the current terrain.
  void activate() => terrain.onActivate();
}
