import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/font_size_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';
import '../widgets/transaction_card.dart';
import 'about_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);

    final List<Widget> screens = [
      const _HomeDashboard(),
      const SearchScreen(),
      const SettingsScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.primaryLight.withOpacity(0.5),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: fontProvider.scale(22)),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary, size: fontProvider.scale(22)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, size: fontProvider.scale(22)),
            selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: fontProvider.scale(22)),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: fontProvider.scale(22)),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primary, size: fontProvider.scale(22)),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded, size: fontProvider.scale(22)),
            selectedIcon: Icon(Icons.info_rounded, color: AppColors.primary, size: fontProvider.scale(22)),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: fontProvider.scale(18),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => txProvider.refreshDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search prompt header card
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: fontProvider.scale(22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search transactions by customer name...',
                          style: TextStyle(
                            fontSize: fontProvider.scale(14),
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SEARCH',
                          style: TextStyle(
                            fontSize: fontProvider.scale(10),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Overview Cards (Total Count, Total Received, Total Sent)
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'Transactions',
                      value: '${txProvider.totalCount}',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight.withOpacity(0.4),
                      fontProvider: fontProvider,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      title: 'Received',
                      value: AppHelpers.formatCurrency(txProvider.totalReceived, compact: true),
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.received,
                      bgColor: AppColors.receivedLight,
                      fontProvider: fontProvider,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      title: 'Sent',
                      value: AppHelpers.formatCurrency(txProvider.totalSent, compact: true),
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.sent,
                      bgColor: AppColors.sentLight,
                      fontProvider: fontProvider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sync Section Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SMS Database Sync',
                          style: TextStyle(
                            fontSize: fontProvider.scale(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (txProvider.isSyncing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      txProvider.lastSyncTime != null
                          ? 'Last sync: ${AppHelpers.formatDateTime(txProvider.lastSyncTime!)}'
                          : 'Last sync: Never synced yet',
                      style: TextStyle(
                        fontSize: fontProvider.scale(12),
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: Text(
                              txProvider.isSyncing ? 'Syncing...' : 'Sync M-Pesa SMS',
                              style: TextStyle(
                                fontSize: fontProvider.scale(13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: txProvider.isSyncing
                                ? null
                                : () async {
                                    final count = await txProvider.syncMessages();
                                    if (context.mounted) {
                                      if (txProvider.syncError != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Sync error: ${txProvider.syncError}'),
                                            backgroundColor: AppColors.sent,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Sync complete! Added $count new transactions.'),
                                            backgroundColor: AppColors.received,
                                          ),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Demo data loader button
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onPressed: txProvider.isSyncing
                              ? null
                              : () async {
                                  final count = await txProvider.loadMockData();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Loaded $count sample M-Pesa transactions.'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  }
                                },
                          child: Text(
                            '+ Sample Data',
                            style: TextStyle(
                              fontSize: fontProvider.scale(12),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Transactions Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: fontProvider.scale(18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (txProvider.transactions.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                      child: Text(
                        'View All (${txProvider.totalCount})',
                        style: TextStyle(
                          fontSize: fontProvider.scale(13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // List of transactions or empty state
              if (txProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (txProvider.transactions.isEmpty)
                _buildEmptyState(context, fontProvider, txProvider)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txProvider.transactions.length > 15 ? 15 : txProvider.transactions.length,
                  itemBuilder: (ctx, index) {
                    final tx = txProvider.transactions[index];
                    return TransactionCard(transaction: tx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required FontSizeProvider fontProvider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: fontProvider.scale(16)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: fontProvider.scale(14),
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: fontProvider.scale(11),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    FontSizeProvider fontProvider,
    TransactionProvider txProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: fontProvider.scale(56),
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Found',
            style: TextStyle(
              fontSize: fontProvider.scale(18),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Sync M-Pesa SMS" to import messages from your device, or load sample data to preview the system.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontProvider.scale(13),
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Sync Messages Now',
            icon: Icons.sync_rounded,
            onPressed: () => txProvider.syncMessages(),
          ),
        ],
      ),
    );
  }
}
