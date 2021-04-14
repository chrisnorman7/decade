/// Provides various mixins used by Decade.

/// Add a title to any object.
abstract class TitleMixin {
  /// The title of this object.
  String get title;

  @override
  String toString() => '<$runtimeType $title>';
}
