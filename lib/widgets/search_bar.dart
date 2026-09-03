import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/font_size_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class AppSearchBar extends StatefulWidget {
  final bool showFilters;
  final VoidCallback? onTap;
  final bool readOnly;

  const AppSearchBar({
    super.key,
    this.showFilters = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    _controller = TextEditingController(text: txProvider.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);

    // Keep controller text synchronized if cleared from provider
    if (_controller.text != txProvider.searchQuery && !widget.readOnly) {
      _controller.text = txProvider.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: (val) {
              txProvider.setSearchQuery(val);
            },
            style: TextStyle(
              fontSize: fontProvider.scale(15),
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search by customer name or code...',
              hintStyle: TextStyle(
                fontSize: fontProvider.scale(14),
                color: AppColors.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: fontProvider.scale(22),
              ),
              suffixIcon: _controller.text.isNotEmpty && !widget.readOnly
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.textSecondary,
                        size: fontProvider.scale(20),
                      ),
                      onPressed: () {
                        _controller.clear();
                        txProvider.clearSearch();
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Filter chips (All, Received, Sent)
        if (widget.showFilters) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  context,
                  label: 'All',
                  isSelected: txProvider.filterType == null,
                  onSelected: () => txProvider.setFilterType(null),
                  fontProvider: fontProvider,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  context,
                  label: '📥 Received',
                  isSelected: txProvider.filterType == TransactionType.received,
                  selectedColor: AppColors.received,
                  onSelected: () => txProvider.setFilterType(TransactionType.received),
                  fontProvider: fontProvider,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  context,
                  label: '📤 Sent',
                  isSelected: txProvider.filterType == TransactionType.sent,
                  selectedColor: AppColors.sent,
                  onSelected: () => txProvider.setFilterType(TransactionType.sent),
                  fontProvider: fontProvider,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required FontSizeProvider fontProvider,
    Color? selectedColor,
  }) {
    final activeColor = selectedColor ?? AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.parse(
            isSelected
                ? 'border: 1.5px solid $activeColor'
                : 'border: 1px solid ${AppColors.divider}',
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontProvider.scale(13),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
