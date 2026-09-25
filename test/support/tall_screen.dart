import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A tall viewport so long forms lay out fully. Filled fields are taller than
/// the old outlined ones, and a scrolling list only builds what is on screen,
/// so buttons near the bottom would otherwise not exist to be tapped.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
