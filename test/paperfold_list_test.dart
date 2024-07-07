import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperfold_list/paperfold_list.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  // Test 'itemExtent'.
  group(
    "'itemExtent' should limit the size of the children.",
    () {
      late Key firstChildKey;

      setUp(() {
        firstChildKey = const Key("first-child");
      });

      testWidgets(
        "For horizontal lists, 'itemExtent' should limit the width of the children.",
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: SizedBox(
                height: 100,
                child: PaperfoldList(
                  targetUnfold: 1.0,
                  itemExtent: 100,
                  axis: PaperfoldAxis.horizontal,
                  children: [Container(key: firstChildKey)],
                ),
              ),
            ),
          );

          final size = tester.getSize(find.byKey(firstChildKey));
          expect(size.width, equals(100.0));
        },
      );

      testWidgets("For vertical lists, 'itemExtent' should limit the height of the children.",
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 100,
              child: PaperfoldList(
                targetUnfold: 1.0,
                itemExtent: 100,
                axis: PaperfoldAxis.vertical,
                children: [Container(key: firstChildKey)],
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byKey(firstChildKey));
        expect(size.height, equals(100.0));
      });
    },
  );

  // Test 'targetUnfold' on mount.
  group(
    "'targetUnfold' should influence the size of the list.",
    () {
      late Key paperfoldListKey;

      setUp(() {
        paperfoldListKey = const Key("paperfold-list");
      });

      testWidgets(
        "When 'targetUnfold' is 0, the height of the list should be 0",
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PaperfoldList(
                  key: paperfoldListKey,
                  itemExtent: 100,
                  targetUnfold: 0,
                  axis: PaperfoldAxis.vertical,
                  children: [
                    Container(),
                    Container(),
                    Container(),
                  ],
                ),
              ),
            ),
          );

          final size = tester.getSize(find.byKey(paperfoldListKey));
          expect(size.height, moreOrLessEquals(0.0));
        },
      );

      testWidgets(
        "When 'targetUnfold' is 1, the height of the list should be equal to the combined height of the children",
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PaperfoldList(
                  key: paperfoldListKey,
                  itemExtent: 100,
                  targetUnfold: 1,
                  axis: PaperfoldAxis.vertical,
                  children: [
                    Container(),
                    Container(),
                    Container(),
                  ],
                ),
              ),
            ),
          );

          final size = tester.getSize(find.byKey(paperfoldListKey));
          expect(size.height, moreOrLessEquals(300));
        },
      );
    },
  );

  // Test 'unmountOnFold'.
  testWidgets(
    "When 'unmountOnFold' is true, the children get unmounted for fully folded list.",
    (tester) async {
      const onlyChildKey = Key("only-child");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaperfoldList(
              itemExtent: 100,
              targetUnfold: 0.0,
              unmountOnFold: true,
              children: [Container(key: onlyChildKey)],
            ),
          ),
        ),
      );

      expect(find.byKey(onlyChildKey), findsNothing);
    },
  );

  // Test 'alignment'.
  group(
    "'alignment' should position the list properly",
    () {
      late Key parentKey;
      late Key onlyChildKey;

      setUp(() {
        parentKey = const Key("parent");
        onlyChildKey = const Key("only-child");
      });

      testWidgets("Start alignment should position a vertical list on top.", (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.expand(
                key: parentKey,
                child: PaperfoldList(
                  itemExtent: 100,
                  targetUnfold: 1,
                  axisAlignment: PaperfoldAxisAlignment.start,
                  children: [Container(key: onlyChildKey)],
                ),
              ),
            ),
          ),
        );

        final childRect = tester.getRect(find.byKey(onlyChildKey));
        expect(childRect.top, equals(0.0));
      });

      testWidgets("Center alignment should position a vertical list in the center.",
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.expand(
                key: parentKey,
                child: PaperfoldList(
                  itemExtent: 100,
                  targetUnfold: 1,
                  axisAlignment: PaperfoldAxisAlignment.center,
                  children: [Container(key: onlyChildKey)],
                ),
              ),
            ),
          ),
        );

        final parentSize = tester.getSize(find.byKey(parentKey));
        final childRect = tester.getRect(find.byKey(onlyChildKey));

        expect(childRect.top, equals(parentSize.height / 2 - 50));
        expect(childRect.bottom, equals(parentSize.height / 2 + 50));
      });

      testWidgets("End alignment should position a vertical list at bottom.", (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.expand(
                key: parentKey,
                child: PaperfoldList(
                  itemExtent: 100,
                  targetUnfold: 1,
                  axisAlignment: PaperfoldAxisAlignment.end,
                  children: [Container(key: onlyChildKey)],
                ),
              ),
            ),
          ),
        );

        final parentSize = tester.getSize(find.byKey(parentKey));
        final childRect = tester.getRect(find.byKey(onlyChildKey));

        expect(childRect.bottom, equals(parentSize.height));
      });
    },
  );

  // Test 'firstFoldInwards'.
  group(
    "Setting 'firstChildFoldsInward' = false should fold the first child outside.",
    () {
      late Key firstChildKey;
      late Key secondChildKey;

      setUp(() {
        firstChildKey = const Key("first-child-key");
        secondChildKey = const Key("second-child-key");
      });

      testWidgets(
        "For horizontal list, setting 'firstChildFoldsInward' = false should fold the leftmost child outside and the next child inside.",
        (tester) async {
          await tester.pumpWidget(MaterialApp(
            home: SizedBox(
              height: 100,
              child: PaperfoldList(
                itemExtent: 100,
                targetUnfold: 0.5,
                firstChildFoldsInward: false,
                axis: PaperfoldAxis.horizontal,
                children: [
                  Container(key: firstChildKey),
                  Container(key: secondChildKey),
                ],
              ),
            ),
          ));

          final firstTransform = tester
              .widget<Transform>(
                find.ancestor(
                  of: find.byKey(firstChildKey),
                  matching: find.byType(Transform),
                ),
              )
              .transform;

          final expectedFirstTransform = Matrix3.rotationY(-pi / 4);
          expect(firstTransform.getRotation(), expectedFirstTransform);

          final secondTransform = tester
              .widget<Transform>(
                find.ancestor(
                  of: find.byKey(secondChildKey),
                  matching: find.byType(Transform),
                ),
              )
              .transform;

          final expectedSecondTransform = Matrix3.rotationY(pi / 4);
          expect(secondTransform.getRotation(), expectedSecondTransform);
        },
      );

      testWidgets(
        "For vertical list, setting 'firstChildFoldsInward' = false should fold the topmost child outside and the next child inside.",
        (tester) async {
          await tester.pumpWidget(MaterialApp(
            home: SizedBox(
              height: 100,
              child: PaperfoldList(
                itemExtent: 100,
                targetUnfold: 0.5,
                firstChildFoldsInward: false,
                axis: PaperfoldAxis.vertical,
                children: [
                  Container(key: firstChildKey),
                  Container(key: secondChildKey),
                ],
              ),
            ),
          ));

          final firstTransform = tester
              .widget<Transform>(
                find.ancestor(
                  of: find.byKey(firstChildKey),
                  matching: find.byType(Transform),
                ),
              )
              .transform;

          final expectedFirstTransform = Matrix3.rotationX(-pi / 4);
          expect(firstTransform.getRotation(), expectedFirstTransform);

          final secondTransform = tester
              .widget<Transform>(
                find.ancestor(
                  of: find.byKey(secondChildKey),
                  matching: find.byType(Transform),
                ),
              )
              .transform;

          final expectedSecondTransform = Matrix3.rotationX(pi / 4);
          expect(secondTransform.getRotation(), expectedSecondTransform);
        },
      );
    },
  );
}
