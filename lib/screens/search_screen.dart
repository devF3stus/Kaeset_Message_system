import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/font_size_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/search_bar.dart';
import '../widgets/transaction_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Transactions',
          style: TextStyle(
            fontSize: fontProvider.scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (txProvider.searchQuery.isNotEmpty || txProvider.filterType != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset Filters',
              onPressed: () => txProvider.clearSearch(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header Container
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.scaffoldBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSearchBar(showFilters: true),
                const SizedBox(height: 12),

                // Search Results Counter & Sort Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        txProvider.searchQuery.isEmpty
                            ? 'Showing ${txProvider.searchResults.length} transactions'
                            : 'Found ${txProvider.searchResults.length} results for "${txProvider.searchQuery}"',
                        style: TextStyle(
                          fontSize: fontProvider.scale(13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort menu
                    PopupMenuButton<String>(
                      initialValue: txProvider.sortBy,
                      tooltip: 'Sort Options',
                      onSelected: (val) => txProvider.setSortBy(val),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sort_rounded, size: fontProvider.scale(16), color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _getSortLabel(txProvider.sortBy),
                              style: TextStyle(
                                fontSize: fontProvider.scale(12),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, size: fontProvider.scale(16), color: AppColors.primary),
                          ],
                        ),
                      ),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'date_desc', child: Text('Date: Newest First')),
                        const PopupMenuItem(value: 'date_asc', child: Text('Date: Oldest First')),
                        const PopupMenuItem(value: 'amount_desc', child: Text('Amount: Highest First')),
                        const PopupMenuItem(value: 'amount_asc', child: Text('Amount: Lowest First')),
                        const PopupMenuItem(value: 'name_asc', child: Text('Customer Name: A - Z')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Search Results List
          Expanded(
            child: txProvider.searchResults.isEmpty
                ? _buildNoResults(context, fontProvider, txProvider)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: txProvider.searchResults.length,
                    itemBuilder: (ctx, index) {
                      final tx = txProvider.searchResults[index];
                      return TransactionCard(transaction: tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'date_asc':
        return 'Oldest';
      case 'amount_desc':
        return 'Highest';
      case 'amount_asc':
        return 'Lowest';
      case 'name_asc':
        return 'Name A-Z';
      case 'date_desc':
      default:
        return 'Newest';
    }
  }

  Widget _buildNoResults(
    BuildContext context,
    FontSizeProvider fontProvider,
    TransactionProvider txProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: fontProvider.scale(64),
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Transactions Match',
              style: TextStyle(
                fontSize: fontProvider.scale(18),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              txProvider.searchQuery.isNotEmpty
                  ? 'No results found for "${txProvider.searchQuery}". Try checking for spelling errors or clearing filters.'
                  : 'No transactions found with the active filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontProvider.scale(13),
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (txProvider.searchQuery.isNotEmpty || txProvider.filterType != null)
              OutlinedButton.icon(
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear All Filters'),
                onPressed: () => txProvider.clearSearch(),
              ),
          ],
        ),
      ),
    );
  }
}
