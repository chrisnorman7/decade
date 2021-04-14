/// Provides various typedefs for use with the engine.
library typedefs;

import 'action.dart';
import 'level.dart';

/// A function which will be called with a [DecadeLevel] instance as its first
/// argument.
typedef DecadeLevelCallback = Function(DecadeLevel);

/// The callback type for [DecadeAction] functions.
typedef DecadeActionCallback = Function();
