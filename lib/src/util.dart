/// Provides various utility functions.
import 'dart:math';

/// A random number generator.
final rng = Random();

/// Get a random element from a list.
T randomElement<T>(List<T> elements) {
  final i = rng.nextInt(elements.length);
  return elements[i];
}
