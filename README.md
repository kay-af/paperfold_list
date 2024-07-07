# Paperfold List

<a href="https://pub.dev/packages/paperfold_list"><img src="https://img.shields.io/badge/pub-1.0.0-blue" alt="pub.dev" /></a>
<a href="https://github.com/kay-af/paperfold_list/actions"><img src="https://github.com/kay-af/paperfold_list/actions/workflows/test.yml/badge.svg" /></a>
<a href="https://opensource.org/license/MIT"><img src="https://img.shields.io/badge/license-MIT-yellow" alt="pub.dev" /></a>

Inspired by [PaperfoldJs](https://www.felixniklas.com/paperfold/).

Paperfold List is a Flutter widget that creates an expandable list view that folds in and out like paper. This widget allows for a visually appealing and interactive list experience, with customizable animations and effects.

![Preview](https://raw.githubusercontent.com/kay-af/paperfold_list/main/preview/example.gif)

## Features

- Expandable list view with a folding paper effect.
- Support for both horizontal and vertical list orientations.
- Smooth & Customizable animations for unfolding and folding the list.

## Example Usage

### Main Widget

Paperfold list can be created like this:

```dart
PaperfoldList(
  itemExtent: 100,
  targetUnfold: 0.5,
  axis: PaperfoldAxis.vertical,
  axisSize: PaperfoldAxisSize.min,
  axisAlignment: PaperfoldAxisAlignment.start,
  animationDuration: const Duration(milliseconds: 500),
  animationCurve: Curves.ease,
  perspective: 0.0015,
  firstChildFoldsInward: true,
  unmountOnFold: true,
  interactionUnfoldThreshold: 1.0,
  effect: PaperfoldShadeEffect(),
  children: const [
    Text("First"),
    Text("Second"),
    Text("Third"),
  ],
)
```

If you want to use a builder pattern, you can instantiate the list like this:

```dart
PaperfoldList.builder(
  itemExtent: 100,
  targetUnfold: 0.5,
  itemCount: 3,
  itemBuilder: (context, index) => Text("Child $index"),
)
```

Check out the [PaperfoldList](https://pub.dev/documentation/paperfold_list/1.0.0/paperfold_list/PaperfoldList-class) documentation for complete information about the parameters.

### Effects

The [PaperfoldEffect](https://pub.dev/documentation/paperfold_list/1.0.0/paperfold_list/PaperfoldEffect-class) class provides a way to include additional effects by wrapping each child with a widget to draw effects over them based on the amount of the list folded and other properties.

There are three types of Effects provided:

- **PaperfoldNoEffect**: Does nothing to decorate the children.

  Example:

  ```dart
  PaperfoldList(
    effect: PaperfoldNoEffect(),
  )
  ```

- **PaperfoldShadeEffect**: The default effect used when not mentioned. This is a preset effect that contains various options to quickly include some shading effects.

  Example:

  ```dart
  PaperfoldList(
    effect: PaperfoldShadeEffect(
      backgroundColor: Colors.white,
      inwardOverlay: Colors.black54,
      inwardCrease: Colors.black12,
    ),
  )
  ```

  Check out the [PaperfoldShadeEffect](https://pub.dev/documentation/paperfold_list/1.0.0/paperfold_list/PaperfoldShadeEffect-class) documentation for complete information about the parameters.

- **PaperfoldListCustomEffect**: Define your own `PaperfoldEffectBuilder` to achieve a fully custom effect.

  Example effect to fade children as the list folds:

  ```dart
  PaperfoldList(
    effect: PaperfoldListCustomEffect(
      builder: (context, info, child) {
        return Opacity(
          opacity: info.unfold,
          child: child,
        );
      }
    ),
  )
  ```

## Issues

Facing issues? Raise them on [Github](https://github.com/kay-af/paperfold_list/issues).
