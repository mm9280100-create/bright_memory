import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/shared_care_data_service.dart';
import '../shared/widgets/app_widgets.dart';

class CareNotesScreen extends StatefulWidget {
  const CareNotesScreen({super.key});

  @override
  State<CareNotesScreen> createState() => _CareNotesScreenState();
}

class _CareNotesScreenState extends State<CareNotesScreen> {
  static const _prefsKey = 'care_notes_v1';

  final List<_NoteData> _notes = [
    _NoteData(
      author: 'Ali',
      avatar: AppAssets.profileAli,
      timeAgo: '5 min ago',
      date: 'Thursday, 30 May 2026',
      time: '3 PM',
      text:
          'Dad ate his meal well today, and his appetite is noticeably improving. He asked to go for a walk in the garden.',
      reactions: 10,
      liked: true,
    ),
    _NoteData(
      author: 'Lola',
      avatar: AppAssets.profileLola,
      timeAgo: '1 hr ago',
      date: 'Wednesday, 29 Apr 2026',
      time: '11 AM',
      text:
          'He felt a bit confused in the afternoon, possibly due to poor sleep last night. I gave him a warm cup of anise tea and he calmed down.',
      reactions: 2,
      liked: true,
    ),
    _NoteData(
      author: 'Nour',
      avatar: AppAssets.profileNour,
      timeAgo: '3 hrs ago',
      date: 'Wednesday, 29 Apr 2026',
      time: '11 AM',
      text:
          'He forgot where he left his glasses this morning, but after a short search we found them. He felt better and started his day calmly.',
      reactions: 0,
      liked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final notes = decoded
              .whereType<Map>()
              .map(
                  (item) => _NoteData.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          if (mounted && notes.isNotEmpty) {
            setState(() {
              _notes
                ..clear()
                ..addAll(notes);
            });
          }
        }
      } catch (_) {
        // Keep bundled notes if saved data is unreadable.
      }
    }

    try {
      final remoteNotes = await SharedCareDataService.instance.fetchCareNotes();
      if (!mounted || remoteNotes == null || remoteNotes.isEmpty) return;
      setState(() {
        _notes
          ..clear()
          ..addAll(remoteNotes.map(_NoteData.fromJson));
      });
      await _saveNotesLocal();
    } catch (_) {
      // Local cache remains available offline.
    }
  }

  Future<void> _saveNotesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_notes.map((note) => note.toJson()).toList()),
    );
  }

  Future<void> _saveNotes() async {
    await _saveNotesLocal();
    try {
      await SharedCareDataService.instance.saveCareNotes(
        _notes.map((note) => note.toJson()).toList(),
      );
    } catch (_) {
      // Keep local save even if the shared backend is temporarily unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppStatusBar(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.greyBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _notes.length,
                itemBuilder: (_, i) {
                  final note = _notes[i];
                  final showDate = i == 0 || note.date != _notes[i - 1].date;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDate) ...[
                        Text(
                          context.tr(note.date),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(note.time),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      _NoteCard(
                        note: note,
                        onLike: () {
                          setState(() {
                            _notes[i] = _notes[i].copyWith(
                              liked: !_notes[i].liked,
                              reactions: _notes[i].liked
                                  ? _notes[i].reactions - 1
                                  : _notes[i].reactions + 1,
                            );
                          });
                          _saveNotes();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showAddNote(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: AppColors.white, size: 28),
        ),
      ),
    );
  }

  void _showAddNote(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('Add Care Note'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.noteCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.tr('Write your note here...'),
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.isNotEmpty) {
                    setState(() {
                      _notes.insert(
                        0,
                        _NoteData(
                          author: 'Ali',
                          avatar: AppAssets.profileAli,
                          timeAgo: 'Just now',
                          date: 'Thursday, 30 May 2026',
                          time: 'Now',
                          text: ctrl.text,
                          reactions: 0,
                          liked: false,
                        ),
                      );
                    });
                    _saveNotes();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  context.tr('Post Note'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final _NoteData note;
  final VoidCallback onLike;
  const _NoteCard({required this.note, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.noteCard,
        border: Border.all(
          color: const Color(0xFFA9A8A8).withValues(alpha: 0.5),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    note.avatar,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 32,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      context.tr(note.timeAgo),
                      style: const TextStyle(
                        fontSize: 6,
                        color: Color(0xFF9D9C9C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.tr(note.text),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: Color(0x66A9A8A8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: onLike,
              child: Row(
                children: [
                  Icon(
                    note.liked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color:
                        note.liked ? AppColors.purple : const Color(0xFFA3A2A2),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    note.reactions > 0
                        ? context.isArabic
                            ? '${note.reactions} ${context.tr('reactions')}'
                            : '${note.reactions} reactions'
                        : context.tr('Like'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFA3A2A2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note Data Model ──────────────────────────────────────────────────────────
class _NoteData {
  final String author, avatar, timeAgo, date, time, text;
  final int reactions;
  final bool liked;

  const _NoteData({
    required this.author,
    required this.avatar,
    required this.timeAgo,
    required this.date,
    required this.time,
    required this.text,
    required this.reactions,
    required this.liked,
  });

  _NoteData copyWith({bool? liked, int? reactions}) => _NoteData(
        author: author,
        avatar: avatar,
        timeAgo: timeAgo,
        date: date,
        time: time,
        text: text,
        reactions: reactions ?? this.reactions,
        liked: liked ?? this.liked,
      );

  factory _NoteData.fromJson(Map<String, dynamic> json) => _NoteData(
        author: json['author']?.toString() ?? 'Ali',
        avatar: json['avatar']?.toString() ?? AppAssets.profileAli,
        timeAgo: json['timeAgo']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        time: json['time']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        reactions: int.tryParse(json['reactions']?.toString() ?? '') ?? 0,
        liked: json['liked'] == true,
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'avatar': avatar,
        'timeAgo': timeAgo,
        'date': date,
        'time': time,
        'text': text,
        'reactions': reactions,
        'liked': liked,
      };
}
