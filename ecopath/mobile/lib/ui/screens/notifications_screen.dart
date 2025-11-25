// lib/ui/screens/notification_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum NotificationKind { game, shop, community, reminder }

class AppNotification {
  final NotificationKind kind;
  final String title;      // short headline
  final String message;    // detail
  final DateTime createdAt;

  AppNotification({
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
  });
}

/// Global center used by ProgressTracker + game screens
class NotificationCenter extends ChangeNotifier {
  NotificationCenter._internal() {
    // Seed with a few sample items so it's not empty on first launch
    _items.addAll([
      AppNotification(
        kind: NotificationKind.game,
        title: 'You got 5 points from quiz!',
        message: 'Nice! Keep your streak going 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 11)),
      ),
      AppNotification(
        kind: NotificationKind.game,
        title: 'You earned 8 pts from Trash Scan',
        message: 'Plastic bottle + can detected.',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      AppNotification(
        kind: NotificationKind.shop,
        title: 'Plastic bag redeemed',
        message: 'Used 12 pts in EcoShop.',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 22)),
      ),
      AppNotification(
        kind: NotificationKind.community,
        title: 'Kezia just passed your rank',
        message: 'You’re now #6 on weekly leaderboard.',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      ),
      AppNotification(
        kind: NotificationKind.reminder,
        title: 'Daily reminder',
        message: 'Take a 1-min quiz to earn points.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  static final NotificationCenter I = NotificationCenter._internal();

  final List<AppNotification> _items = [];
  List<AppNotification> get items => List.unmodifiable(_items);

  void _add(AppNotification n) {
    _items.insert(0, n); // newest first
    notifyListeners();
  }

  // ----- Public APIs used from ProgressTracker -----

  void pushGamePoints({
    required String gameName,
    required int points,
  }) {
    _add(
      AppNotification(
        kind: NotificationKind.game,
        title: 'You got $points pts from $gameName!',
        message: 'Nice job playing $gameName 🎮',
        createdAt: DateTime.now(),
      ),
    );
  }

  void pushLevelUp({required int newLevel}) {
    _add(
      AppNotification(
        kind: NotificationKind.game,
        title: 'Level up! 🎉',
        message: 'You reached Level $newLevel.',
        createdAt: DateTime.now(),
      ),
    );
  }

  void pushRankChanged({
    required int oldRank,
    required int newRank,
  }) {
    final movingUp = newRank < oldRank;
    final diff = (oldRank - newRank).abs();
    final emoji = movingUp ? '📈' : '📉';

    _add(
      AppNotification(
        kind: NotificationKind.community,
        title: movingUp
            ? 'Your rank went up to #$newRank $emoji'
            : 'Your rank is now #$newRank $emoji',
        message: 'You moved ${movingUp ? "up" : "down"} by $diff spot(s) on the leaderboard.',
        createdAt: DateTime.now(),
      ),
    );
  }

  void pushEnergyFull(int maxEnergy) {
    _add(
      AppNotification(
        kind: NotificationKind.reminder,
        title: 'Energy full ⚡',
        message: 'Your energy is back to $maxEnergy. Time to play again!',
        createdAt: DateTime.now(),
      ),
    );
  }

  // Optional generic method if you need custom notifications later
  void pushCustom({
    required NotificationKind kind,
    required String title,
    required String message,
  }) {
    _add(
      AppNotification(
        kind: kind,
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationCenter _center;

  @override
  void initState() {
    super.initState();
    _center = NotificationCenter.I;
    _center.addListener(_onCenterChanged);
  }

  void _onCenterChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _center.removeListener(_onCenterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final cs = Theme.of(context).colorScheme;
    final items = _center.items;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(paddingTop: paddingTop)),
            if (items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No notifications yet.\nPlay games, recycle, or complete challenges to earn some!',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _NotificationTile(item: items[index]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// ====== HEADER ======
class _Header extends StatelessWidget {
  const _Header({required this.paddingTop});
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(20, paddingTop + 20, 20, 12),
      color: cs.surface,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // back button
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back_rounded, color: cs.onSurface, size: 22),
              ),
            ),
          ),

          // title
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notifications',
                style: tt.displaySmall?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),

          // mascot image
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              height: 100,
              child: Image.asset(
                'assets/images/notificationpage.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== TILE ======
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final AppNotification item;

  IconData _iconFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.game:
        return Icons.sports_esports_rounded;
      case NotificationKind.shop:
        return Icons.shopping_bag_rounded;
      case NotificationKind.community:
        return Icons.emoji_events_rounded;
      case NotificationKind.reminder:
        return Icons.notifications_active_rounded;
    }
  }

  (Color bg, Color fg) _iconColors(ColorScheme cs, NotificationKind kind) {
    switch (kind) {
      case NotificationKind.game:
        return (cs.tertiaryContainer, cs.onTertiaryContainer);
      case NotificationKind.shop:
        return (cs.primaryContainer, cs.onPrimaryContainer);
      case NotificationKind.community:
        return (cs.secondaryContainer, cs.onSecondaryContainer);
      case NotificationKind.reminder:
        return (cs.errorContainer, cs.onErrorContainer);
    }
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '${weeks}w';
    final months = (diff.inDays / 30).floor();
    return '${months}mo';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final (bg, fg) = _iconColors(cs, item.kind);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(item.kind), color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _timeAgo(item.createdAt),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
