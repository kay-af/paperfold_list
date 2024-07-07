import 'package:paperfold_list/paperfold_list.dart';

/// Controls the list position inside the parent.
///
/// * When using [PaperfoldAxis.horizontal] the alignment corresponds to left,
///   center, and right just like the `mainAxisAlignment` of a `Row`.
///
/// * When using [PaperfoldAxis.vertical] the alignment corresponds to top,
///   center, and bottom just like the `mainAxisAlignment` of a `Column`.
enum PaperfoldAlignment {
  /// Align the items to the start of the parent.
  start,

  /// Align the items to the center of the parent.
  center,

  /// Align the items to the end of the parent.
  end,
}
