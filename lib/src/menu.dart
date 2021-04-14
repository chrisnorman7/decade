/// Provides the [DecadeMenu] class.
library menu;

import 'dart:math';

import 'game.dart';
import 'level.dart';
import 'typedefs.dart';

/// An item in a menu.
class DecadeMenuItem {
  /// Create a menu item.
  const DecadeMenuItem(
      {this.func, this.title, this.selectSoundUrl, this.activateSoundUrl});

  /// The function which will be called when this item is selected.
  ///
  /// If this value is `null`, it will be impossible to activate this item.
  final DecadeLevelCallback? func;

  /// The title of this item.
  ///
  /// If this value is `null`, nothing will be spoken when this item is
  /// selected.
  final String? title;

  /// The sound which will be heard when this item is selected.
  ///
  /// If this value is `null`, no sound will be played when this menu item is
  /// selected.
  final String? selectSoundUrl;

  /// The sound which will be played when this item is activated.
  ///
  /// If this value is `null`, no sound will be played when this item is
  /// activated.
  final String? activateSoundUrl;
}

/// A menu, which holds a list of [DecadeMenuItem] instances.
class DecadeMenu extends DecadeLevel {
  /// Create a menu instance.
  DecadeMenu(DecadeGame game, String title, this.items) : super(game, title);

  /// The current position in this menu.
  ///
  /// If this value is `null`, then the user has not made a selection, and the
  /// title of the menu should be shown.
  int? position;

  /// All the items for this menu.
  final List<DecadeMenuItem> items;

  /// Get the current item.
  ///
  /// If this value is `null`, then the title of this menu should be shown.
  DecadeMenuItem? get currentItem {
    final pos = position;
    if (pos == null || pos >= items.length) {
      return null;
    } else {
      return items[pos];
    }
  }

  /// Show the current item.
  ///
  /// If [position] is `null`, the title of the menu will be shown. Otherwise,
  /// the title of the newly-selected item will be shown.
  ///
  /// If the newly-selected item has a non-null [DecadeMenuItem.selectSoundUrl]
  /// attribute, that URL will be played with the [DecadeGame.playSound] method.
  void showItem(
      {

      /// An optional item to show.
      ///
      /// If this value is `null`, [currentItem] will be used.
      DecadeMenuItem? item}) {
    item ??= currentItem;
    if (item == null) {
      return game.output(title);
    }
    final itemTitle = item.title;
    if (itemTitle != null) {
      game.output(itemTitle);
    }
    final selectSoundUrl = item.selectSoundUrl;
    if (selectSoundUrl != null) {
      game.playSound(selectSoundUrl);
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
    } else {
      position = min(items.length - 1, p + 1);
    }
    showItem();
  }
}
