import 'package:flutter/material.dart';
import 'loading_skeleton.dart';

/// Placeholder rows shaped like list tiles, pinned to the top where the real
/// rows will appear. It scrolls so pull-to-refresh still works while loading.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  LoadingSkeleton(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(22))),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoadingSkeleton(width: 160, height: 14),
                        SizedBox(height: 8),
                        LoadingSkeleton(width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
