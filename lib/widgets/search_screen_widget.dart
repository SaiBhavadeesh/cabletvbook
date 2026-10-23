import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:cableTvBook/widgets/app_svg_icon.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:cableTvBook/theme/app_colors.dart';

class SearchScreenWidget extends StatefulWidget {
  final bool all;
  final bool pending;
  final bool active;
  final bool credits;
  final bool inactive;
  final String? areaId;

  const SearchScreenWidget({
    super.key,
    this.all = false,
    this.pending = false,
    this.credits = false,
    this.active = false,
    this.inactive = false,
    this.areaId,
  });

  @override
  _SearchScreenWidgetState createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget>
    with AutomaticKeepAliveClientMixin {
  static const int _pageSize = 25;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<DocumentSnapshot> _rawDocs = [];
  List<Customer> _allLoadedCustomers = [];
  List<Customer> _filteredCustomers = [];

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Query _buildBaseQuery() {
    final op = operatorDetails;
    if (op == null) throw Exception('Operator information unavailable');

    Query collection = FirebaseFirestore.instance
        .collection('users/${op.id}/customers');

    if (widget.areaId != null && widget.areaId!.isNotEmpty) {
      collection = collection.where('areaId', isEqualTo: widget.areaId);
    }
    if (widget.active) {
      collection = collection.where('curSts', isEqualTo: 'Active');
    } else if (widget.inactive) {
      collection = collection.where('curSts', isEqualTo: 'Inactive');
    }
    return collection;
  }

  List<Customer> _parseCustomers(List<DocumentSnapshot> docs) {
    final parsed = docs
        .where((d) => d.data() != null)
        .map((d) => Customer.fromMap(d.data() as Map<String, dynamic>))
        .toList();

    return getSelectedCustomers(
      all: widget.all,
      pending: widget.pending,
      credits: widget.credits,
      active: widget.active,
      inactive: widget.inactive,
      providedCustomers: parsed,
    );
  }

  void _applySearchFilter(String query) {
    final trimmed = query.toLowerCase().trim();
    if (trimmed.isEmpty) {
      _filteredCustomers = List.from(_allLoadedCustomers);
    } else {
      _filteredCustomers = _allLoadedCustomers
          .where((customer) =>
              customer.name.toLowerCase().contains(trimmed) ||
              customer.accountNumber.toLowerCase().contains(trimmed) ||
              customer.macId.toLowerCase().contains(trimmed) ||
              customer.phoneNumber.contains(trimmed))
          .toList();
    }
  }

  Future<void> _fetchFirstPage() async {
    if (!mounted) return;
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _hasMore = true;
      _rawDocs.clear();
      _allLoadedCustomers.clear();
      _filteredCustomers.clear();
    });

    try {
      final query = _buildBaseQuery().limit(_pageSize);
      final snapshot = await query.get();

      final newCustomers = _parseCustomers(snapshot.docs);

      if (mounted) {
        setState(() {
          _rawDocs = snapshot.docs;
          _allLoadedCustomers = newCustomers;
          _applySearchFilter(_searchController.text);
          _hasMore = snapshot.docs.length >= _pageSize;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _rawDocs.isEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      final query = _buildBaseQuery()
          .startAfterDocument(_rawDocs.last)
          .limit(_pageSize);
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final newCustomers = _parseCustomers(snapshot.docs);

        if (mounted) {
          setState(() {
            _rawDocs.addAll(snapshot.docs);
            _allLoadedCustomers.addAll(newCustomers);
            _applySearchFilter(_searchController.text);
            _hasMore = snapshot.docs.length >= _pageSize;
          });
        }
      } else {
        if (mounted) setState(() => _hasMore = false);
      }
    } catch (_) {
      // Keep existing data on error
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200 && !_isLoadingMore && _hasMore) {
      _fetchNextPage();
    }
  }

  void _onTextChange(String value) {
    setState(() {
      _applySearchFilter(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final op = operatorDetails;
    if (op == null) {
      return const Center(child: Text('Operator information unavailable'));
    }

    if (_isInitialLoading) {
      return Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: const [AppColors.primary],
          ),
        ),
      );
    }

    if (_errorMessage != null && _allLoadedCustomers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load subscribers: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchFirstPage,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Modern Search Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onTextChange,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search by name, phone, account #, or MAC...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onTextChange('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),

        // Subheader count & action row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_filteredCustomers.length}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${_filteredCustomers.length == 1 ? 'subscriber' : 'subscribers'} found',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Filtered by "${_searchController.text.trim()}"',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AddCustomerScreen.routeName),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFEF3C7),
                          Color(0xFFFDE68A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB45309)
                              .withValues(alpha: 0.14),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppSvgIcon(
                          AppSvgIconType.addCustomer,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Add Customer',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Customer List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchFirstPage,
            child: _filteredCustomers.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_search_rounded,
                                size: 40,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Subscribers Found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No matches for "${_searchController.text}". Try another query.'
                                  : 'No subscriber records in this category.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Scrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100, top: 4),
                      itemCount: _filteredCustomers.length +
                          (_isLoadingMore ? 1 : 0),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index >= _filteredCustomers.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }

                        return CustomerTile(
                          customer: _filteredCustomers[index],
                          index: index,
                          onCustomerDeleted: _fetchFirstPage,
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
