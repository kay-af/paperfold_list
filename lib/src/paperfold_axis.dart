import 'package:flutter/widgets.dart';
import 'package:paperfold_list/paperfold_list.dart';
import 'package:paperfold_list/src/paperfold_list.dart';

/// The axis along which the [PaperfoldList] widget is laid out.
enum PaperfoldAxis {
  /// The [PaperfoldList] is laid out from `left` to `right`.
  horizontal,

  /// The [PaperfoldList] is laid out from `top` to `bottom`.
  vertical,
}

/// Controls the `mainAxisSize` of the [Row] or [Column] widget used to layout
/// the children of the [PaperfoldList].
///
/// * [PaperfoldAxisSize.min] corresponds to [MainAxisSize.min].
///
/// * [PaperfoldAxisSize.max] corresponds to [MainAxisSize.max].
enum PaperfoldAxisSize {
  /// Takes up the minimum space required.
  min,

  /// Takes up all the available space.
  max,
}

/// Controls the `mainAxisAlignment` of the [Row] or [Column] widget used to
/// layout the children of the [PaperfoldList].
///
/// * When using [PaperfoldAxis.horizontal] the alignment corresponds to left,
///   center, and right just like the `mainAxisAlignment` of a [Row].
///
/// * When using [PaperfoldAxis.vertical] the alignment corresponds to top,
///   center, and bottom just like the `mainAxisAlignment` of a [Column].
enum PaperfoldAxisAlignment {
  /// Align the items to the start.
  start,

  /// Align the items to the center.
  center,

  /// Align the items to the end.
  end,
}
