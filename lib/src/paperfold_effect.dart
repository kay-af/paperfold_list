import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:paperfold_list/paperfold_list.dart';

/// Signature for a function that creates a widget, decorated using [PaperfoldInfo],
/// which should wrap the provided `child`.
typedef PaperfoldEffectBuilder = Widget Function(
  BuildContext context,
  PaperfoldInfo info,
  Widget child,
);

/// Decorates each `child` within the [PaperfoldList] based on its current `state`.
abstract class PaperfoldEffect {
  /// The builder used to decorate the `children`.
  final PaperfoldEffectBuilder builder;

  /// Construct a [PaperfoldEffect] using the [PaperfoldEffectBuilder] provided.
  PaperfoldEffect({required this.builder});
}

/// A [PaperfoldEffect] that does not decorate any `child` within the [PaperfoldList].
class PaperfoldNoEffect extends PaperfoldEffect {
  /// Construct a [PaperfoldEffect] that does nothing to decorate the `child`.
  PaperfoldNoEffect() : super(builder: (context, info, child) => child);
}

/// A [PaperfoldEffect] that decorates each `child` within the [PaperfoldList] with
/// a background, highlight, and shadow. This is the default effect used in the
/// [PaperfoldList] widget.
class PaperfoldShadeEffect extends PaperfoldEffect {
  /// Constructs a [PaperfoldEffect] that decorates every `child` of the [PaperfoldList]
  /// using the following parameters:
  ///
  /// `backgroundColor` - Draws a surface with the specified color behind each child.
  /// A `null` value indicates no surface.
  ///
  /// `inwardOverlay` - Overlays a flat surface of the specified color on a child that folds
  /// inward. The overlay strengthens as the paper folds. It is useful for drawing
  /// shadows or highlights on a child that folds inward. A `null` value indicates
  /// no overlay.
  ///
  /// `outwardOverlay` - Overlays a flat surface of the given color on a child that folds
  /// outward. The overlay strengthens as the paper folds. It is useful for drawing
  /// shadows or highlights on a child that folds outward. A `null` value indicates
  /// no overlay.
  ///
  /// `inwardCrease` - Color of a gradient that starts from the inside crease and fades
  /// towards the outside. The gradient strengthens as the paper folds. The size of
  /// the gradient is determined by the `inwardCreaseSize`. A `null` value indicates no
  /// gradient.
  ///
  /// `inwardCreaseSize` - The size of the `inwardCrease` gradient represented as a fraction
  /// of `itemExtent` of [PaperfoldList]. This property is ignored if `inwardCrease` is
  /// `null`.
  ///
  /// `outwardCrease` - Color of a gradient that starts from the outside crease and fades
  /// towards the inside. The gradient strengthens as the paper folds. The size of
  /// the gradient is determined by the `outwardCreaseSize`. A `null` value indicates no
  /// gradient.
  ///
  /// `outwardCreaseSize` - The size of the `outwardCrease` gradient represented as a fraction
  /// of `itemExtent` of [PaperfoldList]. This property is ignored if `outwardCrease` is
  /// `null`.
  ///
  /// `drawInwardCreaseOnTop` - The inward crease is drawn after the outward crease.
  ///
  /// `preBuilder` - Optional builder to add custom effects after drawing the background
  /// before applying overlays and creases.
  ///
  /// `postBuilder` - Optional builder to add custom effects after applying the shade
  /// effects.
  PaperfoldShadeEffect({
    final Color? backgroundColor = const Color(0xFFF8F4F0),
    final Color? inwardOverlay = const Color(0x240C0404),
    final Color? outwardOverlay,
    final Color? inwardCrease = const Color(0x420C0404),
    final double inwardCreaseSize = 0.75,
    final Color? outwardCrease = const Color(0x42F5F5F5),
    final double outwardCreaseSize = 0.25,
    final bool drawInwardCreaseOnTop = false,
    final PaperfoldEffectBuilder? preBuilder,
    final PaperfoldEffectBuilder? postBuilder,
  })  : assert(
          inwardCreaseSize >= 0 && inwardCreaseSize <= 1,
          "inCreaseSize must be represented as a fraction (0 to 1) of the itemExtent passed in PaperfoldList widget",
        ),
        assert(
          outwardCreaseSize >= 0 && inwardCreaseSize <= 1,
          "outCreaseSize must be represented as a fraction (0 to 1) of the itemExtent passed in PaperfoldList widget",
        ),
        super(builder: (context, info, child) {
          final surfacedChild = _optionallyDrawBackground(
            color: backgroundColor,
            child: child,
          );

          final shadedChild = _optionallyDrawCreases(
            inwardCrease: inwardCrease,
            outwardCrease: outwardCrease,
            inwardCreaseSize: inwardCreaseSize,
            outwardCreaseSize: outwardCreaseSize,
            drawInwardCreaseOnTop: drawInwardCreaseOnTop,
            info: info,
            child: _optionallyDrawOverlay(
              overlay: info.foldsInward ? inwardOverlay : null,
              info: info,
              child: _optionallyDrawOverlay(
                overlay: !info.foldsInward ? outwardOverlay : null,
                info: info,
                child:
                    preBuilder != null ? preBuilder(context, info, surfacedChild) : surfacedChild,
              ),
            ),
          );

          return postBuilder != null ? postBuilder(context, info, shadedChild) : shadedChild;
        });

  /// Flips an alignment centered on the edge of a box.
  static Alignment _flipAlignment(Alignment alignment) {
    return alignment * -1;
  }

  /// Calculates the starting alignment of a gradient to be applied on the crease.
  static Alignment _computeCreaseBeginAlignment({
    required bool isInwardCrease,
    required PaperfoldInfo info,
  }) {
    final axis = info.axis;
    final foldsInward = info.foldsInward;
    final inCreaseAlignment = axis == PaperfoldAxis.horizontal
        ? (foldsInward ? Alignment.centerRight : Alignment.centerLeft)
        : (foldsInward ? Alignment.bottomCenter : Alignment.topCenter);
    if (!isInwardCrease) {
      return _flipAlignment(inCreaseAlignment);
    }
    return inCreaseAlignment;
  }

  /// Calculates the ending alignment of a gradient to be applied on the crease.
  static Alignment _computeCreaseEndAlignment({
    required bool isInwardCrease,
    required PaperfoldInfo info,
    required double size,
  }) {
    final begin = _computeCreaseBeginAlignment(
      isInwardCrease: isInwardCrease,
      info: info,
    );
    final end = _flipAlignment(begin);
    return Alignment.lerp(begin, end, size)!;
  }

  /// Overlays the given child with the crease gradients
  static Widget _optionallyDrawCreases({
    required Color? inwardCrease,
    required double inwardCreaseSize,
    required Color? outwardCrease,
    required double outwardCreaseSize,
    required bool drawInwardCreaseOnTop,
    required PaperfoldInfo info,
    required Widget child,
  }) {
    // Render no crease if not provided.
    if (inwardCrease == null && outwardCrease == null) return child;

    final inward = inwardCrease == null
        ? null
        : Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(inwardCrease.withOpacity(0), inwardCrease, 1 - info.unfold)!,
                    inwardCrease.withOpacity(0),
                  ],
                  begin: _computeCreaseBeginAlignment(
                    isInwardCrease: true,
                    info: info,
                  ),
                  end: _computeCreaseEndAlignment(
                    isInwardCrease: true,
                    info: info,
                    size: inwardCreaseSize,
                  ),
                ),
              ),
            ),
          );

    final outward = outwardCrease == null
        ? null
        : Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(outwardCrease.withOpacity(0), outwardCrease, 1 - info.unfold)!,
                    outwardCrease.withOpacity(0),
                  ],
                  begin: _computeCreaseBeginAlignment(
                    isInwardCrease: false,
                    info: info,
                  ),
                  end: _computeCreaseEndAlignment(
                    isInwardCrease: false,
                    info: info,
                    size: outwardCreaseSize,
                  ),
                ),
              ),
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (drawInwardCreaseOnTop) ...[
          if (outward != null) outward,
          if (inward != null) inward,
        ],
        if (!drawInwardCreaseOnTop) ...[
          if (inward != null) inward,
          if (outward != null) outward,
        ],
      ],
    );
  }

  /// Overlay a shadow or a highlight over the child.
  static Widget _optionallyDrawOverlay({
    required Color? overlay,
    required PaperfoldInfo info,
    required Widget child,
  }) {
    // Render no overlay if not provided.
    if (overlay == null) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Color.lerp(overlay.withOpacity(0), overlay, 1 - info.unfold)!,
        BlendMode.srcATop,
      ),
      child: child,
    );
  }

  /// Draw the background surface for the child.
  static Widget _optionallyDrawBackground({Color? color, required Widget child}) {
    // Render no surface if not provided.
    if (color == null) return child;
    return Container(
      color: color,
      child: child,
    );
  }
}

/// A [PaperfoldEffect] that decorates each `child` within the [PaperfoldList] with
/// a custom effect builder.
class PaperfoldListCustomEffect extends PaperfoldEffect {
  /// Constructs a [PaperfoldEffect] that decorates every `child` of the [PaperfoldList]
  /// using a custom effect builder.
  ///
  /// See [PaperfoldShadeEffect] for a preset effect.
  PaperfoldListCustomEffect({required super.builder});
}
