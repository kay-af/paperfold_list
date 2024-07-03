import 'package:paperfold_list/paperfold_list.dart';

/// Stores information about the state of a [PaperfoldList] and properties that
/// can be used to decorate using effects or render its children.
class PaperfoldInfo {
  /// Index of the child to be decorated or rendered.
  int index;

  /// The number of children contained in the list.
  int itemCount;

  /// Indicates the amount of list `unfolded`.
  ///
  /// `0` - the list is fully folded.
  ///
  /// `1` - the list is fully unfolded.
  double unfold;

  /// Indicates if the current child is set to fold inside starting from the `left`
  /// or `top` for [PaperfoldAxis.horizontal] or [PaperfoldAxis.vertical] axes respectively.
  bool foldsInward;

  /// The axis along which the [PaperfoldList] widget is laid out.
  PaperfoldAxis axis;

  /// Constructs an instance to store the data representing the state of [PaperfoldList].
  PaperfoldInfo({
    required this.index,
    required this.itemCount,
    required this.unfold,
    required this.foldsInward,
    required this.axis,
  });
}
