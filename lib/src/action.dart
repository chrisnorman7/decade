/// Provides various action classes.
library action;

import 'dart:async';

import 'package:flutter/services.dart';

import 'mixins.dart';
import 'typedefs.dart';

/// A class which represents a keyboard key.
///
/// Instances of this class can be used to ensure only certain keys trigger an
/// [Action].
class Hotkey {
  /// Create a hotkey.
  const Hotkey(this.physicalKey, {this.controlKey, this.altKey, this.shiftKey});

  /// The flutter key which defines this hotkey.
  final PhysicalKeyboardKey physicalKey;

  /// Which control key(s) need to be pressed for this hotkey to work.
  final KeyboardSide? controlKey;

  /// Which shift key(s) need to be pressed for this hotkey to work.
  final KeyboardSide? shiftKey;

  /// Which alt key(s) need to be pressed for this hotkey to work.
  final KeyboardSide? altKey;

  /// Match a modifier key.
  bool _matchModifier(KeyboardSide? expected, KeyboardSide? actual) =>
      (actual == expected) ||
      (actual == null && expected == null) ||
      (actual != null && expected == KeyboardSide.any);

  /// Returns `true` if [eventData] matches this hotkey.
  bool matches(RawKeyEventData eventData) {
    if (eventData.physicalKey != physicalKey) {
      return false;
    }
    // Now check modifiers.
    return _matchModifier(controlKey,
            eventData.getModifierSide(ModifierKey.controlModifier)) &&
        _matchModifier(
            shiftKey, eventData.getModifierSide(ModifierKey.shiftModifier)) &&
        _matchModifier(
            altKey, eventData.getModifierSide(ModifierKey.altModifier));
  }

  /// Print a string representation of this hotkey.
  @override
  String toString() {
    final List<String> keys = [];
    switch (controlKey) {
      case KeyboardSide.any:
        keys.add('CTRL');
        break;
      case KeyboardSide.left:
        keys.add('LCTRL');
        break;
      case KeyboardSide.right:
        keys.add('RCTRL');
        break;
      case KeyboardSide.all:
        keys.add('CTRLS');
        break;
      case null:
        break;
    }
    switch (altKey) {
      case KeyboardSide.any:
        keys.add('ALT');
        break;
      case KeyboardSide.left:
        keys.add('LALT');
        break;
      case KeyboardSide.right:
        keys.add('RALT');
        break;
      case KeyboardSide.all:
        keys.add('ALTS');
        break;
      case null:
        break;
    }
    switch (shiftKey) {
      case KeyboardSide.any:
        keys.add('SHIFT');
        break;
      case KeyboardSide.left:
        keys.add('LSHIFT');
        break;
      case KeyboardSide.right:
        keys.add('RSHIFT');
        break;
      case KeyboardSide.all:
        keys.add('SHIFTs');
        break;
      case null:
        break;
    }
    keys.add(physicalKey.debugName ?? '<UNKNOWN>');
    return keys.join('+');
  }
}

/// An action which can be called.
///
/// Actions can be triggered by the inclusion of a [Hotkey], and can be
/// given an [Action.interval], to ensure they run on a schedule.
class Action extends TitleMixin {
  /// Create an action.
  Action(this.title, this.hotkey,
      {this.triggerFunc, this.spamFunc, this.stopFunc, this.interval});

  /// The title of this action.
  @override
  final String title;

  /// The hotkey which must be used to trigger this action.
  final Hotkey hotkey;

  /// The function which will be called when this action is triggered or
  /// started.
  final ActionCallback? triggerFunc;

  /// The function which will be called when spamming this command.
  ///
  /// For this function to mean something, [interval] must not be `null`.
  final ActionCallback? spamFunc;

  /// The function which will be called when this action is stopped.
  final ActionCallback? stopFunc;

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
    if (running == false) {
      _running = true;
      final i = interval;
      _hasRun = false;
      run();
      if (i != null) {
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

  /// Return a string representation of this object.
  @override
  String toString() => '$title: $hotkey';
}
