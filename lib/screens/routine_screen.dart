import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/routine_sync_service.dart';
import 'bottom_nav.dart';

// --- Data Model ----------------------------------------------------------------
enum TaskStatus { pending, done, upcoming }

class TaskData {
  final String id;
  final String image;
  final String title;
  final String scheduledLabel;
  final String completedLabel;
  final String description;
  final TaskStatus initialStatus;

  const TaskData({
    required this.id,
    required this.image,
    required this.title,
    required this.scheduledLabel,
    required this.completedLabel,
    required this.description,
    required this.initialStatus,
  });
}

// --- Screen (StatefulWidget for interactivity) ---------------------------------
class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});
  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  static const _blue = Color(0xFF5B82D7);
  static const _totalTasks = 10;

  // All tasks with mutable status
  late final List<_MutableTask> _morningTasks;
  late final List<_MutableTask> _upcomingTasks;

  @override
  void initState() {
    super.initState();
    _morningTasks = [
      _MutableTask(
        TaskData(
          id: 'drink_water',
          image: AppAssets.routineWater,
          title: 'Drink Water',
          scheduledLabel: 'Scheduled: 9:30 AM',
          completedLabel: 'Completed at 9:30 AM',
          description: 'Finish two full glass of water to stay hydrated.',
          initialStatus: TaskStatus.pending,
        ),
      ),
      _MutableTask(
        TaskData(
          id: 'medication',
          image: AppAssets.routineMedicine,
          title: 'Medication',
          scheduledLabel: 'Scheduled: 10:00 AM',
          completedLabel: 'Completed at 10:00 AM',
          description:
              'Time to take your medication. Please take 3 tablets of Panadol with water.',
          initialStatus: TaskStatus.pending,
        ),
      ),
      _MutableTask(
        TaskData(
          id: 'breakfast',
          image: AppAssets.routineBreakfast,
          title: 'Eat Breakfast',
          scheduledLabel: 'Scheduled: 8:00 AM',
          completedLabel: 'Completed at 7:45 AM',
          description: '',
          initialStatus: TaskStatus.pending,
        ),
      ),
    ];
    _upcomingTasks = [
      _MutableTask(
        TaskData(
          id: 'lunch',
          image: AppAssets.routineLunch,
          title: 'Eat Lunch',
          scheduledLabel: 'Scheduled: 12:30 PM',
          completedLabel: 'Completed at 12:30 PM',
          description: '',
          initialStatus: TaskStatus.upcoming,
        ),
      ),
    ];
    unawaited(_loadRoutineState());
  }

  int get _doneCount => [
        ..._morningTasks,
        ..._upcomingTasks,
      ].where((t) => t.status == TaskStatus.done).length;

  Future<void> _loadRoutineState() async {
    try {
      final states = await RoutineSyncService.instance.fetchTasks();
      if (!mounted) return;
      setState(() {
        for (final task in [..._morningTasks, ..._upcomingTasks]) {
          if (states[task.data.id]?.done ?? false) {
            task.status = TaskStatus.done;
          }
        }
      });
    } catch (_) {
      // Keep the local routine usable if the network is unavailable.
    }
  }

  void _markDone(_MutableTask task) {
    setState(() => task.status = TaskStatus.done);
    unawaited(
      RoutineSyncService.instance.markDone(
        taskId: task.data.id,
        title: task.data.title,
        completedAt: DateTime.now(),
      ),
    );
  }

  String _shareRoutineText() {
    final tasks = [..._morningTasks, ..._upcomingTasks];
    final rows = tasks.map((task) {
      final status = task.status == TaskStatus.done ? 'Done' : 'Pending';
      return '- ${task.data.title} (${task.data.scheduledLabel}): $status';
    }).join('\n');
    return 'Daily Routine\n$rows';
  }

  @override
  Widget build(BuildContext context) {
    final done = _doneCount;
    final total = _totalTasks;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                // -- Top bar ----------------------------------------------
                _TopBar(text: _shareRoutineText()),
                const SizedBox(height: 8),

                // -- Title ------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.tr('Daily Routine'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E0E0),
                ),
                const SizedBox(height: 16),

                // -- Progress ---------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('Daily Progress'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.isArabic
                                ? 'تم $done من $total'
                                : '$done of $total done',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: _blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: done / total,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFD9D9D9),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(_blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // -- List -------------------------------------------------
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Morning section label
                      _SectionLabel(
                        title: 'Morning Tasks',
                        subtitle: 'current Time: 10:00 AM',
                      ),
                      const SizedBox(height: 12),

                      // Morning cards
                      ..._morningTasks.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _TaskCard(task: t, onDone: () => _markDone(t)),
                        ),
                      ),

                      // Upcoming section
                      Text(
                        context.tr('Upcoming'),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 10),

                      ..._upcomingTasks.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _TaskCard(task: t, onDone: () => _markDone(t)),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}

// --- Mutable task wrapper ------------------------------------------------------
class _MutableTask {
  final TaskData data;
  TaskStatus status;
  _MutableTask(this.data) : status = data.initialStatus;
}

// --- Top Bar ------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final String text;
  const _TopBar({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleBtn(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF212121),
              ),
            ),
            Row(
              children: [
                _CircleBtn(
                  onTap: () => ContentActionService.copyText(context, text),
                  child: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(width: 8),
                _CircleBtn(
                  onTap: () => ContentActionService.shareText(context, text),
                  child: const Icon(
                    Icons.ios_share_outlined,
                    size: 18,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _CircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _CircleBtn({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFEDEDED),
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
      );
}

// --- Section Label ------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  final String title, subtitle;
  const _SectionLabel({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(title),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.7,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr(subtitle),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 9.8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B82D7),
            ),
          ),
        ],
      );
}

// --- Task Card ----------------------------------------------------------------
class _TaskCard extends StatelessWidget {
  final _MutableTask task;
  final VoidCallback onDone;
  const _TaskCard({required this.task, required this.onDone});

  static const _blue = Color(0xFF5B82D7);
  static const _blueDark = Color(0xFF45609B);
  static const _greenDone = Color(0xFF70B590);

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    final isDone = status == TaskStatus.done;
    final isUpcoming = status == TaskStatus.upcoming;
    final isPending = status == TaskStatus.pending;
    final label = isDone ? task.data.completedLabel : task.data.scheduledLabel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.5),
        border: isPending ? Border.all(color: _blue, width: 1.09) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 7,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // -- Main column -----------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        task.data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFFEDEDED)),
                      ),
                      if (isDone)
                        Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.22,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 52,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Text block
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(task.data.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF212121),
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(label),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.3,
                        fontWeight: FontWeight.w500,
                        color: isDone ? _greenDone : _blue,
                      ),
                    ),
                    if (task.data.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.tr(task.data.description),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11.3,
                          fontWeight: FontWeight.w400,
                          color: _blueDark,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Action button
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: _ActionButton(
                  status: status,
                  onDone: isPending ? onDone : null,
                ),
              ),
            ],
          ),

          // -- Grey overlay for done / upcoming --------------------
          if (isDone || isUpcoming)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(
                    0xFFCCCCCC,
                  ).withValues(alpha: isDone ? 0.3 : 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Action Button ------------------------------------------------------------
class _ActionButton extends StatelessWidget {
  final TaskStatus status;
  final VoidCallback? onDone;
  const _ActionButton({required this.status, this.onDone});

  static const _blue = Color(0xFF5B82D7);
  static const _greyDisabled = Color(0xFFCFD9E5);
  static const _textGrey = Color(0xFF8A8787);

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == TaskStatus.upcoming;
    final isDone = status == TaskStatus.done;

    return GestureDetector(
      onTap: onDone,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isUpcoming || isDone ? _greyDisabled : _blue,
          borderRadius: BorderRadius.circular(7),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isUpcoming) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: isDone ? _blue : const Color(0xFF212121),
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                context.tr(
                  isUpcoming
                      ? 'NOT TIME YET'
                      : isDone
                          ? 'DONE'
                          : 'DONE',
                ),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isUpcoming ? _textGrey : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
