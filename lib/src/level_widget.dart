/// Provides the [LevelWidget] class.
import 'package:flutter/material.dart';

import '../decade.dart';

/// A widget for displaying a decade level.
class LevelWidget extends StatefulWidget {
  /// Create a widget.
  const LevelWidget(this.level, {Key? key}) : super(key: key);

  /// The level this widget represents.
  final Level level;

  /// Create state for this widget.
  @override
  _LevelWidgetState createState() => _LevelWidgetState();
}

/// State for [LevelWidget].
class _LevelWidgetState extends State<LevelWidget> {
  /// Whether or not this state is fully setup.
  bool _isLoaded = false;

  /// The focus node to use with the keyboard handler.
  FocusNode? _focusNode;

  /// Actually call the load function.
  Future<void> load() async {
    await widget.level.load(this);
    setState(() {
      _isLoaded = true;
    });
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isLoaded == false) {
      load();
      child = CircularProgressIndicator();
    } else {
      var focusNode = _focusNode;
      if (focusNode == null) {
        focusNode = FocusNode();
        FocusScope.of(context).requestFocus(focusNode);
      }
      child = Focus(
        child: RawKeyboardListener(
          child: Text(widget.level.title),
          focusNode: focusNode,
          onKey: widget.level.game.handleKey,
        ),
        autofocus: true,
      );
    }
    return child;
  }

  /// Dispose of the focus node.
  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }
}
