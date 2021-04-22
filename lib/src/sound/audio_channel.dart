/// Provides the [AudioChannel] class.
import 'dart:async';
import 'dart:io';

import 'package:dart_synthizer/dart_synthizer.dart';

import '../util.dart';
import 'audio_factory.dart';
import 'sound.dart';

/// A channel for playing sounds.
///
/// This class can be thought of like a channel on a mixer. It has optional
/// panning (provided by [PannedChannel] and [ThreeDChannel]), and can have fx
/// applied to it.
abstract class AudioChannel {
  /// Create a channel.
  AudioChannel(this.factory, this.source);

  /// The audio factory this channel is part of.
  AudioFactory factory;

  /// The audio source to play through.
  final Source source;

  /// The gain of this channel.
  double _gain = 1.0;

  /// Get the gain of this channel.
  double get gain {
    _checkValid();
    return _gain;
  }

  /// Set the gain.
  set gain(double value) {
    _checkValid();
    _gain = value;
    source.gain = value;
  }

  /// Change the gain slightly.
  void adjustGain(double amount) {
    var g = gain + amount;
    if (g > 1.0) {
      g = 1.0;
    }
    if (g < 0.0) {
      g = 0.0;
    }
    gain = g;
  }

  /// Whether or not this source has been destroyed.
  bool _destroyed = false;

  /// The sounds that have been created by this channel.
  final List<Sound> _sounds = [];

  /// Get the sounds that have been loaded onto this channel.
  ///
  /// This list cannot be modified.
  List<Sound> get sounds => List.from(_sounds);

  /// The reverb that has been applied to this channel.
  GlobalFdnReverb? _reverb;

  /// Get the reverb associated with this channel.
  GlobalFdnReverb? get reverb => _reverb;

  /// The echo that has been applied to this channel.
  GlobalEcho? _echo;

  /// Get the echo that has been connected to this channel.
  GlobalEcho? get echo => _echo;

  /// Destroy this channel, rendering it useless.
  void destroy() {
    _checkValid();
    _destroyed = true;
    _sounds
      ..forEach((element) => element.destroy())
      ..clear();
    source.destroy();
  }

  /// Throws an exception if [destroy] has been called on this instance.
  void _checkValid() {
    if (_destroyed) {
      throw Exception('This channel has been destroyed.');
    }
  }

  /// Create and return a sound from a generator.
  Sound loadGenerator(Generator generator) {
    final sound = Sound(this, generator);
    source.addGenerator(generator);
    _sounds.add(sound);
    return sound;
  }

  /// Load a sound from a filename.
  ///
  /// If [stream] is `true`, a [StreamingGenerator] will be used. Otherwise, a
  /// [BufferGenerator] will be used.
  Sound loadFile(FileSystemEntity path, {bool stream = false}) {
    if (path is Directory) {
      final contents = path.listSync();
      return loadFile(randomElement<FileSystemEntity>(contents) as File,
          stream: stream);
    } else if (path is File) {
      Generator generator;
      if (stream) {
        generator = factory.ctx.createStreamingGenerator('file', path.path);
      } else {
        final buffer = Buffer.fromFile(factory.synthizer, path);
        generator = factory.ctx.createBufferGenerator(buffer: buffer);
      }
      return loadGenerator(generator);
    } else {
      throw Exception('Invalid path: <${path.runtimeType}> $path.');
    }
  }

  /// Remove a sound from [sounds].
  void removeSound(Sound sound) => _sounds.remove(sound);

  /// Destroy a sound.
  ///
  /// This method calls [Sound.destroy] on [sound], and then removes it from
  /// [sounds] by way of [removeSound].
  void destroySound(Sound sound) {
    sound.destroy();
    removeSound(sound);
  }

  /// Connect a reverb send to this channel.
  ///
  /// At present, exactly 1 reverb can be added per channel.
  GlobalFdnReverb connectReverb(
      {GlobalFdnReverb? reverbObject,
      double sendLevel = 1.0,
      double fadeTime = 0.01,
      BiquadConfig? sendFilter}) {
    if (_reverb != null) {
      throw Exception('Only 1 reverb per channel.');
    }
    if (reverbObject == null) {
      reverbObject = factory.ctx.createGlobalFdnReverb();
    }
    factory.ctx.ConfigRoute(source, reverbObject,
        gain: sendLevel, fadeTime: fadeTime, filter: sendFilter);
    _reverb = reverbObject;
    return reverbObject;
  }

  /// Disconnect [reverb].
  ///
  /// This method does not destroy [reverb], as this would negate the
  /// usefulness of [fadeTime].
  ///
  /// If [reverb] is not `null`, it will be returned.
  ///
  /// If you wish to simply destroy [reverb], you can use the [destroyReverb]
  /// method.
  GlobalFdnReverb? disconnectReverb({double fadeTime = 0.01}) {
    final r = reverb;
    if (r != null) {
      factory.ctx.removeRoute(source, r, fadeTime: fadeTime);
      return r;
    }
    _reverb = null;
  }

  /// Destroy [reverb].
  void destroyReverb() {
    reverb?.destroy();
    _reverb = null;
  }

  /// Connect an echo send to this channel.
  ///
  /// At this time, exactly 1 echo can be added to a channel.
  GlobalEcho connectEcho(
      {GlobalEcho? echoObject,
      double sendLevel = 1.0,
      double fadeTime = 0.01,
      BiquadConfig? sendFilter}) {
    if (echo == null) {
      throw Exception('Only 1 echo can be added to a channel.');
    }
    if (echoObject == null) {
      echoObject = factory.ctx.createGlobalEcho();
    }
    factory.ctx.ConfigRoute(source, echoObject,
        gain: sendLevel, fadeTime: fadeTime, filter: sendFilter);
    _echo = echoObject;
    return echoObject;
  }

  /// Disconnect [echo].
  ///
  /// This method does not destroy [echo], as this would negate the
  /// usefulness of [fadeTime].
  ///
  /// If [echo] is not `null`, it will be returned.
  ///
  /// If you wish to simply destroy [echo], you can use the [destroyEcho]
  /// method.
  GlobalEcho? disconnectEcho({double fadeTime = 0.01}) {
    final e = echo;
    if (e != null) {
      factory.ctx.removeRoute(source, e, fadeTime: fadeTime);
      return e;
    }
    _echo = null;
  }

  /// Destroy [echo].
  void destroyEcho() {
    echo?.destroy();
    _echo = null;
  }

  /// Play a sound, and have it destroyed when it ends.
  Sound playSound(FileSystemEntity path) {
    if (path is Directory) {
      final contents = path.listSync();
      return playSound(randomElement<FileSystemEntity>(contents));
    } else if (path is File) {
      final buffer = Buffer.fromFile(factory.synthizer, path);
      final generator = factory.ctx.createBufferGenerator(buffer: buffer);
      final s = loadGenerator(generator);
      Timer(Duration(seconds: (buffer.lengthInSeconds + 1).floor()),
          () => destroySound(s));
      return s;
    } else {
      throw Exception('Invalid path: <${path.runtimeType}> $path.');
    }
  }
}

/// A channel with no panning.
///
/// This channel is not a mono channel, it simply cannot be panned.
class UnpannedChannel extends AudioChannel {
  /// Create a channel.
  UnpannedChannel(AudioFactory factory, DirectSource source)
      : super(factory, source);
}

/// A mixin used by [PannedChannel] and [ThreeDChannel].
mixin SpatializedChannel on AudioChannel {
  /// The position of this channel.
  Object get position;
}

/// A channel with a left and right balance.
class PannedChannel extends AudioChannel with SpatializedChannel {
  /// Create a channel.
  PannedChannel(AudioFactory factory, PannedSource source)
      : super(factory, source);

  double? _position = 0.0;

  /// Get the position of this channel.
  @override
  double get position {
    var p = _position;
    if (p == null) {
      p = (source as PannedSource).panningScalar;
      _position = p;
    }
    return p;
  }

  /// Set the position of this channel.
  set position(double value) {
    _position = value;
    (source as PannedSource).panningScalar = value;
  }
}

/// A channel which can be panned in 3d space.
class ThreeDChannel extends AudioChannel with SpatializedChannel {
  /// Create a channel.
  ThreeDChannel(AudioFactory factory, Source3D source) : super(factory, source);

  Double3? _position;

  /// Get the position.
  @override
  Double3 get position {
    var p = _position;
    if (p == null) {
      p = (source as Source3D).position;
      _position = p;
    }
    return p;
  }

  /// Set [position].
  set position(Double3 value) {
    _position = value;
    (source as Source3D).position = value;
  }
}
