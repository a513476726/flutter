// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

class TestFlowDelegate extends FlowDelegate {
  TestFlowDelegate({
    Animation<double> startOffset
  }) : startOffset = startOffset, super(repaint: startOffset);

  final Animation<double> startOffset;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dy = startOffset.value;
    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i, transform: new Matrix4.translationValues(0.0, dy, 0.0));
      dy += 0.75 * context.getChildSize(i).height;
    }
  }

  @override
  bool shouldRepaint(TestFlowDelegate oldDelegate) => startOffset == oldDelegate.startOffset;
}

void main() {
  testWidgets('Flow control test', (WidgetTester tester) {
    AnimationController startOffset = new AnimationController.unbounded();
    List<int> log = <int>[];

    Widget buildBox(int i) {
      return new GestureDetector(
        onTap: () {
          log.add(i);
        },
        child: new Container(
          width: 100.0,
          height: 100.0,
          decoration: const BoxDecoration(
            backgroundColor: const Color(0xFF0000FF)
          ),
          child: new Text('$i')
        )
      );
    }

    tester.pumpWidget(
      new Flow(
        delegate: new TestFlowDelegate(startOffset: startOffset),
        children: <Widget>[
          buildBox(0),
          buildBox(1),
          buildBox(2),
          buildBox(3),
          buildBox(4),
          buildBox(5),
          buildBox(6),
        ]
      )
    );

    tester.tap(find.text('0'));
    expect(log, equals([0]));
    tester.tap(find.text('1'));
    expect(log, equals([0, 1]));
    tester.tap(find.text('2'));
    expect(log, equals([0, 1, 2]));

    log.clear();
    tester.tapAt(new Point(20.0, 90.0));
    expect(log, equals([1]));

    startOffset.value = 50.0;
    tester.pump();

    log.clear();
    tester.tapAt(new Point(20.0, 90.0));
    expect(log, equals([0]));
  });
}
