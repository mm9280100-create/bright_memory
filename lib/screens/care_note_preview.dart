import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';

class CareNotePreview extends StatefulWidget {
  final VoidCallback onAllTap;
  const CareNotePreview({super.key, required this.onAllTap});

  @override
  State<CareNotePreview> createState() => _CareNotePreviewState();
}

class _CareNotePreviewState extends State<CareNotePreview> {
  bool _liked = false;
  int _reactions = 10;

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
          // Author
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    AppAssets.profileAli,
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
                    const Text(
                      'Ali',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.tr('5 min ago'),
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

          // Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.tr(
                'Dad ate his meal well today, and his appetite is noticeably improving. He asked to go for a walk in the garden.',
              ),
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

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _liked = !_liked;
                    _reactions += _liked ? 1 : -1;
                  }),
                  child: Row(
                    children: [
                      Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color:
                            _liked ? AppColors.purple : const Color(0xFFA3A2A2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _liked
                            ? context.isArabic
                                ? '$_reactions ${context.tr('reactions')}'
                                : '$_reactions reactions'
                            : context.tr('Like'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFA3A2A2),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onAllTap,
                  child: Row(
                    children: [
                      Text(
                        context.tr('all'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textDark),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios, size: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

