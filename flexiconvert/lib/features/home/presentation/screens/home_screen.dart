import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/category_grid.dart';
import '../widgets/recent_files_list.dart';
import '../widgets/statistics_card.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.value;

    Widget avatar;
    if (!kIsWeb && profile?.customAvatarPath != null) {
      avatar = CircleAvatar(
        radius: 18,
        backgroundImage: FileImage(File(profile!.customAvatarPath!)),
      );
    } else if (user?.photoURL != null) {
      avatar = CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(user!.photoURL!),
      );
    } else {
      avatar = CircleAvatar(
        radius: 18,
        backgroundColor: context.colorScheme.primaryContainer,
        child: Icon(Icons.person, size: 18, color: context.colorScheme.primary),
      );
    }

    return Scaffold(
      appBar: AnimatedAppBar(
        title: 'FlexiConvert',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.goNamed(RouteConstants.search),
          ),
          GestureDetector(
            onTap: () => _openProfile(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: avatar,
            ),
          ),
        ],
      ),
      body: WebConstrainedBox(
        maxWidth: 800,
        child: _buildMobileLayout(context),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  /// Scrollable layout for both web and mobile
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatisticsCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            SizedBox(height: AppSpacing.xxl),
            Text(
              'Categories',
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.md),
            const CategoryGrid().animate().fadeIn(delay: 300.ms),
            SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Files',
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.goNamed(RouteConstants.history),
                  child: const Text('View All'),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            SizedBox(height: AppSpacing.sm),
            const RecentFilesList().animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const ProfileScreen(),
        ),
      ),
    );
  }
}
