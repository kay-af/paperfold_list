import 'package:flutter/widgets.dart';
import 'package:paperfold_list/paperfold_list.dart';

typedef PaperfoldListEffectBuilder = Widget Function(
  BuildContext context,
  PaperfoldListItemInfo info,
  Widget child,
);

abstract class PaperfoldListEffect {
  final PaperfoldListEffectBuilder builder;

  PaperfoldListEffect({required this.builder});
}

class PaperfoldListNoEffect extends PaperfoldListEffect {
  PaperfoldListNoEffect() : super(builder: (context, info, child) => child);
}

class PaperfoldListShadeEffect extends PaperfoldListEffect {
  PaperfoldListShadeEffect({
    final Color? backgroundColor = const Color(0xFFF8F4F0),
    final Color? inOverlay = const Color(0x240C0404),
    final Color? outOverlay,
    final Color? inCrease = const Color(0x420C0404),
    final double inCreaseSize = 0.75,
    final Color? outCrease = const Color(0x42F5F5F5),
    final double outCreaseSize = 0.25,
  })  : assert(inCreaseSize >= 0 && inCreaseSize <= 1),
        assert(outCreaseSize >= 0 && inCreaseSize <= 1),
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

  static Alignment _flipAlignment(Alignment alignment) {
    return alignment * -1;
  }

  static Alignment _computeCreaseBeginAlignment({
    required bool inCrease,
    required PaperfoldListItemInfo info,
  }) {
    final axis = info.axis;
    final foldInside = info.foldsIn;
    final inCreaseAlignment = axis == PaperfoldListAxis.horizontal
        ? (foldInside ? Alignment.centerRight : Alignment.centerLeft)
        : (foldInside ? Alignment.bottomCenter : Alignment.topCenter);
    if (!inCrease) {
      return _flipAlignment(inCreaseAlignment);
    }
    return inCreaseAlignment;
  }

  static Alignment _computeCreaseEndAlignment({
    required bool inCrease,
    required PaperfoldListItemInfo info,
    required double size,
  }) {
    final begin = _computeCreaseBeginAlignment(
      inCrease: inCrease,
      info: info,
    );
    final end = _flipAlignment(begin);
    return Alignment.lerp(begin, end, size)!;
  }

  static Widget _optionallyDrawCreases({
    required Color? inCrease,
    required double inCreaseSize,
    required Color? outCrease,
    required double outCreaseSize,
    required PaperfoldListItemInfo info,
    required Widget child,
  }) {
    if (inCrease == null && outCrease == null) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
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
      ],
    );
  }

  static Widget _optionallyDrawOverlay({
    required Color? overlay,
    required PaperfoldListItemInfo info,
    required Widget child,
  }) {
    if (overlay == null) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Color.lerp(overlay.withOpacity(0), overlay, 1 - info.unfold)!,
        BlendMode.srcATop,
      ),
      child: child,
    );
  }

  static Widget _optionallyDrawBackground({Color? color, required Widget child}) {
    if (color == null) return child;
    return Container(
      color: color,
      child: child,
    );
  }
}

class PaperfoldListCustomEffect extends PaperfoldListEffect {
  PaperfoldListCustomEffect({required super.builder});
}
