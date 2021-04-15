/// Provides various action classes.
library action;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'mixins.dart';
import 'typedefs.dart';

/// A class which represents a keyboard key.
///
/// Instances of this class can be used to ensure only certain keys trigger an
/// [DecadeAction].
class DecadeHotkey {
  /// Create a hotkey.
  const DecadeHotkey(this.logicalKey,
      {this.controlKey = false, this.altKey = false, this.shiftKey = false});

  /// The flutter key which defines this hotkey.
  final LogicalKeyboardKey logicalKey;

  /// Whether or not the control key is pressed.
  final bool controlKey;

  /// Whether or not the shift key is pressed.
  final bool shiftKey;

  /// Whether or not the alt key is held down.
  final bool altKey;

  /// Returns `true` if [event] matches this hotkey.
  bool matches(RawKeyEvent event, {bool includeModifiers = true}) =>
      event.logicalKey.keyId == logicalKey.keyId &&
      (includeModifiers == false ||
          (event.isAltPressed == altKey &&
              event.isControlPressed == controlKey &&
              event.isShiftPressed == shiftKey));
}

/// An action which can be called.
///
/// Actions can be triggered by the inclusion of a [DecadeHotkey], and can be
/// given an [DecadeAction.interval], to ensure they run on a schedule.
class DecadeAction extends TitleMixin {
  /// Create an action.
  DecadeAction(this.title, this.hotkey,
      {this.triggerFunc, this.spamFunc, this.stopFunc, this.interval});

  /// The title of this action.
  @override
  final String title;

  /// The hotkey which must be used to trigger this action.
  final DecadeHotkey hotkey;

  /// The function which will be called when this action is triggered or
  /// started.
  final DecadeActionCallback? triggerFunc;

  /// The function which will be called when spamming this command.
  ///
  /// For this function to mean something, [interval] must not be `null`.
  final DecadeActionCallback? spamFunc;

  /// The function which will be called when this action is stopped.
  final DecadeActionCallback? stopFunc;

  /// The interval between action runs.
  ///
  /// If this value is `null`, then this action cannot be triggered multiple
  /// times by the hotkey being held down.
  final Duration? interval;

  DateTime? _lastRun;

  /// The time this action was last used.
  DateTime? get lastRun => _lastRun;

  /// The timer which handles running this action.
  Timer? _timer;

  bool _running = false;

  /// Whether or not this action is running.
  bool get running => _running;

  bool _hasRun = false;

  /// Whether or not this action has run since [start] was called.
  bool get hasRun => _hasRun;

  /// Run [triggerFunc].
  void run() {
    final i = interval;
    final now = DateTime.now();
    final lr = _lastRun;
    if (lr == null || (i == null || now.difference(lr) >= i)) {
      _hasRun = true;
      final tf = triggerFunc;
      if (tf != null) {
        tf();
      }
      _lastRun = now;
    } else {
      final sf = spamFunc;
      if (sf != null) {
        sf();
      }
    }
  }

  /// Start this action.
  ///
  /// If [interval] is `null`, just run [triggerFunc] once. Otherwise, schedule
  /// it to
  /// run every [interval].
  void start() {
    final i = interval;
    if (running == false) {
      _hasRun = false;
      run();
      if (i != null) {
        _running = true;
        _timer = Timer.periodic(i, (timer) => run());
      }
    }
  }

  /// Stop this action.
  ///
  /// If [interval] is `null`, do nothing. Otherwise, cancel the timer.
  void stop() {
    if (running == true) {
      _running = false;
      _timer?.cancel();
      _timer = null;
      final sf = stopFunc;
      if (sf != null && hasRun) {
        sf();
      }
      _hasRun = false;
    }
  }
}
