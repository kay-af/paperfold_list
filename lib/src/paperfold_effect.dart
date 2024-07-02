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
/// a background, highlights, and shadows. This is the default effect used in the
/// [PaperfoldList] widget.
class PaperfoldShadeEffect extends PaperfoldEffect {
  /// Constructs a [PaperfoldEffect] that decorates every `child` of the [PaperfoldList]
  /// using the following parameters:
  ///
  /// `backgroundColor` - Provides a surface of the same color behind every child.
  /// A `null` value indicates no surface.
  ///
  /// `inOverlay` - Overlays a flat surface of the given color on a child that folds
  /// inside. The overlay strengthens as the paper folds. It is useful for drawing
  /// shadows or highlights on a child that folds inside. A `null` value indicates
  /// no overlay.
  ///
  /// `outOverlay` - Overlays a flat surface of the given color on a child that folds
  /// outside. The overlay strengthens as the paper folds. It is useful for drawing
  /// shadows or highlights on a child that folds outside. A `null` value indicates
  /// no overlay.
  ///
  /// `inCrease` - Color of a gradient that starts from the inside crease and fades
  /// towards the outside. The gradient strengthens as the paper folds. The size of
  /// the gradient is determined by the `inCreaseSize`. A `null` value indicates no
  /// gradient.
  ///
  /// `inCreaseSize` - The size of the `inCrease` gradient represented as a fraction
  /// of `itemExtent` of [PaperfoldList]. This property is ignored if `inCrease` is
  /// `null`.
  ///
  /// `outCrease` - Color of a gradient that starts from the outside crease and fades
  /// towards the inside. The gradient strengthens as the paper folds. The size of
  /// the gradient is determined by the `outCreaseSize`. A `null` value indicates no
  /// gradient.
  ///
  /// `outCreaseSize` - The size of the `outCrease` gradient represented as a fraction
  /// of `itemExtent` of [PaperfoldList]. This property is ignored if `outCrease` is
  /// `null`.
  PaperfoldShadeEffect({
    final Color? backgroundColor = const Color(0xFFF8F4F0),
    final Color? inOverlay = const Color(0x240C0404),
    final Color? outOverlay,
    final Color? inCrease = const Color(0x420C0404),
    final double inCreaseSize = 0.75,
    final Color? outCrease = const Color(0x42F5F5F5),
    final double outCreaseSize = 0.25,
  })  : assert(
          inCreaseSize >= 0 && inCreaseSize <= 1,
          "inCreaseSize must be represented as a fraction (0 to 1) of the itemExtent passed in PaperfoldList widget",
        ),
        assert(
          outCreaseSize >= 0 && inCreaseSize <= 1,
          "outCreaseSize must be represented as a fraction (0 to 1) of the itemExtent passed in PaperfoldList widget",
        ),
        super(builder: (context, info, child) {
          return _optionallyDrawCreases(
            inCrease: inCrease,
            outCrease: outCrease,
            inCreaseSize: inCreaseSize,
            outCreaseSize: outCreaseSize,
            info: info,
            child: _optionallyDrawOverlay(
              overlay: info.foldsIn ? inOverlay : null,
              info: info,
              child: _optionallyDrawOverlay(
                overlay: !info.foldsIn ? outOverlay : null,
                info: info,
                child: _optionallyDrawBackground(
                  color: backgroundColor,
                  child: child,
                ),
              ),
            ),
          );
        });

  /// Flips an alignment centered on the edge of a box.
  static Alignment _flipAlignment(Alignment alignment) {
    return alignment * -1;
  }

  /// Calculates the starting alignment of a gradient to be applied on the crease.
  static Alignment _computeCreaseBeginAlignment({
    required bool inCrease,
    required PaperfoldInfo info,
  }) {
    final axis = info.axis;
    final foldInside = info.foldsIn;
    final inCreaseAlignment = axis == PaperfoldAxis.horizontal
        ? (foldInside ? Alignment.centerRight : Alignment.centerLeft)
        : (foldInside ? Alignment.bottomCenter : Alignment.topCenter);
    if (!inCrease) {
      return _flipAlignment(inCreaseAlignment);
    }
    return inCreaseAlignment;
  }

  /// Calculates the ending alignment of a gradient to be applied on the crease.
  static Alignment _computeCreaseEndAlignment({
    required bool inCrease,
    required PaperfoldInfo info,
    required double size,
  }) {
    final begin = _computeCreaseBeginAlignment(
      inCrease: inCrease,
      info: info,
    );
    final end = _flipAlignment(begin);
    return Alignment.lerp(begin, end, size)!;
  }

  /// Overlays the given child with the crease gradients
  static Widget _optionallyDrawCreases({
    required Color? inCrease,
    required double inCreaseSize,
    required Color? outCrease,
    required double outCreaseSize,
    required PaperfoldInfo info,
    required Widget child,
  }) {
    // Render no crease if not provided.
    if (inCrease == null && outCrease == null) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // Render the crease facing inside.
        if (inCrease != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(inCrease.withOpacity(0), inCrease, 1 - info.unfold)!,
                    inCrease.withOpacity(0),
                  ],
                  begin: _computeCreaseBeginAlignment(
                    inCrease: true,
                    info: info,
                  ),
                  end: _computeCreaseEndAlignment(
                    inCrease: true,
                    info: info,
                    size: inCreaseSize,
                  ),
                ),
              ),
            ),
          ),
        // Render the crease facing outside.
        if (outCrease != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(outCrease.withOpacity(0), outCrease, 1 - info.unfold)!,
                    outCrease.withOpacity(0),
                  ],
                  begin: _computeCreaseBeginAlignment(
                    inCrease: false,
                    info: info,
                  ),
                  end: _computeCreaseEndAlignment(
                    inCrease: false,
                    info: info,
                    size: outCreaseSize,
                  ),
                ),
              ),
            ),
          ),
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
