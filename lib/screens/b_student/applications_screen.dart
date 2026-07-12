import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../widgets/widgets.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  int tab = 0;

  List<Application> _filtered(List<Application> live) {
    final all = [...live, ...Fixtures.applications];
    return switch (tab) {
      1 =>
        all
            .where(
              (a) =>
                  a.status == ApplicationStatus.applied ||
                  a.status == ApplicationStatus.reviewing,
            )
            .toList(),
      2 => all.where((a) => a.status == ApplicationStatus.interview).toList(),
      3 =>
        all
            .where(
              (a) =>
                  a.status == ApplicationStatus.accepted ||
                  a.status == ApplicationStatus.shortlisted,
            )
            .toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Application>>(
      stream: MarketplaceRepository.instance.watchMyApplications(),
      builder: (context, snapshot) {
        final list = _filtered(snapshot.data ?? const []);
        return _build(context, list);
      },
    );
  }

  Widget _build(BuildContext context, List<Application> list) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Applications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppSegmentedControl(
              labels: const ['All', 'Applied', 'Interview', 'Accepted'],
              index: tab,
              onChanged: (i) => setState(() => tab = i),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: EmptyStateView(
                      icon: Symbols.work_history_rounded,
                      title: 'No applications yet',
                      subtitle:
                          'Find a role you like and your applications will live here — from Applied to Accepted.',
                      ctaLabel: 'Explore opportunities',
                      onCta: () => Navigator.of(context).pop(),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => ApplicationCard(
                      application: list[i],
                      onTap: () => Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ApplicationDetailScreen(application: list[i]),
                            ),
                          )
                          .then((_) => setState(() {})),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
