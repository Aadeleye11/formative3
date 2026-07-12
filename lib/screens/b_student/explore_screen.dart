import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'opportunity_details_screen.dart';

const _categoryOptions = [
  'Design',
  'Engineering',
  'Marketing',
  'Data',
  'Content',
  'Research',
];
const _commitmentLabels = ['≤5h', '5–10h', '10h+'];
const _locationOptions = ['Remote', 'On-campus', 'Hybrid'];
const _compensationOptions = ['Unpaid', 'Stipend', 'Equity', 'Credit'];
const _sortLabels = ['Newest', 'Best match', 'Ending soon'];
const _trending = [
  (Symbols.bar_chart_rounded, 'Data Analyst'),
  (Symbols.videocam_rounded, 'Video Editing'),
  (Symbols.eco_rounded, 'Agritech'),
];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _recentSearches = ['Flutter Developer', 'UX Research', 'Data Analyst'];

  String _search = '';
  Set<String> _categories = {};
  int _commitmentIndex = -1;
  Set<String> _locations = {};
  Set<String> _compensations = {};
  int _sortIndex = 0;
  List<Opportunity> _liveOpportunities = [];
  StreamSubscription<List<Opportunity>>? _liveSub;

  List<Opportunity> get _allOpportunities => [
    ..._liveOpportunities,
    ...Fixtures.opportunities,
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _liveSub = MarketplaceRepository.instance.watchLiveOpportunities().listen((
      items,
    ) {
      if (mounted) setState(() => _liveOpportunities = items);
    });
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSaved(Opportunity o) {
    setState(() => o.saved = !o.saved);
    if (o.isLive) {
      MarketplaceRepository.instance.toggleSaved(o, o.saved);
    }
  }

  bool get _hasActiveFilters =>
      _search.trim().isNotEmpty ||
      _categories.isNotEmpty ||
      _commitmentIndex != -1 ||
      _locations.isNotEmpty ||
      _compensations.isNotEmpty;

  List<Opportunity> _matchesFor(
    Set<String> categories,
    int commitmentIndex,
    Set<String> locations,
    Set<String> compensations,
  ) {
    final q = _search.trim().toLowerCase();
    return _allOpportunities.where((o) {
      if (q.isNotEmpty) {
        final haystack = '${o.title} ${o.startup.name} ${o.category}'
            .toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      if (categories.isNotEmpty && !categories.contains(o.category)) {
        return false;
      }
      if (commitmentIndex != -1 &&
          _commitmentBucket(o.commitment) !=
              _commitmentLabels[commitmentIndex]) {
        return false;
      }
      if (locations.isNotEmpty &&
          !locations.any(
            (l) => o.location.toLowerCase().contains(l.toLowerCase()),
          )) {
        return false;
      }
      if (compensations.isNotEmpty &&
          !compensations.any(
            (c) => o.compensation.toLowerCase().contains(c.toLowerCase()),
          )) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Opportunity> get _filtered {
    final list = _matchesFor(
      _categories,
      _commitmentIndex,
      _locations,
      _compensations,
    );
    list.sort(_comparator);
    return list;
  }

  int _comparator(Opportunity a, Opportunity b) {
    switch (_sortIndex) {
      case 1:
        return b.matchPercent.compareTo(a.matchPercent);
      case 2:
        return _closingDays(
          a.closesLabel,
        ).compareTo(_closingDays(b.closesLabel));
      default:
        return _recencyDays(
          a.postedLabel,
        ).compareTo(_recencyDays(b.postedLabel));
    }
  }

  void _applySearchTerm(String term) {
    _searchCtrl.text = term;
    _searchCtrl.selection = TextSelection.collapsed(offset: term.length);
    setState(() => _search = term);
  }

  void _resetAllFilters() {
    setState(() {
      _searchCtrl.clear();
      _search = '';
      _categories = {};
      _commitmentIndex = -1;
      _locations = {};
      _compensations = {};
    });
  }

  void _openFilterSheet() {
    var tempCategories = Set<String>.of(_categories);
    var tempCommitment = _commitmentIndex;
    var tempLocations = Set<String>.of(_locations);
    var tempCompensations = Set<String>.of(_compensations);
    var tempSort = _sortIndex;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final count = _matchesFor(
              tempCategories,
              tempCommitment,
              tempLocations,
              tempCompensations,
            ).length;
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.hairline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextLinkButton(
                        label: 'Reset',
                        onPressed: () => setSheetState(() {
                          tempCategories = {};
                          tempCommitment = -1;
                          tempLocations = {};
                          tempCompensations = {};
                          tempSort = 0;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _sheetLabel('CATEGORY'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categoryOptions
                                .map(
                                  (c) => SelectableChip.tint(
                                    label: c,
                                    selected: tempCategories.contains(c),
                                    onTap: () => setSheetState(() {
                                      if (tempCategories.contains(c)) {
                                        tempCategories.remove(c);
                                      } else {
                                        tempCategories.add(c);
                                      }
                                    }),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 22),
                          _sheetLabel('COMMITMENT'),
                          const SizedBox(height: 10),
                          AppSegmentedControl(
                            labels: _commitmentLabels,
                            index: tempCommitment,
                            onChanged: (i) => setSheetState(
                              () =>
                                  tempCommitment = tempCommitment == i ? -1 : i,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sheetLabel('LOCATION'),
                                    const SizedBox(height: 10),
                                    ..._locationOptions.map(
                                      (l) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: SelectableChip.tint(
                                          label: l,
                                          selected: tempLocations.contains(l),
                                          onTap: () => setSheetState(() {
                                            if (tempLocations.contains(l)) {
                                              tempLocations.remove(l);
                                            } else {
                                              tempLocations.add(l);
                                            }
                                          }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sheetLabel('COMPENSATION'),
                                    const SizedBox(height: 10),
                                    ..._compensationOptions.map(
                                      (c) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: SelectableChip.tint(
                                          label: c,
                                          selected: tempCompensations.contains(
                                            c,
                                          ),
                                          onTap: () => setSheetState(() {
                                            if (tempCompensations.contains(c)) {
                                              tempCompensations.remove(c);
                                            } else {
                                              tempCompensations.add(c);
                                            }
                                          }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _sheetLabel('SORT BY'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              _sortLabels.length,
                              (i) => SelectableChip(
                                label: _sortLabels[i],
                                selected: tempSort == i,
                                onTap: () => setSheetState(() => tempSort = i),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Show $count results',
                    onPressed: () {
                      setState(() {
                        _categories = tempCategories;
                        _commitmentIndex = tempCommitment;
                        _locations = tempLocations;
                        _compensations = tempCompensations;
                        _sortIndex = tempSort;
                      });
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetLabel(String text) => Text(
    text,
    style: AppText.caption.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 11.5,
      letterSpacing: 0.4,
    ),
  );

  Widget _searchInput() {
    final focused = _searchFocusNode.hasFocus;
    return Container(
      height: AppShape.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: focused ? Colors.white : AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppShape.inputRadius),
        border: focused
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        boxShadow: focused ? AppShape.cardShadow : null,
      ),
      child: Row(
        children: [
          Icon(
            Symbols.search_rounded,
            size: 20,
            color: focused ? AppColors.primary : AppColors.inkSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocusNode,
              onChanged: (v) => setState(() => _search = v),
              style: AppText.body.copyWith(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Search roles, startups, skills…',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          if (_search.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() {
                _searchCtrl.clear();
                _search = '';
              }),
              child: const Icon(
                Symbols.close_rounded,
                size: 18,
                color: AppColors.inkFaint,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tuneButton() {
    return GestureDetector(
      onTap: _openFilterSheet,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShape.ctaShadow(AppColors.primary),
        ),
        child: const Icon(Symbols.tune_rounded, color: Colors.white),
      ),
    );
  }

  Widget _recentSearchesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent searches',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final term in _recentSearches)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _applySearchTerm(term),
                      child: Row(
                        children: [
                          const Icon(
                            Symbols.history_rounded,
                            size: 18,
                            color: AppColors.inkSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              term,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _recentSearches.remove(term)),
                    child: const Icon(
                      Symbols.close_rounded,
                      size: 16,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _trendingSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending on campus',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending
                .map(
                  (t) => GestureDetector(
                    onTap: () => _applySearchTerm(t.$2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppShape.pill),
                        boxShadow: AppShape.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.$1, size: 15, color: AppColors.inkSecondary),
                          const SizedBox(width: 6),
                          Text(
                            t.$2,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _activeFilterChips() {
    final chips = <Widget>[];
    if (_search.trim().isNotEmpty) {
      final term = _search.trim();
      chips.add(
        _FilterTag(
          label: '"$term"',
          onRemove: () => setState(() {
            _searchCtrl.clear();
            _search = '';
          }),
        ),
      );
    }
    for (final c in _categories) {
      chips.add(
        _FilterTag(
          label: c,
          onRemove: () => setState(() => _categories.remove(c)),
        ),
      );
    }
    if (_commitmentIndex != -1) {
      chips.add(
        _FilterTag(
          label: _commitmentLabels[_commitmentIndex],
          onRemove: () => setState(() => _commitmentIndex = -1),
        ),
      );
    }
    for (final l in _locations) {
      chips.add(
        _FilterTag(
          label: l,
          onRemove: () => setState(() => _locations.remove(l)),
        ),
      );
    }
    for (final c in _compensations) {
      chips.add(
        _FilterTag(
          label: c,
          onRemove: () => setState(() => _compensations.remove(c)),
        ),
      );
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final discovery = !_hasActiveFilters;
    final showEmpty = list.isEmpty && _hasActiveFilters;
    final showNothingPostedYet = list.isEmpty && discovery;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Explore',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(child: _searchInput()),
                const SizedBox(width: 10),
                _tuneButton(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (discovery) _recentSearchesSection(),
                if (discovery) _trendingSection(),
                if (!discovery)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _activeFilterChips(),
                    ),
                  ),
                if (showEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: EmptyStateView(
                      icon: Symbols.search_off_rounded,
                      title: 'No matches yet',
                      subtitle:
                          'Try clearing a filter — pick whichever one is most limiting.',
                      ctaLabel: 'Reset all filters',
                      onCta: _resetAllFilters,
                    ),
                  )
                else if (showNothingPostedYet)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: EmptyStateView(
                      icon: Symbols.description_rounded,
                      title: 'No opportunities posted yet',
                      subtitle:
                          'Once a startup posts a role, it shows up here for every student to browse.',
                    ),
                  )
                else ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      discovery ? 22 : 14,
                      20,
                      10,
                    ),
                    child: Text(
                      discovery
                          ? 'Browse all opportunities'
                          : '${list.length} ${list.length == 1 ? 'result' : 'results'}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final o in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OpportunityListCard(
                              opportunity: o,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OpportunityDetailsScreen(opportunity: o),
                                ),
                              ),
                              onBookmarkTap: () => _toggleSaved(o),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterTag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentTint,
          borderRadius: BorderRadius.circular(AppShape.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppText.chipLabel.copyWith(
                fontSize: 11.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Symbols.close_rounded,
              size: 13,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

String _commitmentBucket(String commitment) {
  final numbers = RegExp(
    r'\d+',
  ).allMatches(commitment).map((m) => int.parse(m.group(0)!)).toList();
  final hours = numbers.isEmpty ? 0 : numbers.last;
  if (hours <= 5) return _commitmentLabels[0];
  if (hours <= 10) return _commitmentLabels[1];
  return _commitmentLabels[2];
}

int _recencyDays(String label) {
  final match = RegExp(
    r'(\d+)\s*(days?|weeks?|months?|hours?|hrs?|mins?|d\b)',
  ).firstMatch(label.toLowerCase());
  if (match == null) return 0;
  final n = int.parse(match.group(1)!);
  final unit = match.group(2)!;
  if (unit.startsWith('week')) return n * 7;
  if (unit.startsWith('month')) return n * 30;
  if (unit.startsWith('hour') || unit.startsWith('hr')) return 0;
  if (unit.startsWith('min')) return 0;
  return n;
}

int _closingDays(String label) {
  final match = RegExp(r'\d+').firstMatch(label);
  if (match == null) return 1 << 30;
  return int.parse(match.group(0)!);
}
