/// Provides the [Menu] class.
library menu;

import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../decade.dart';
import '../game.dart';
import '../level.dart';
import '../typedefs.dart';

/// An item in a menu.
class MenuItem {
  /// Create a menu item.
  const MenuItem({this.func, this.title, this.selectSound, this.activateSound});

  /// The function which will be called when this item is selected.
  ///
  /// If this value is `null`, it will be impossible to activate this item.
  final ActionCallback? func;

  /// The title of this item.
  ///
  /// If this value is `null`, nothing will be spoken when this item is
  /// selected.
  final String? title;

  /// The sound which will be heard when this item is selected.
  ///
  /// If this value is `null`, no sound will be played when this menu item is
  /// selected.
  final FileSystemEntity? selectSound;

  /// The sound which will be played when this item is activated.
  ///
  /// If this value is `null`, no sound will be played when this item is
  /// activated.
  final FileSystemEntity? activateSound;
}

/// A menu which holds a list of [MenuItem] instances.
class Menu extends Level {
  /// Create a menu instance.
  Menu(Game game, String title, this.items,
      {List<FileSystemEntity>? music,
      this.selectSound,
      this.activateSound,
      this.cancelMessage,
      this.cancelSound,
      bool canBeCancelled = false})
      : super(game, title, music: music, cancellable: canBeCancelled);

  /// The current position in this menu.
  ///
  /// If this value is `null`, then the user has not made a selection, and the
  /// title of the menu should be shown.
  int? position;

  /// All the items for this menu.
  final List<MenuItem> items;

  /// Get the current item.
  ///
  /// If this value is `null`, then the title of this menu should be shown.
  MenuItem? get currentItem {
    final pos = position;
    if (pos == null || pos >= items.length) {
      return null;
    }
    return items[pos];
  }

  /// The sound which should be played when selecting an item.
  ///
  /// This sound can be overridden by [MenuItem.selectSound].
  final FileSystemEntity? selectSound;

  /// The sound that will be played when activating an item.
  ///
  /// This sound can be overridden by [MenuItem.activateSound].
  final FileSystemEntity? activateSound;

  /// The message that will be shown when [cancel] is called.
  final String? cancelMessage;

  /// The sound that will be played when [cancel] is called.
  final FileSystemEntity? cancelSound;

  /// Finish setting up this menu.
  @override
  void setup() {
    super.setup();
    actions.addAll(<LevelAction>[
      LevelAction('Move up', ActionHotkey(PhysicalKeyboardKey.keyW),
          triggerFunc: moveUp),
      LevelAction('Move down', ActionHotkey(PhysicalKeyboardKey.keyS),
          triggerFunc: moveDown),
      LevelAction(
          'Activate a menu item', ActionHotkey(PhysicalKeyboardKey.keyD),
          triggerFunc: activateItem),
      LevelAction('Cancel', ActionHotkey(PhysicalKeyboardKey.keyA),
          triggerFunc: cancel)
    ]);
  }

  /// Show the current item.
  ///
  /// If [position] is `null`, the title of the menu will be shown. Otherwise,
  /// the title of the newly-selected item will be shown.
  ///
  /// If the newly-selected item has a non-null [MenuItem.selectSound]
  /// attribute, that URL will be played with the [Game.playSound] method.
  ///
  /// If [item] is `null`, [currentItem] will be used.
  void showItem({MenuItem? item}) {
    item ??= currentItem;
    if (item == null) {
      return game.output(title);
    }
    final itemTitle = item.title;
    if (itemTitle != null) {
      game.output(itemTitle);
    }
    final sound = item.selectSound ?? selectSound;
    if (sound != null) {
      game.playSound(sound);
    }
  }

  /// Move up in the menu.
  ///
  /// If [position] is `0`, or `null`, the [title] of the menu will be shown.
  void moveUp() {
    final p = position;
    if (p == 0 || p == null) {
      position = null;
    } else {
      position = p - 1;
    }
    showItem();
  }

  /// Move down in the menu.
  ///
  /// This function will not allow wrapping.
  void moveDown() {
    final p = position;
    if (p == null) {
      position = 0;
    } else if (items.isEmpty) {
      position = null;
    } else {
      position = min(items.length - 1, p + 1);
    }
    showItem();
  }

  /// Activate a menu item.
  ///
  /// If [item] is `null`, the current item will be used.
  void activateItem({MenuItem? item}) {
    item ??= currentItem;
    if (item != null) {
      final sound = item.activateSound ?? activateSound;
      if (sound != null) {
        game.playSound(sound);
      }
      final f = item.func;
      if (f != null) {
        f();
      }
    }
  }

  /// This menu has been pushed. Show the title.
  @override
  void onPush() {
    super.onPush();
    showItem();
  }

  /// This menu has been revealed. Show the title.
  @override
  void onReveal(Level by) {
    super.onReveal(by);
    showItem();
  }

  /// Cancel this menu, and say something.
  @override
  void cancel() {
    final message = cancelMessage;
    if (message != null) {
      game.output(message);
    }
    final sound = cancelSound;
    if (sound != null) {
      game.playSound(sound);
    }
    super.cancel();
  }
}
