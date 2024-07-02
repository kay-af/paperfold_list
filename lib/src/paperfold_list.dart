import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:paperfold_list/paperfold_list.dart';
import 'package:vector_math/vector_math_64.dart';

typedef PaperfoldListItemBuilder = Widget Function(
  BuildContext context,
  PaperfoldInfo info,
);

class PaperfoldList extends StatefulWidget {
  static const _defaultAnimationDuration = Duration(milliseconds: 350);
  static const _defaultAnimationCurve = Curves.linear;

  final double unfold;
  final double itemExtent;
  final PaperfoldAxis axis;
  final Duration animationDuration;
  final Curve animationCurve;
  final double perspective;
  final bool firstFoldOutside;
  final PaperfoldEffect? effect;

  final List<Widget>? children;
  final int? itemCount;
  final PaperfoldListItemBuilder? itemBuilder;

  PaperfoldList({
    required this.itemExtent,
    required this.unfold,
    required this.children,
    this.axis = PaperfoldAxis.vertical,
    this.animationDuration = _defaultAnimationDuration,
    this.animationCurve = _defaultAnimationCurve,
    this.perspective = 0.001,
    this.firstFoldOutside = false,
    this.effect,
    super.key,
  })  : assert(unfold >= 0 && unfold <= 1),
        assert(itemExtent > 0),
        assert(children != null && children.isNotEmpty),
        itemCount = null,
        itemBuilder = null;

  const PaperfoldList.builder({
    required this.itemExtent,
    required this.unfold,
    required this.itemCount,
    required this.itemBuilder,
    this.axis = PaperfoldAxis.vertical,
    this.animationDuration = _defaultAnimationDuration,
    this.animationCurve = _defaultAnimationCurve,
    this.perspective = 0.001,
    this.firstFoldOutside = false,
    this.effect,
    super.key,
  })  : assert(unfold >= 0 && unfold <= 1),
        assert(itemExtent > 0),
        assert(itemCount != null && itemCount > 0),
        assert(itemBuilder != null),
        children = null;

  @override
  State<PaperfoldList> createState() => PaperfoldListState();
}

class PaperfoldListState extends State<PaperfoldList> with SingleTickerProviderStateMixin {
  late AnimationController _unfoldAnimationController;
  late PaperfoldEffect _effect;

  @override
  void initState() {
    super.initState();
    _unfoldAnimationController = AnimationController(
      vsync: this,
      value: widget.unfold,
    );
    _effect = widget.effect ?? PaperfoldShadeEffect();
  }

  @override
  void didUpdateWidget(covariant PaperfoldList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.unfold != widget.unfold) {
      _unfoldAnimationController.stop();
      _unfoldAnimationController
          .animateTo(widget.unfold,
              duration: widget.animationDuration, curve: widget.animationCurve)
          .orCancel
          .catchError((_) {});
    }

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
    switch (widget.axis) {
      case PaperfoldAxis.vertical:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        );
      case PaperfoldAxis.horizontal:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        );
    }
  }

  List<Widget> _buildChildren() {
    final isHorizontal = widget.axis == PaperfoldAxis.horizontal;
    final isVertical = !isHorizontal;
    final childCount = widget.children?.length ?? widget.itemCount!;

    return List.generate(childCount, (index) {
      final foldInside = index.isEven ^ widget.firstFoldOutside;

      return AnimatedBuilder(
        animation: _unfoldAnimationController,
        builder: (context, child) {
          final unfold = _unfoldAnimationController.value;
          final alignmentHorizontal = foldInside ? Alignment.centerLeft : Alignment.centerRight;
          final alignmentVertical = foldInside ? Alignment.topCenter : Alignment.bottomCenter;
          final alignment = isHorizontal ? alignmentHorizontal : alignmentVertical;

          final angle = (1 - unfold) * (pi / 2) * (foldInside ? 1 : -1) * (isHorizontal ? -1 : 1);

          final perspectiveTransform = Matrix4.identity()..setEntry(3, 2, widget.perspective);

          if (isVertical) {
            perspectiveTransform.rotateX(angle);
          } else {
            perspectiveTransform.rotateY(angle);
          }

          final transformedContainerVertex = perspectiveTransform.transform(
            Vector4(
              isHorizontal ? (foldInside ? 1 : -1) * widget.itemExtent : 0.0,
              isVertical ? (foldInside ? 1 : -1) * widget.itemExtent : 0.0,
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

          final info = PaperfoldInfo(
            index: index,
            itemCount: childCount,
            unfold: unfold,
            foldsIn: foldInside,
            axis: widget.axis,
          );

          return SizedBox.fromSize(
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
                    child ?? widget.itemBuilder!(context, info),
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.children?.elementAt(index),
      );
    });
  }
}
