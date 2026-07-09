import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/call_invite_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool _calling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 360,
          height: 800,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 64,
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.greyBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 151,
                width: 328,
                child: Text(
                  context.tr(
                    "Don't forget those who loved you without expecting anything in return.",
                  ),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA8892E),
                    letterSpacing: 0,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 212,
                child: _ContactCard(
                  onVideo: () => _startCall(context, CallInviteMode.video),
                  onCall: () => _startCall(context, CallInviteMode.audio),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startCall(BuildContext context, CallInviteMode mode) async {
    if (_calling || CallInviteService.instance.hasActiveSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('A call is already in progress'))),
      );
      return;
    }
    setState(() => _calling = true);
    final started = await CallInviteService.instance.sendInvite(mode);
    if (!context.mounted) return;
    if (!started) {
      setState(() => _calling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('A call is already in progress'))),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      mode == CallInviteMode.video ? AppRoutes.videoCall : AppRoutes.call,
    ).whenComplete(() {
      if (mounted) setState(() => _calling = false);
    });
  }
}

class _ContactCard extends StatelessWidget {
  final VoidCallback onVideo;
  final VoidCallback onCall;

  const _ContactCard({
    required this.onVideo,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      height: 397,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.locationBar,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 60,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                AppAssets.dad,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF5A5047)),
              ),
            ),
          ),
          const Positioned(
            left: 12,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Dad',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    height: 27 / 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Omar',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      height: 15 / 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF848484),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 94,
            bottom: 10,
            child: _ContactActionButton(
              icon: Icons.videocam,
              filled: true,
              onTap: onVideo,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 10,
            child: _ContactActionButton(
              icon: Icons.call,
              onTap: onCall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ContactActionButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled ? AppColors.emergency : Colors.white,
          border: filled ? null : Border.all(color: AppColors.emergency),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? Colors.white : AppColors.emergency,
        ),
      ),
    );
  }
}

