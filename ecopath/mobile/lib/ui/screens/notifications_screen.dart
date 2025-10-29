import 'package:flutter/material.dart';

/// ====== STYLE ======
const kPrimary = Color(0xFF00221C);
const kAccent = Color(0xFF5E9460);
const kCard = Color(0xFFF6F4F3);
const kSoft = Color(0xFF9AA8A4);

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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: Replace with your repository/service later.
  final List<AppNotification> _items = [
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
  ];

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(paddingTop: paddingTop),
            ),
            SliverList.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = _items[index];
                return _NotificationTile(item: n);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// ====== WIDGETS ======

class _Header extends StatelessWidget {
  const _Header({required this.paddingTop});
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, paddingTop + 20, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // back button (top-left)
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // go back to Profile
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: kPrimary,
                  size: 22,
                ),
              ),
            ),
          ),

          // Title (slightly pushed down so it doesn't clash visually with back button)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                  height: 1.1,
                ),
              ),
            ),
          ),

          // Right-side mascot image
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

  Color _iconBgFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.game:
        return const Color(0xFFE9F7EE); // light green
      case NotificationKind.shop:
        return const Color(0xFFEFF4FF); // light blue-ish
      case NotificationKind.community:
        return const Color(0xFFFFF4EC); // light orange
      case NotificationKind.reminder:
        return const Color(0xFFFFF2F2); // light red
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBgFor(item.kind),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(item.kind), color: kPrimary),
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
                    style: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kSoft,
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
              style: const TextStyle(
                color: kSoft,
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
