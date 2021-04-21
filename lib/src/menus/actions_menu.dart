/// Provides the [ActionsMenu] class.
import '../../decade.dart';
import '../game.dart';
import 'menu.dart';

/// An action menu.
///
/// This class can be thought of as a help menu.
class ActionsMenu extends Menu {
  /// Create an actions menu.
  ActionsMenu(Game game, Level level, {String title = 'Actions'})
      : super(
            game,
            title,
            level.actions
                .map<MenuItem>((Action action) =>
                    MenuItem(func: action.run, title: action.title))
                .toList());

  /// This menu has been pushed, show the title.
  @override
  void onPush() {
    super.onPush();
    showItem();
  }
}
