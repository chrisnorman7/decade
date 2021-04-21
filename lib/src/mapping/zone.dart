/// Provides the [Zone] class.
import 'dart:math';

import 'package:flutter/services.dart';

import '../action.dart';
import '../game.dart';
import '../level.dart';
import '../menus/menu.dart';
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
class Zone extends Level {
  /// Create a zone.
  Zone(Game game, String title, this.defaultTerrain, this.terrains, this.start,
      this.end,
      {Point<int>? coords})
      : coordinates = coords ?? start,
        super(game, title, <Action>[]);

  /// The lowest coordinates on the map.
  final Point<int> start;

  /// The highest coordinates on the map.
  final Point<int> end;

  /// The current coordinates of the player.
  Point<int> coordinates;

  /// All the terrains on this zone.
  final Map<Point, Terrain> terrains;

  /// The default terrain when moving on this map.
  final Terrain defaultTerrain;

  /// Add walking commands.
  @override
  void setup() {
    super.setup();
    actions.addAll([
      Action('Move north', Hotkey(PhysicalKeyboardKey.keyW),
          triggerFunc: () => move(MoveDirections.north),
          interval: Duration(milliseconds: 500)),
      Action('Move east', Hotkey(PhysicalKeyboardKey.keyD),
          triggerFunc: () => move(MoveDirections.east),
          interval: Duration(milliseconds: 500)),
      Action('Move south', Hotkey(PhysicalKeyboardKey.keyS),
          triggerFunc: () => move(MoveDirections.south),
          interval: Duration(milliseconds: 500)),
      Action('Move west', Hotkey(PhysicalKeyboardKey.keyA),
          triggerFunc: () => move(MoveDirections.west),
          interval: Duration(milliseconds: 500)),
      Action('Show coordinates', Hotkey(PhysicalKeyboardKey.keyC),
          triggerFunc: () => game.output('${coordinates.x}, ${coordinates.y}')),
      Action('Return to main menu', Hotkey(PhysicalKeyboardKey.escape),
          triggerFunc: () {
        final m = Menu(game, 'Are you sure you want to quit?', [
          MenuItem(
              title: 'Yes',
              func: () {
                game..popLevel()..popLevel();
              }),
          MenuItem(title: 'No', func: game.popLevel)
        ]);
        game.pushLevel(m);
      })
    ]);
  }

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
      coordinates = p;
      final terrain = terrains[p] ?? defaultTerrain;
      game.interfaceSoundsChannel.playSound(terrain.footstepSound);
    }
  }
}
