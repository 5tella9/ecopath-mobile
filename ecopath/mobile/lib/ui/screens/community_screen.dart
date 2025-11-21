// lib/ui/screens/community_screen.dart
import 'dart:io';

import 'package:ecopath/core/progress_tracker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// NEW: localization
import 'package:ecopath/l10n/app_localizations.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _userAvatar = 'assets/images/profileimg.png';
  static const _keziaAvatar = 'assets/images/otter.png';
  static const _thomasAvatar = 'assets/images/polar.png';
  static const _jinAvatar = 'assets/images/bee.png';
  static const _minjiAvatar = 'assets/images/bird.png';
  static const _keziaFeedImg = 'assets/images/community1.png';
  static const _severusAvatar = 'assets/images/elephant.png';

  final String _currentUserName = 'Stella';

  int streak = 5;
  String? _filterTag;

  final _quests = <Quest>[
    Quest(
      id: 'q1',
      title: 'Recycle 5 Bottles',
      desc: 'Drop clean bottles into the correct bin.',
      rarity: Rarity.common,
      xp: 20,
      goal: 5,
    ),
    Quest(
      id: 'q2',
      title: 'Eco Bag Streak',
      desc: 'Use a reusable bag for 3 days.',
      rarity: Rarity.rare,
      xp: 30,
      goal: 3,
    ),
    Quest(
      id: 'q3',
      title: 'Public Transport Hero',
      desc: 'Commute car-free twice this week.',
      rarity: Rarity.epic,
      xp: 40,
      goal: 2,
    ),
  ];

  final _leaders = <Leader>[
    Leader('Severus', 250, _severusAvatar),
    Leader('Hermione', 210, _keziaAvatar),
    Leader('Ron', 190, _thomasAvatar),
    Leader('Harry', 170, _jinAvatar),
    Leader('Lunar', 155, _minjiAvatar),
    Leader('Ginny', 140, _keziaAvatar),
    Leader('Draco', 130, _thomasAvatar),
    Leader('Neville', 120, _jinAvatar),
    Leader('Stella', 90, _userAvatar),
  ];

  final Set<String> _likedPosts = {};

  final _feed = <Post>[
    Post(
      id: 'p1',
      author: 'Hermione',
      avatar: _keziaAvatar,
      content: 'Turned an old T-shirt into a tote! ♻️ #Upcycling #Recycling',
      image: _keziaFeedImg,
      tags: ['#Upcycling', '#Recycling'],
      likes: 17,
      comments: 2,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
      isLocal: false,
    ),
    Post(
      id: 'p2',
      author: 'Ron',
      avatar: _thomasAvatar,
      content:
          'Pro tip: freeze veggie scraps to make broth later. #ZeroWaste #Composting',
      tags: ['#ZeroWaste', '#Composting'],
      likes: 9,
      comments: 1,
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      isLocal: false,
    ),
  ];

  final Map<String, List<String>> _comments = {
    'p1': ['Love this idea! 🌱', 'So cute and useful!'],
    'p2': ['Great tip, thanks!', 'I do this too.'],
  };

  final _missions = <Mission>[
    Mission(
      id: 'm1',
      title: 'Han River Cleanup',
      date: 'Sat, Nov 15 • 10:00',
      place: 'Yeouinaru Station Exit 2',
      desc: 'Friendly riverside cleanup. Gloves & bags provided.',
      registerUntil: 'Nov 14, 23:59',
    ),
    Mission(
      id: 'm2',
      title: 'Upcycling Workshop',
      date: 'Sun, Nov 23 • 14:00',
      place: 'Sejong Univ. Makerspace',
      desc: 'Turn old shirts into tote bags with simple sewing tips.',
      registerUntil: 'Nov 21, 18:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _gainXP(int add, {String? toast}) {
    ProgressTracker.instance.addXp(add);
    if (toast != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$toast • +$add XP'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final Color dark1 = Color.lerp(Colors.black, cs.primary, 0.35)!;
    final Color dark2 = Color.lerp(Colors.black, cs.primary, 0.75)!;
    final bgGradient = LinearGradient(
      colors: [dark1, dark2],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Color pillColor =
        Color.lerp(cs.primaryContainer, Colors.black, 0.35)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.communityTitle,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _gamerHeader(cs, text),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white24),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  labelColor: cs.onPrimary,
                  unselectedLabelColor: cs.onPrimary.withOpacity(.7),
                  tabs: [
                    Tab(text: l10n.tabQuests),
                    Tab(text: l10n.tabFeed),
                    Tab(text: l10n.tabEvents),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _questsTab(context, cs, text, pillColor),
                    _feedTab(context, cs, text),
                    _eventsTab(context, cs, text, pillColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _tab.index == 1
          ? FloatingActionButton(
              backgroundColor: pillColor,
              onPressed: _composePost,
              child: Icon(Icons.add, color: cs.onPrimary),
              tooltip: l10n.fabAddEcoTip,
            )
          : null,
    );
  }

  // ---------- HEADER ----------
  Widget _gamerHeader(ColorScheme cs, TextTheme text) {
    final tracker = ProgressTracker.instance;
    final level = tracker.level;
    final xp = tracker.currentXp;
    final xpToNext = tracker.xpToNext;
    final progress =
        xpToNext == 0 ? 0.0 : (xp / xpToNext).clamp(0.0, 1.0);

    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.surface,
            backgroundImage: const AssetImage(_userAvatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.levelPrefix} $level',
                  style: text.titleMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: cs.onPrimary.withOpacity(.2),
                    color: cs.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$xp / $xpToNext XP',
                  style: text.bodySmall?.copyWith(color: cs.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    size: 16, color: Colors.orangeAccent),
                const SizedBox(width: 4),
                Text(
                  '${l10n.streakPrefix} $streak',
                  style: text.bodySmall?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- QUESTS + LEADERBOARD ----------
  Widget _questsTab(
      BuildContext context, ColorScheme cs, TextTheme text, Color pillColor) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ..._quests.map((q) => _questCard(context, q, cs, text, pillColor)),
        const SizedBox(height: 16),
        _leaderboardCard(context, cs, text),
      ],
    );
  }

  Widget _questCard(BuildContext context, Quest q, ColorScheme cs,
      TextTheme text, Color pillColor) {
    final l10n = AppLocalizations.of(context)!;

    final color = switch (q.rarity) {
      Rarity.common => cs.primary,
      Rarity.rare => cs.secondary,
      Rarity.epic => cs.tertiary,
    };
    final pct = (q.progress / q.goal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.title,
              style: text.titleMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              q.desc,
              style: text.bodySmall
                  ?.copyWith(color: cs.onPrimary.withOpacity(.8)),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: cs.onPrimary.withOpacity(.2),
              color: color,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${q.progress}/${q.goal}',
                  style: text.bodySmall?.copyWith(color: cs.onPrimary),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => q.joined = !q.joined);
                    _gainXP(
                      5,
                      toast: q.joined
                          ? l10n.joinedQuestToast
                          : l10n.leftQuestToast,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pillColor,
                    foregroundColor: cs.onPrimary,
                  ),
                  child: Text(q.joined ? 'Joined' : 'Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- LEADERBOARD ----------
  Widget _leaderboardCard(
      BuildContext context, ColorScheme cs, TextTheme text) {
    final tracker = ProgressTracker.instance;
    final l10n = AppLocalizations.of(context)!;

    final leaders = _leaders
        .map((l) => l.name == _currentUserName
            ? Leader(l.name, tracker.currentXp, l.avatar)
            : Leader(l.name, l.xp, l.avatar))
        .toList();

    final sorted = [...leaders]..sort((a, b) => b.xp.compareTo(a.xp));
    final top5 = sorted.take(5).toList();
    final currentIndex =
        sorted.indexWhere((l) => l.name == _currentUserName);
    final showCurrentOutsideTop5 = currentIndex >= 5 && currentIndex != -1;
    final currentRank = currentIndex + 1;

    Leader? currentLeader;
    if (currentIndex != -1) {
      currentLeader = sorted[currentIndex];
      ProgressTracker.instance.setRank(currentRank);
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.leaderboardThisWeek,
                style: text.titleMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tracker.currentXp} XP',
                style: text.bodySmall?.copyWith(
                  color: cs.onPrimary.withOpacity(.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (top5.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (top5.length > 1)
                  _podiumTile(
                    leader: top5[1],
                    rank: 2,
                    cs: cs,
                    text: text,
                    height: 90,
                  ),
                _podiumTile(
                  leader: top5[0],
                  rank: 1,
                  cs: cs,
                  text: text,
                  height: 110,
                  highlight: true,
                ),
                if (top5.length > 2)
                  _podiumTile(
                    leader: top5[2],
                    rank: 3,
                    cs: cs,
                    text: text,
                    height: 80,
                  ),
              ],
            ),
          const SizedBox(height: 8),
          for (int i = 3; i < top5.length; i++)
            _leaderRow(
              rank: i + 1,
              leader: top5[i],
              cs: cs,
              text: text,
            ),
          if (showCurrentOutsideTop5 && currentLeader != null) ...[
            const SizedBox(height: 6),
            Divider(color: Colors.white12, height: 16),
            _leaderRow(
              rank: currentRank,
              leader: currentLeader,
              cs: cs,
              text: text,
              isYou: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _podiumTile({
    required Leader leader,
    required int rank,
    required ColorScheme cs,
    required TextTheme text,
    required double height,
    bool highlight = false,
  }) {
    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = const Color(0xFFFFD54F);
        break;
      case 2:
        medalColor = const Color(0xFFE0E0E0);
        break;
      case 3:
        medalColor = const Color(0xFFB87333);
        break;
      default:
        medalColor = cs.surface;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: highlight ? 22 : 20,
          backgroundImage: AssetImage(leader.avatar),
        ),
        const SizedBox(height: 6),
        Text(
          leader.name,
          style: text.bodySmall?.copyWith(
            color: cs.onPrimary,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: height / 4,
          decoration: BoxDecoration(
            color: medalColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: text.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: rank == 3 ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _leaderRow({
    required int rank,
    required Leader leader,
    required ColorScheme cs,
    required TextTheme text,
    bool isYou = false,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$rank',
            style: text.bodyMedium?.copyWith(
              color: cs.onPrimary.withOpacity(.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(leader.avatar),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isYou ? '${leader.name} ${l10n.isYouSuffix}' : leader.name,
              style: text.bodyMedium
                  ?.copyWith(color: cs.onPrimary.withOpacity(.9)),
            ),
          ),
          Text(
            '${leader.xp} XP',
            style: text.bodySmall?.copyWith(
              color: cs.onPrimary.withOpacity(.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- FEED ----------
  Widget _feedTab(BuildContext context, ColorScheme cs, TextTheme text) {
    final posts = _filterTag == null
        ? _feed
        : _feed.where((p) => p.tags.contains(_filterTag)).toList();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        if (_filterTag != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Text(
                  '${l10n.filterShowingPrefix} $_filterTag',
                  style: text.bodySmall?.copyWith(color: cs.onPrimary),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() => _filterTag = null);
                  },
                  child: Text(l10n.clear),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (_, i) => _postCard(posts[i], cs, text),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final t = TimeOfDay.fromDateTime(time);
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _toggleLike(Post p) {
    setState(() {
      if (_likedPosts.contains(p.id)) {
        _likedPosts.remove(p.id);
        p.likes -= 1;
      } else {
        _likedPosts.add(p.id);
        p.likes += 1;
      }
    });
  }

  void _openComments(Post p) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87.withOpacity(0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final comments = _comments[p.id] ?? [];
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.commentsTitle,
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: comments.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        comments[i],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: l10n.commentsHint,
                            hintStyle:
                                const TextStyle(color: Colors.white70),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          final textValue = controller.text.trim();
                          if (textValue.isEmpty) return;
                          setState(() {
                            _comments.putIfAbsent(p.id, () => []);
                            _comments[p.id]!.add(textValue);
                            p.comments = _comments[p.id]!.length;
                          });
                          controller.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHashtagChip(String tag, ColorScheme cs, TextTheme text) {
    final bool active = _filterTag == tag;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterTag = tag;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:
              active ? cs.primaryContainer : cs.surface.withOpacity(0.25),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          tag,
          style: text.bodySmall?.copyWith(
            color: cs.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _postCard(Post p, ColorScheme cs, TextTheme text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 18, backgroundImage: AssetImage(p.avatar)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                p.author,
                style: text.titleSmall?.copyWith(color: cs.onPrimary),
              ),
            ),
            Text(
              _formatTime(p.time),
              style: text.bodySmall
                  ?.copyWith(color: cs.onPrimary.withOpacity(0.7)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            p.content,
            style: text.bodySmall?.copyWith(color: cs.onPrimary),
          ),
          if (p.tags.isNotEmpty)
            Wrap(
              children: p
                  .mapTags()
                  .map((tag) => _buildHashtagChip(tag, cs, text))
                  .toList(),
            ),
          if (p.image != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: p.isLocal
                  ? Image.file(
                      File(p.image!),
                      height: 170,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      p.image!,
                      height: 170,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () => _toggleLike(p),
                icon: Icon(
                  _likedPosts.contains(p.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _likedPosts.contains(p.id)
                      ? Colors.pinkAccent
                      : cs.onPrimary.withOpacity(0.8),
                  size: 22,
                ),
              ),
              Text(
                '${p.likes}',
                style: text.bodySmall?.copyWith(color: cs.onPrimary),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _openComments(p),
                icon: Icon(
                  Icons.mode_comment_outlined,
                  color: cs.onPrimary.withOpacity(0.8),
                  size: 22,
                ),
              ),
              Text(
                '${p.comments}',
                style: text.bodySmall?.copyWith(color: cs.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- EVENTS ----------
  Widget _eventsTab(
      BuildContext context, ColorScheme cs, TextTheme text, Color pillColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _missions
          .map((m) => _missionCard(context, m, cs, text, pillColor))
          .toList(),
    );
  }

  Widget _missionCard(BuildContext context, Mission m, ColorScheme cs,
      TextTheme text, Color pillColor) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.title,
            style: text.titleMedium?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  m.date,
                  style: text.bodySmall
                      ?.copyWith(color: cs.onPrimary.withOpacity(0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  m.place,
                  style: text.bodySmall
                      ?.copyWith(color: cs.onPrimary.withOpacity(0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                '${l10n.registerByPrefix} ${m.registerUntil}',
                style: text.bodySmall
                    ?.copyWith(color: cs.onPrimary.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            m.desc,
            style: text.bodySmall?.copyWith(color: cs.onPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => m.joined = !m.joined);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        m.joined
                            ? '${l10n.joinedPrefix} ${m.title}'
                            : '${l10n.leftPrefix} ${m.title}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pillColor,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(m.joined ? 'Joined' : 'Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _composePost() async {
    final contentController = TextEditingController();
    final tagsController =
        TextEditingController(text: '#EcoTips #ZeroWaste');
    String? pickedImagePath;

    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87.withOpacity(0.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.newPostTitle,
                      style: Theme.of(ctx)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.shareEcoTipHint,
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.hashtagsHint,
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.black54,
                    labelText: l10n.hashtagsLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (picked != null) {
                      pickedImagePath = picked.path;
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(l10n.addPhotoButton),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final textValue = contentController.text.trim();
                      if (textValue.isEmpty) return;
                      final tagsText = tagsController.text.trim();
                      final tags = tagsText
                          .split(RegExp(r'\s+'))
                          .where((t) => t.startsWith('#') && t.length > 1)
                          .toList();

                      setState(() {
                        final newPost = Post(
                          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                          author: _currentUserName,
                          avatar: _userAvatar,
                          content: textValue +
                              (tags.isNotEmpty
                                  ? ' ${tags.join(' ')}'
                                  : ''),
                          tags: tags,
                          likes: 0,
                          comments: 0,
                          time: DateTime.now(),
                          image: pickedImagePath,
                          isLocal: pickedImagePath != null,
                        );
                        _feed.insert(0, newPost);
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Text(l10n.postButton),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ------------------ DATA CLASSES ------------------ */

enum Rarity { common, rare, epic }

class Quest {
  final String id;
  final String title;
  final String desc;
  final Rarity rarity;
  final int xp;
  final int goal;
  bool joined;
  int progress;
  Quest({
    required this.id,
    required this.title,
    required this.desc,
    required this.rarity,
    required this.xp,
    required this.goal,
    this.joined = false,
    this.progress = 0,
  });
}

class Leader {
  final String name;
  final int xp;
  final String avatar;
  Leader(this.name, this.xp, this.avatar);
}

class Post {
  final String id;
  final String author;
  final String avatar;
  final String content;
  final String? image;
  final List<String> tags;
  int likes;
  int comments;
  final DateTime time;
  final bool isLocal;

  Post({
    required this.id,
    required this.author,
    required this.avatar,
    required this.content,
    this.image,
    required this.tags,
    this.likes = 0,
    this.comments = 0,
    required this.time,
    this.isLocal = false,
  });

  Iterable<String> mapTags() {
    final set = <String>{};
    for (final t in tags) {
      if (t.trim().isNotEmpty) set.add(t.trim());
    }
    return set;
  }
}

class Mission {
  final String id;
  final String title;
  final String date;
  final String place;
  final String desc;
  final String registerUntil;
  bool joined;
  Mission({
    required this.id,
    required this.title,
    required this.date,
    required this.place,
    required this.desc,
    required this.registerUntil,
    this.joined = false,
  });
}
