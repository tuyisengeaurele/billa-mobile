import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/revenue_section.dart';
import '../widgets/summary_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);

    return Scaffold(
      body: RefreshIndicator(
        // Failures are swallowed here on purpose: each section already shows
        // its own error with a Retry, so the refresh indicator only needs to
        // know when loading has finished.
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(revenueProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future).then<void>((_) {}, onError: (_) {}),
            ref.read(revenueProvider.future).then<void>((_) {}, onError: (_) {}),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, media.padding.top + 12, 16, media.padding.bottom + 16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              SizedBox(height: 20),
              RevenueSection(),
              SizedBox(height: 24),
              SummarySection(),
            ],
          ),
        ),
      ),
    );
  }
}
