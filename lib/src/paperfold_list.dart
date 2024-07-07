import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:paperfold_list/paperfold_list.dart';
import 'package:vector_math/vector_math_64.dart';

/// # Paperfold List
///
/// A Flutter widget to make an expandable list view that folds in / out like
/// paper.
///
/// Laid out based on the `axis` (See [PaperfoldAxis]), the `itemExtent`
/// determines the fixed size of the list items.
///
/// `targetUnfold`, a value that ranges from `0` to `1` determines the
/// percentage of the list to be unfolded. When the widget mounts for the first
/// time, this value is used to determine the initial state of the list.
/// Subsequent updates smoothly animate the list to the new `targetUnfold` value
/// based on `animationDuration` (Default value: `250ms`) and `animationCurve`
/// (Default value: [Curves.linear]).
///
/// `perspective` is the value of the transformation matrix's `(3,2)` entry.
/// Typically, a small value like `0.001` works well to visualize 3D rotations.
///
/// `axis` not only determines the way the list is laid out but also the
/// direction in which the list grows.
///
/// * [PaperfoldAxis.horizontal] lists grow from `left` to `right`.
///
/// * [PaperfoldAxis.vertical] lists grow from `top` to `bottom`.
///
/// `effect` provides a way to incorporate additional decoration for each list
/// item based on the state of the list (Such as the current `unfold` value
/// being animated) and other properties. See [PaperfoldEffect].
///
/// When fully folded (ie. current `unfold` = `0`), `unmountOnFold` determines
/// if the `children` are rendered in the tree. To skip the rendering and
/// optimize, pass `unmountOnFold` = `true`. This will unmount the children when
/// the list is fully folded. However, their state will reset as they are
/// removed from the tree.
///
/// When the list folds, `interactionUnfoldThreshold` determines the point after
/// which, the `children` won't receive pointer events. When current `unfold` <
/// `interactionUnfoldThreshold`, the [IgnorePointer] will activate over the
/// `children` of the list. If `interactionUnfoldThreshold` is `null`, the
/// pointer events will never be ignored.
///
/// ## Constructors
///
/// * `PaperfoldList`: Creates a PaperfoldList using a list of widgets.
///
/// * `PaperfoldList.builder`: Creates a PaperfoldList using the builder
///   pattern.
/// ```
class PaperfoldList extends StatefulWidget {
  static const _defaultAnimationDuration = Duration(milliseconds: 250);
  static const _defaultAnimationCurve = Curves.linear;

  /// A value that ranges from `0` to `1` determines the percentage of the list
  /// to be unfolded. When the widget mounts for the first time, this value is
  /// used to determine the initial state of the list.
  ///
  /// Subsequent updates smoothly animate the list to the new `targetUnfold`.
  final double targetUnfold;

  /// The size occupied by the children of the list. It is defined as:
  ///
  /// * The `width` of every element when the `axis` is set to
  ///   [PaperfoldAxis.horizontal].
  ///
  /// * The `height` of every element when the `axis` is set to
  ///   [PaperfoldAxis.vertical].
  final double itemExtent;

  /// The axis along which the [PaperfoldList] widget is laid out.
  ///
  /// Default value: [PaperfoldAxis.vertical].
  final PaperfoldAxis axis;

  /// [PaperfoldList] places the children in a [Row] or [Column] based on the
  /// `axis`. This property controls the `mainAxisSize` property of the
  /// corresponding widget.
  ///
  /// * [PaperfoldAxisSize.min] corresponds to [MainAxisSize.min].
  ///
  /// * [PaperfoldAxisSize.max] corresponds to [MainAxisSize.max].
  ///
  /// Default value: [PaperfoldAxisSize.min].
  final PaperfoldAxisSize axisSize;

  /// [PaperfoldList] places the children in a [Row] or [Column] based on the
  /// `axis`. This property controls the `mainAxisAlignment` property of the
  /// corresponding widget.
  ///
  /// * [PaperfoldAxisAlignment.start] corresponds to [MainAxisAlignment.start].
  ///
  /// * [PaperfoldAxisAlignment.center] corresponds to
  ///   [MainAxisAlignment.center].
  ///
  /// * [PaperfoldAxisAlignment.end] corresponds to [MainAxisAlignment.end].
  ///
  /// Default value: [PaperfoldAxisAlignment.start].
  final PaperfoldAxisAlignment axisAlignment;

  /// The time taken to smoothly animate to the `targetUnfold` whenever the
  /// `targetUnfold` value changes.
  ///
  /// Default value: `250ms`.
  final Duration animationDuration;

  /// The animation curve used to smoothly animate to the `targetUnfold`
  /// whenever the `targetUnfold` value changes.
  ///
  /// Default value: [Curves.linear].
  final Curve animationCurve;

  /// The value of the transformation matrix's `(3,2)` entry. Typically, a small
  /// value like `0.001` works well to visualize 3D rotations.
  ///
  /// Default value: `0.001`.
  final double perspective;

  /// Determines wether the first child folds inward.
  ///
  /// The first child is the:
  ///
  /// * `leftmost` child when `axis` = [PaperfoldAxis.horizontal].
  ///
  /// * `topmost` child when `axis` = [PaperfoldAxis.vertical].
  ///
  /// Default value: `true`.
  final bool firstChildFoldsInward;

  /// When fully folded, this value determines if the `children` should be
  /// mounted. To unmount the children when fully folded, set this value to
  /// `true`. However, doing so will reset their state as they are removed from
  /// the tree.
  ///
  /// Default value: `false`.
  final bool unmountOnFold;

  /// When the list folds, this value specifies the point after which, the
  /// `children` won't receive pointer events. When currently animated `unfold`
  /// < `interactionUnfoldThreshold`, the [IgnorePointer] will activate over the
  /// `children`. If `interactionUnfoldThreshold` is `null`, the
  /// pointer events will never be ignored.
  ///
  /// Default value: `null`.
  final double? interactionUnfoldThreshold;

  /// Provides a way to incorporate additional decoration such as highlight and
  /// shadows for each list item based on the state of the list (Such as the
  /// current `unfold` value being animated) and other properties. See
  /// [PaperfoldEffect].
  ///
  /// Default value: [PaperfoldShadeEffect].
  final PaperfoldEffect? effect;

  /// The children of the list when PaperfoldList(...) constructor is used.
  ///
  /// `null` when PaperfoldList.builder(...) constructor is used.
  final List<Widget>? children;

  /// The number of children when PaperfoldList.builder(...) constructor is
  /// used.
  ///
  /// `null` when PaperfoldList(...) constructor is used.
  final int? itemCount;

  /// The builder responsible for building the children when
  /// PaperfoldList.builder(...) constructor is used.
  ///
  /// `null` when PaperfoldList(...) constructor is used.
  final IndexedWidgetBuilder? itemBuilder;

  /// Creates a [PaperfoldList] with fixed children.
  PaperfoldList({
    required this.itemExtent,
    required this.targetUnfold,
    required this.children,
    this.axis = PaperfoldAxis.vertical,
    this.axisSize = PaperfoldAxisSize.min,
    this.axisAlignment = PaperfoldAxisAlignment.start,
    this.animationDuration = _defaultAnimationDuration,
    this.animationCurve = _defaultAnimationCurve,
    this.perspective = 0.001,
    this.firstChildFoldsInward = true,
    this.unmountOnFold = false,
    this.interactionUnfoldThreshold,
    this.effect,
    super.key,
  })  : assert(
          targetUnfold >= 0 && targetUnfold <= 1,
          "targetUnfold must be within the inclusive range of 0 to 1.",
        ),
        assert(
          itemExtent > 0,
          "itemExtent must be a positive number greater than 0.",
        ),
        assert(
          children != null && children.isNotEmpty,
          "Atleast one child is required.",
        ),
        assert(
          interactionUnfoldThreshold == null ||
              (interactionUnfoldThreshold >= 0 && interactionUnfoldThreshold <= 1),
          "interactionUnfoldThreshold can either be null or must be within the inclusive range of 0 to 1.",
        ),
        itemCount = null,
        itemBuilder = null;

  /// Creates a [PaperfoldList] with builder pattern.
  const PaperfoldList.builder({
    required this.itemExtent,
    required this.targetUnfold,
    required this.itemCount,
    required this.itemBuilder,
    this.axis = PaperfoldAxis.vertical,
    this.axisSize = PaperfoldAxisSize.min,
    this.axisAlignment = PaperfoldAxisAlignment.start,
    this.animationDuration = _defaultAnimationDuration,
    this.animationCurve = _defaultAnimationCurve,
    this.perspective = 0.001,
    this.firstChildFoldsInward = true,
    this.unmountOnFold = false,
    this.interactionUnfoldThreshold,
    this.effect,
    super.key,
  })  : assert(
          targetUnfold >= 0 && targetUnfold <= 1,
          "targetUnfold must be within the inclusive range of 0 to 1.",
        ),
        assert(
          itemExtent > 0,
          "itemExtent must be a positive number greater than 0.",
        ),
        assert(
          itemCount != null && itemCount > 0,
          "itemCount is required and must be an integer > 0",
        ),
        assert(
          itemBuilder != null,
          "itemBuilder is required.",
        ),
        assert(
          interactionUnfoldThreshold == null ||
              (interactionUnfoldThreshold >= 0 && interactionUnfoldThreshold <= 1),
          "interactionUnfoldThreshold can either be null or must be within the inclusive range of 0 to 1.",
        ),
        children = null;

  @override
  State<PaperfoldList> createState() => PaperfoldListState();
}

/// The state of [PaperfoldList] widget.
class PaperfoldListState extends State<PaperfoldList> with SingleTickerProviderStateMixin {
  // Animates the unfold value to the `targetUnfold` whenever it changes.
  late AnimationController _unfoldAnimationController;
  // The [PaperfoldEffect] to use.
  late PaperfoldEffect _effect;

  @override
  void initState() {
    super.initState();
    // Initially set it to `targetUnfold`.
    _unfoldAnimationController = AnimationController(
      vsync: this,
      value: widget.targetUnfold,
    );
    // Use the default effect if `null`.
    _effect = widget.effect ?? PaperfoldShadeEffect();
  }

  @override
  void didUpdateWidget(covariant PaperfoldList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate if `targetUnfold` changes.
    if (oldWidget.targetUnfold != widget.targetUnfold) {
      _unfoldAnimationController.stop();
      _unfoldAnimationController
          .animateTo(widget.targetUnfold,
              duration: widget.animationDuration, curve: widget.animationCurve)
          .orCancel
          .catchError((_) {});
    }

    // Update the effect if changed.
    if (oldWidget.effect != widget.effect) {
      _effect = widget.effect ?? PaperfoldShadeEffect();
    }
  }

  @override
  void dispose() {
    _unfoldAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The parent layout based on the `axis`.
    switch (widget.axis) {
      case PaperfoldAxis.vertical:
        return Column(
          mainAxisSize: _flexSize,
          mainAxisAlignment: _flexAlignment,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        );
      case PaperfoldAxis.horizontal:
        return Row(
          mainAxisSize: _flexSize,
          mainAxisAlignment: _flexAlignment,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        );
    }
  }

  /// Converts the widget's [PaperfoldAxisSize] to corresponding [MainAxisSize].
  MainAxisSize get _flexSize {
    switch (widget.axisSize) {
      case PaperfoldAxisSize.min:
        return MainAxisSize.min;
      case PaperfoldAxisSize.max:
        return MainAxisSize.max;
    }
  }

  /// Converts the widget's [PaperfoldAxisAlignment] to corresponding
  /// [MainAxisAlignment].
  MainAxisAlignment get _flexAlignment {
    switch (widget.axisAlignment) {
      case PaperfoldAxisAlignment.start:
        return MainAxisAlignment.start;
      case PaperfoldAxisAlignment.center:
        return MainAxisAlignment.center;
      case PaperfoldAxisAlignment.end:
        return MainAxisAlignment.end;
    }
  }

  List<Widget> _buildChildren() {
    final isHorizontal = widget.axis == PaperfoldAxis.horizontal;
    final isVertical = !isHorizontal;
    final childCount = widget.children?.length ?? widget.itemCount!;

    return List.generate(childCount, (index) {
      // Check and assign wether the current child folds inward based on the
      // widget configuration.
      final foldsInward = index.isEven ^ !widget.firstChildFoldsInward;

      return AnimatedBuilder(
        animation: _unfoldAnimationController,
        builder: (context, child) {
          // The currently animated unfold value that animates to targetUnfold.
          final unfold = _unfoldAnimationController.value;

          // Don't mount children if fully folded and unmountOnFold is true.
          if (unfold == 0 && widget.unmountOnFold) {
            return const SizedBox.shrink();
          }

          // Calculate the alignment of the transform.
          final alignmentHorizontal = foldsInward ? Alignment.centerLeft : Alignment.centerRight;
          final alignmentVertical = foldsInward ? Alignment.topCenter : Alignment.bottomCenter;
          final alignment = isHorizontal ? alignmentHorizontal : alignmentVertical;

          // Calculate the rotation angle.
          final angle = (1 - unfold) * (pi / 2) * (foldsInward ? 1 : -1) * (isHorizontal ? -1 : 1);

          // Perspective Matrix4 with rotation applied.
          final perspectiveTransform = Matrix4.identity()..setEntry(3, 2, widget.perspective);
          if (isVertical) {
            perspectiveTransform.rotateX(angle);
          } else {
            perspectiveTransform.rotateY(angle);
          }

          // Calculate the orthographic size of the box wrapping the Transform
          // widget after applying the perspective transform.
          final transformedContainerVertex = perspectiveTransform.transform(
            Vector4(
              isHorizontal ? (foldsInward ? 1 : -1) * widget.itemExtent : 0.0,
              isVertical ? (foldsInward ? 1 : -1) * widget.itemExtent : 0.0,
              0.0,
              1.0,
            ),
          );
          final size = Size(
            isHorizontal
                ? transformedContainerVertex.x.abs() / transformedContainerVertex.w.abs()
                : double.infinity,
            isVertical
                ? transformedContainerVertex.y.abs() / transformedContainerVertex.w.abs()
                : double.infinity,
          );

          // The current widget state encapsulated as `info`.
          final info = PaperfoldInfo(
            index: index,
            itemCount: childCount,
            unfold: unfold,
            foldsInward: foldsInward,
            axis: widget.axis,
            itemExtent: widget.itemExtent,
          );

          // See if the pointers should be ignored based on the widget
          // configuration.
          final shouldIgnorePointers = widget.interactionUnfoldThreshold == null
              ? false
              : unfold < widget.interactionUnfoldThreshold!;

          return IgnorePointer(
            ignoring: shouldIgnorePointers,
            child: SizedBox.fromSize(
              size: size,
              child: UnconstrainedBox(
                clipBehavior: Clip.hardEdge,
                alignment: alignment,
                constrainedAxis: isHorizontal ? Axis.vertical : Axis.horizontal,
                child: SizedBox.fromSize(
                  size: isHorizontal
                      ? Size.fromWidth(widget.itemExtent)
                      : Size.fromHeight(widget.itemExtent),
                  child: Transform(
                    alignment: alignment,
                    transform: perspectiveTransform,
                    child: _effect.builder(
                      context,
                      info,
                      child!,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        // Use the `children` if normal constructor was used. Use `itemBuilder`
        // otherwise.
        child: widget.children?.elementAt(index) ?? widget.itemBuilder!(context, index),
      );
    });
  }
}
