/// Provides the [Sound] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import 'audio_channel.dart';

/// A sound which can be played.
class Sound {
  /// Create a sound.
  ///
  /// This method is normally called by [AudioChannel.playSound] or
  /// [AudioChannel.loadFile].
  Sound(this.channel, this.generator);

  /// The channel this sound is part of.
  final AudioChannel channel;

  /// The generator which will produce audio.
  final Generator generator;

  /// The gain of this sound.
  double? _gain;

  /// The the gain of this sound.
  double get gain {
    var g = _gain;
    if (g == null) {
      g = generator.gain;
      _gain = g;
    }
    return g;
  }

  /// Set [gain].
  set gain(double value) {
    _gain = value;
    generator.gain = value;
  }

  /// Whether or not this source has been destroyed.
  bool _destroyed = false;

  /// Destroy this sound.
  void destroy() {
    if (_destroyed == false) {
      generator.destroy();
      _destroyed = true;
    }
  }
}
