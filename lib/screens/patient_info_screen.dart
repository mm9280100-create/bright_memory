import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/shared_care_data_service.dart';
import '../shared/widgets/app_widgets.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  static const _prefsKey = 'patient_information_v1';

  // â”€â”€ Patient data state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String? _name;
  String? _building;
  String? _apartment;
  String? _floor;
  String? _gender = 'male';
  String? _yearOfBirth = '1996';
  String? _height = '173';
  String? _weight = '60';

  String get _locationDisplay {
    final parts = [
      _building,
      _apartment,
      _floor,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isEmpty ? '' : parts.join(', ');
  }

  @override
  void initState() {
    super.initState();
    _loadPatientInfo();
  }

  Future<void> _loadPatientInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        if (mounted) _applyPatientInfo(data);
      } catch (_) {
        // Keep defaults if saved data is unreadable.
      }
    }

    try {
      final remote = await SharedCareDataService.instance.fetchPatientInfo();
      if (!mounted || remote == null || remote.isEmpty) return;
      _applyPatientInfo(remote);
      await _savePatientInfoLocal();
    } catch (_) {
      // Local cache remains available offline.
    }
  }

  void _applyPatientInfo(Map<String, dynamic> data) {
    setState(() {
      _name = data['name']?.toString();
      _building = data['building']?.toString();
      _apartment = data['apartment']?.toString();
      _floor = data['floor']?.toString();
      _gender = data['gender']?.toString();
      _yearOfBirth = data['yearOfBirth']?.toString();
      _height = data['height']?.toString();
      _weight = data['weight']?.toString();
    });
  }

  Map<String, dynamic> _patientInfoJson() => {
        'name': _name,
        'building': _building,
        'apartment': _apartment,
        'floor': _floor,
        'gender': _gender,
        'yearOfBirth': _yearOfBirth,
        'height': _height,
        'weight': _weight,
      };

  Future<void> _savePatientInfoLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_patientInfoJson()),
    );
  }

  Future<void> _savePatientInfo() async {
    await _savePatientInfoLocal();
    try {
      await SharedCareDataService.instance.savePatientInfo(_patientInfoJson());
    } catch (_) {
      // Keep local save even if the shared backend is temporarily unavailable.
    }
  }

  void _updatePatientInfo(VoidCallback update) {
    setState(update);
    _savePatientInfo();
  }

  // â”€â”€ Bottom Sheet helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _showSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Status bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: AppStatusBar(),
            ),
            const SizedBox(height: 12),

            // â”€â”€ Back button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
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
                    color: AppColors.textDark,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // â”€â”€ Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.tr('Patient information'),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // â”€â”€ Info rows â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _InfoRow(
                      iconAsset: AppAssets.personIcon,
                      label: 'your name',
                      value: _name,
                      onTap: () => _showSheet(
                        _NameSheet(
                          initial: _name,
                          onConfirm: (v) => _updatePatientInfo(() => _name = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      iconAsset: AppAssets.locationPin,
                      label: 'location',
                      value: _locationDisplay.isEmpty ? null : _locationDisplay,
                      onTap: () => _showSheet(
                        _LocationSheet(
                          building: _building,
                          apartment: _apartment,
                          floor: _floor,
                          onConfirm: (b, a, f) => _updatePatientInfo(() {
                            _building = b;
                            _apartment = a;
                            _floor = f;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      iconAsset: AppAssets.genderIcon,
                      label: 'gender',
                      value: _gender,
                      onTap: () => _showSheet(
                        _GenderSheet(
                          selected: _gender,
                          onConfirm: (v) =>
                              _updatePatientInfo(() => _gender = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      iconAsset: AppAssets.birthIcon,
                      label: 'Year of birth',
                      value: _yearOfBirth,
                      onTap: () => _showSheet(
                        _DateSheet(
                          initial: _yearOfBirth,
                          onConfirm: (v) =>
                              _updatePatientInfo(() => _yearOfBirth = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      iconAsset: AppAssets.heightIcon,
                      label: 'height',
                      value: _height != null ? '$_height cm' : null,
                      onTap: () => _showSheet(
                        _HeightSheet(
                          initial: _height,
                          onConfirm: (v) =>
                              _updatePatientInfo(() => _height = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      iconAsset: AppAssets.bodyWeight,
                      label: 'body weight',
                      value: _weight != null ? '$_weight kg' : null,
                      onTap: () => _showSheet(
                        _WeightSheet(
                          initial: _weight,
                          onConfirm: (v) =>
                              _updatePatientInfo(() => _weight = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Info Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InfoRow extends StatelessWidget {
  final String? iconAsset;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _InfoRow({
    this.iconAsset,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.lightPurple,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // â”€â”€ Icon circle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                iconAsset!,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                color: const Color(0xFF424242),
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF424242),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // â”€â”€ Label â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: Text(
                context.tr(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),

            // â”€â”€ Value + chevron â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
              width: 108,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (value != null && value!.isNotEmpty) ...[
                    Flexible(
                      child: Text(
                        context.tr(value!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Base Bottom Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BaseSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _BaseSheet({
    required this.title,
    required this.content,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEDEDED),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onCancel,
                child: Text(
                  context.tr('Cancel'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE05A4E),
                  ),
                ),
              ),
              Text(
                context.tr(title),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF575555),
                ),
              ),
              GestureDetector(
                onTap: onConfirm,
                child: Text(
                  context.tr('Confirm'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}

// â”€â”€â”€ Name Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _NameSheet extends StatefulWidget {
  final String? initial;
  final void Function(String) onConfirm;
  const _NameSheet({this.initial, required this.onConfirm});

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Name',
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        widget.onConfirm(_ctrl.text);
        Navigator.pop(context);
      },
      content: _SheetTextField(
        controller: _ctrl,
        hint: 'Enter your name',
        autofocus: true,
      ),
    );
  }
}

// â”€â”€â”€ Location Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _LocationSheet extends StatefulWidget {
  final String? building;
  final String? apartment;
  final String? floor;
  final void Function(String, String, String) onConfirm;
  const _LocationSheet({
    this.building,
    this.apartment,
    this.floor,
    required this.onConfirm,
  });

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  late final TextEditingController _building;
  late final TextEditingController _apartment;
  late final TextEditingController _floor;

  @override
  void initState() {
    super.initState();
    _building = TextEditingController(text: widget.building ?? '');
    _apartment = TextEditingController(text: widget.apartment ?? '');
    _floor = TextEditingController(text: widget.floor ?? '');
  }

  @override
  void dispose() {
    _building.dispose();
    _apartment.dispose();
    _floor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'location',
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        widget.onConfirm(_building.text, _apartment.text, _floor.text);
        Navigator.pop(context);
      },
      content: Column(
        children: [
          _SheetTextField(
            controller: _building,
            hint: 'Enter your building',
            autofocus: true,
          ),
          const SizedBox(height: 8),
          _SheetTextField(controller: _apartment, hint: 'Enter your apartment'),
          const SizedBox(height: 8),
          _SheetTextField(controller: _floor, hint: 'Enter your floor'),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Gender Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GenderSheet extends StatefulWidget {
  final String? selected;
  final void Function(String) onConfirm;
  const _GenderSheet({this.selected, required this.onConfirm});

  @override
  State<_GenderSheet> createState() => _GenderSheetState();
}

class _GenderSheetState extends State<_GenderSheet> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'gender',
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        if (_selected != null) {
          widget.onConfirm(_selected!);
        }
        Navigator.pop(context);
      },
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GenderBtn(
              label: 'female',
              selected: _selected == 'female',
              onTap: () => setState(() => _selected = 'female'),
            ),
            const SizedBox(width: 16),
            _GenderBtn(
              label: 'male',
              selected: _selected == 'male',
              onTap: () => setState(() => _selected = 'male'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 87,
        height: 47,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF059669) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          context.tr(label),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF575555),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Date (Year of Birth) Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DateSheet extends StatefulWidget {
  final String? initial;
  final void Function(String) onConfirm;
  const _DateSheet({this.initial, required this.onConfirm});

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'year of birth',
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        widget.onConfirm(_ctrl.text);
        Navigator.pop(context);
      },
      content: _SheetTextField(
        controller: _ctrl,
        hint: 'DD / MM / YYYY',
        keyboardType: TextInputType.datetime,
        autofocus: true,
      ),
    );
  }
}

// â”€â”€â”€ Height Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _HeightSheet extends StatefulWidget {
  final String? initial;
  final void Function(String) onConfirm;
  const _HeightSheet({this.initial, required this.onConfirm});

  @override
  State<_HeightSheet> createState() => _HeightSheetState();
}

class _HeightSheetState extends State<_HeightSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'height (cm)',
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        widget.onConfirm(_ctrl.text);
        Navigator.pop(context);
      },
      content: _SheetTextField(
        controller: _ctrl,
        hint: 'Enter your height',
        keyboardType: TextInputType.number,
        autofocus: true,
      ),
    );
  }
}

// â”€â”€â”€ Weight Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _WeightSheet extends StatefulWidget {
  final String? initial;
  final void Function(String) onConfirm;
  const _WeightSheet({this.initial, required this.onConfirm});

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'weight (kg)',
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        widget.onConfirm(_ctrl.text);
        Navigator.pop(context);
      },
      content: _SheetTextField(
        controller: _ctrl,
        hint: 'Enter your weight',
        keyboardType: TextInputType.number,
        autofocus: true,
      ),
    );
  }
}

// â”€â”€â”€ Sheet Text Field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool autofocus;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: context.tr(hint),
          hintStyle: const TextStyle(fontSize: 10, color: Color(0xFF575555)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
