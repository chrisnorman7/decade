/// Provides the [DecadeActionsMenu] class.
import '../../decade.dart';
import '../game.dart';
import 'menu.dart';

/// An action menu.
class DecadeActionsMenu extends DecadeMenu {
  /// Create an actions menu.
  DecadeActionsMenu(DecadeGame game, DecadeLevel level,
      {String title = 'Actions'})
      : super(
            game,
            title,
            level.actions
                .map<DecadeMenuItem>((DecadeAction action) =>
                    DecadeMenuItem(func: action.run, title: action.title))
                .toList());

  /// This menu has been pushed, show the title.
  @override
  void onPush() {
    super.onPush();
    showItem();
  }
}
