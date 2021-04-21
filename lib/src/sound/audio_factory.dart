/// Provides the [AudioFactory] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import 'audio_channel.dart';

/// The main class for controlling audio.
///
/// You must call [AudioFactory.init] before sending audio.]
class AudioFactory {
  /// Create an audio factory.
  AudioFactory(this.synthizer);

  /// The Synthizer instance to use.
  final Synthizer synthizer;

  /// The audio context to play through.
  Context? _ctx;

  /// Raises an error if [initialised] is `false`.
  Context get ctx {
    final c = _ctx;
    if (c == null) {
      throw Exception('Not yet initialised.');
    }
    return c;
  }

  /// The gain of this factory.
  double? _gain;

  /// Get the master volume.
  double get gain {
    var v = _gain;
    if (v == null) {
      v = ctx.gain;
      _gain = v;
    }
    return v;
  }

  /// Set the master volume.
  set gain(double value) {
    _gain = value;
    ctx.gain = value;
  }

  /// The orientation of this factory.
  Double6? _orientation;

  /// Get the current orientation of this factory.
  Double6 get orientation {
    var v = _orientation;
    if (v == null) {
      v = ctx.orientation;
      _orientation = v;
    }
    return v;
  }

  /// All the channels that are loaded to this factory.
  final List<AudioChannel> _channels = [];

  /// get the channels that have been created by this factory.
  ///
  /// It will be impossible to modify this list.
  List<AudioChannel> get channels => List.from(_channels);

  /// Create a context.
  ///
  /// This method also calls [Synthizer.initialize], so you don't have to.
  void init() {
    _ctx = synthizer.createContext();
  }

  /// Returns `true` if this factory has not yet been initialised.
  bool get initialised => _ctx != null;

  /// Destroy this factory.
  ///
  /// This method also destroys all the channels it has created.
  ///
  /// If you want to use this factory again, you will first need to call the
  /// [init] method.
  void destroy() {
    _channels
      ..forEach((element) => element.destroy())
      ..clear();
    ctx.destroy();
    _ctx = null;
  }

  /// Create an unpanned source.
  UnpannedChannel createUnpannedChannel() {
    final channel = UnpannedChannel(this, ctx.createDirectSource());
    _channels.add(channel);
    return channel;
  }

  /// Create a panned channel.
  PannedChannel createPannedChannel() {
    final channel = PannedChannel(this, ctx.createPannedSource());
    _channels.add(channel);
    return channel;
  }

  /// Create a 3d channel.
  ThreeDChannel createThreeDChannel() {
    final channel = ThreeDChannel(this, ctx.createSource3D());
    _channels.add(channel);
    return channel;
  }
}
