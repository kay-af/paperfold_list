import 'package:paperfold_list/paperfold_list.dart';

/// Stores information about the state of a [PaperfoldList] and properties that
/// can be used to decorate the `children`.
class PaperfoldInfo {
  /// Index of the child to be decorated or rendered.
  final int index;

  /// The number of children contained in the [PaperfoldList].
  final int itemCount;

  /// Indicates the amount of the [PaperfoldList] currently unfolded.
  ///
  /// * `0`: The list is fully folded.
  ///
  /// * `1`: The list is fully unfolded.
  final double unfold;

  /// Indicates wether the current child is set to fold inwards starting from
  /// the `left` for [PaperfoldAxis.horizontal] or `top` for
  /// [PaperfoldAxis.vertical].
  final bool foldsInward;

  /// The axis along which the [PaperfoldList] widget is laid out.
  final PaperfoldAxis axis;

  /// The extent of each item of a [PaperfoldList].
  ///
  /// * `width` when `axis` = [PaperfoldAxis.horizontal]
  ///
  /// * `height` when `axis` = [PaperfoldAxis.vertical]
  final double itemExtent;

  /// Creates a [PaperfoldInfo] that store the data representing the state of
  /// [PaperfoldList] and properties of the `child` to be decorated or rendered.
  PaperfoldInfo({
    required this.index,
    required this.itemCount,
    required this.unfold,
    required this.foldsInward,
    required this.axis,
    required this.itemExtent,
  });
}
