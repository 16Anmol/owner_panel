import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Upload (create) a new property — PG, Guest Room, or Plot.
///
/// Flow:
///   1. Pick property type (pg / guest / plot)
///   2. Fill type-specific details
///   3. Add at least 1 photo + Registry doc + NOC doc (all required)
///   4. Submit  →  createProperty  →  uploadPropertyPhotos  →  uploadDocuments
///
/// Mirrors the field structure & web/mobile file picker used by
/// EditPropertyScreen so the data shape matches the backend exactly.
class UploadPropertyScreen extends StatefulWidget {
  const UploadPropertyScreen({super.key});
  @override
  State<UploadPropertyScreen> createState() => _UploadPropertyScreenState();
}

class _UploadPropertyScreenState extends State<UploadPropertyScreen> {
  String _type = 'plot'; // pg | guest | plot
  bool _saving = false;

  // ── New uploads ───────────────────────────────────────────────
  final List<Uint8List> _photoBytes = [];
  final List<String> _photoNames = [];
  Uint8List? _registryBytes;
  String? _registryName;
  Uint8List? _nocBytes;
  String? _nocName;
  // ID proof (Aadhaar or PAN) — front + back
  String _idType = 'aadhaar'; // 'aadhaar' | 'pan'
  Uint8List? _idFrontBytes;
  String? _idFrontName;
  Uint8List? _idBackBytes;
  String? _idBackName;

  // ── Common fields ─────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _mapLinkCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<String> _facilities = [];

  // ── Plot fields ───────────────────────────────────────────────
  final _plotIdCtrl = TextEditingController();
  final _plotSizeCtrl = TextEditingController();
  final _plotLengthCtrl = TextEditingController();
  final _plotWidthCtrl = TextEditingController();
  final _totalPriceCtrl = TextEditingController();
  String? _plotType, _facing, _ownershipType;

  // ── PG fields ─────────────────────────────────────────────────
  final _totalRoomsCtrl = TextEditingController();
  final _acRoomsCtrl = TextEditingController();
  final _nonAcCtrl = TextEditingController();
  final _singlePriceCtrl = TextEditingController();
  final _singleDepCtrl = TextEditingController();
  final _doublePriceCtrl = TextEditingController();
  final _doubleDepCtrl = TextEditingController();
  String _occupancy = 'any', _roomType = 'sharing';
  bool _commonKitchen = false, _privateKitchen = false;
  final List<String> _pgAvailFor = [];

  // ── Guest fields ──────────────────────────────────────────────
  final _gSinglePriceCtrl = TextEditingController();
  final _gSingleDepCtrl = TextEditingController();
  final _gDoublePriceCtrl = TextEditingController();
  final _gDoubleDepCtrl = TextEditingController();
  final _gFamilyPriceCtrl = TextEditingController();
  final _gFamilyDepCtrl = TextEditingController();

  // ── Completion checks ─────────────────────────────────────────
  bool get _photosComplete => _photoBytes.isNotEmpty;
  bool get _registryComplete => _registryBytes != null;
  bool get _nocComplete => _nocBytes != null;
  bool get _idComplete => _idFrontBytes != null && _idBackBytes != null;
  bool get _mediaComplete =>
      _photosComplete && _registryComplete && _nocComplete && _idComplete;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _locationCtrl,
      _landmarkCtrl,
      _descCtrl,
      _mapLinkCtrl,
      _plotIdCtrl,
      _plotSizeCtrl,
      _plotLengthCtrl,
      _plotWidthCtrl,
      _totalPriceCtrl,
      _totalRoomsCtrl,
      _acRoomsCtrl,
      _nonAcCtrl,
      _singlePriceCtrl,
      _singleDepCtrl,
      _doublePriceCtrl,
      _doubleDepCtrl,
      _gSinglePriceCtrl,
      _gSingleDepCtrl,
      _gDoublePriceCtrl,
      _gDoubleDepCtrl,
      _gFamilyPriceCtrl,
      _gFamilyDepCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // Opens Google Maps (searching the typed location) so the owner can find the
  // exact spot, then Share → Copy link, and paste it into the Maps link field.
  Future<void> _openMapsToCopyLink() async {
    final q = _locationCtrl.text.trim();
    final url = q.isEmpty
        ? 'https://www.google.com/maps'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // ── Pick photos (image_picker — works on web + mobile) ────────
  Future<void> _pickPhotos() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      for (final xf in picked) {
        final bytes = await xf.readAsBytes();
        if (mounted) {
          setState(() {
            _photoBytes.add(bytes);
            _photoNames.add(xf.name);
          });
        }
      }
    } catch (e) {
      _snack('Could not pick photos: $e', AppColors.error);
    }
  }

  // ── Pick a document (registry / noc) — image_picker ──────────
  Future<void> _pickDocument(String docType) async {
    try {
      final picker = ImagePicker();
      final xf =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xf == null) return;
      final bytes = await xf.readAsBytes();
      if (mounted) {
        setState(() {
          if (docType == 'registry') {
            _registryBytes = bytes;
            _registryName = xf.name;
          } else if (docType == 'noc') {
            _nocBytes = bytes;
            _nocName = xf.name;
          } else if (docType == 'idFront') {
            _idFrontBytes = bytes;
            _idFrontName = xf.name;
          } else if (docType == 'idBack') {
            _idBackBytes = bytes;
            _idBackName = xf.name;
          }
        });
      }
    } catch (e) {
      _snack('Could not pick document: $e', AppColors.error);
    }
  }

  // ── Build the type-specific details map for createProperty ─────
  Map<String, dynamic> _buildDetails() {
    if (_type == 'plot') {
      return {
        'plotId': _plotIdCtrl.text.trim(),
        'plotType': _plotType,
        'facing': _facing,
        'plotSize': _plotSizeCtrl.text,
        'plotLength': _plotLengthCtrl.text,
        'plotWidth': _plotWidthCtrl.text,
        'totalPrice': _totalPriceCtrl.text,
        'ownershipType': _ownershipType,
        'facilities': _facilities,
        'description': _descCtrl.text.trim(),
      };
    } else if (_type == 'pg') {
      return {
        'totalRooms': _totalRoomsCtrl.text,
        'acRooms': _acRoomsCtrl.text,
        'nonAcRooms': _nonAcCtrl.text,
        'occupancyType': _occupancy,
        'roomType': _roomType,
        'singlePrice': _singlePriceCtrl.text,
        'singleDeposit': _singleDepCtrl.text,
        'doublePrice': _doublePriceCtrl.text,
        'doubleDeposit': _doubleDepCtrl.text,
        'availableFor': _pgAvailFor,
        'facilities': _facilities,
        'commonKitchen': _commonKitchen,
        'privateKitchen': _privateKitchen,
        'description': _descCtrl.text.trim(),
      };
    } else {
      // guest
      return {
        'totalRooms': _totalRoomsCtrl.text,
        'acRooms': _acRoomsCtrl.text,
        'nonAcRooms': _nonAcCtrl.text,
        'singlePrice': _gSinglePriceCtrl.text,
        'singleDeposit': _gSingleDepCtrl.text,
        'doublePrice': _gDoublePriceCtrl.text,
        'doubleDeposit': _gDoubleDepCtrl.text,
        'familyPrice': _gFamilyPriceCtrl.text,
        'familyDeposit': _gFamilyDepCtrl.text,
        'facilities': _facilities,
        'commonKitchen': _commonKitchen,
        'privateKitchen': _privateKitchen,
        'description': _descCtrl.text.trim(),
      };
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ── Submit ────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      _snack('Please enter the property name and location', AppColors.error);
      return;
    }
    if (!_mediaComplete) {
      _snack(
          '⚠️ Please add at least 1 photo, the Registry document and the NOC document',
          AppColors.error);
      return;
    }

    setState(() => _saving = true);
    try {
      // 1. Create the property record
      final res = await ApiService.createProperty(
        propertyType: _type,
        propertyName: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        localLandmark: _landmarkCtrl.text.trim(),
        mapLink: _mapLinkCtrl.text.trim(),
        details: _buildDetails(),
      );

      final propertyId =
          (res['property']?['_id'] ?? res['property']?['id']) as String?;
      if (propertyId == null) {
        throw Exception('Property created but no ID was returned');
      }

      // 2. Upload photos
      if (_photoBytes.isNotEmpty) {
        await ApiService.uploadPropertyPhotos(
          propertyId: propertyId,
          imageBytes: _photoBytes,
          fileNames: _photoNames,
        );
      }

      // 3. Upload documents
      await ApiService.uploadDocuments(
        propertyId: propertyId,
        registryBytes: _registryBytes,
        registryFileName: _registryName,
        nocBytes: _nocBytes,
        nocFileName: _nocName,
        idType: _idType,
        idFrontBytes: _idFrontBytes,
        idFrontFileName: _idFrontName,
        idBackBytes: _idBackBytes,
        idBackFileName: _idBackName,
      );

      if (mounted) {
        _snack(
            '✅ Property submitted! It is now under review.', AppColors.success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = _type == 'pg'
        ? '🛏️ PG Room'
        : _type == 'guest'
            ? '🏨 Guest Room'
            : '🌿 Plot';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Property',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.textDark)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Property type selector ───────────────────────
            _TypeSelector(
              selected: _type,
              onChanged: (t) {
                setState(() {
                  _type = t;
                  // facilities differ per type — reset to avoid invalid carry-over
                  _facilities.clear();
                });
              },
            ),
            const SizedBox(height: 16),

            // ── Required uploads banner ──────────────────────
            if (!_mediaComplete) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE65100).withValues(alpha: 0.4)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFE65100), size: 18),
                        SizedBox(width: 8),
                        Text('Required uploads',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE65100))),
                      ]),
                      const SizedBox(height: 6),
                      if (!_photosComplete)
                        const Text('• Property photos (at least 1)',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFBF360C))),
                      if (!_registryComplete)
                        const Text('• Registry / ownership document',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFBF360C))),
                      if (!_nocComplete)
                        const Text('• NOC document',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFBF360C))),
                      if (!_idComplete)
                        const Text('• ID proof (Aadhaar/PAN) — front & back',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFBF360C))),
                    ]),
              ),
              const SizedBox(height: 16),
            ],

            // ── Photos section ───────────────────────────────
            _PhotosSection(
              photoBytes: _photoBytes,
              onAdd: _pickPhotos,
              onRemove: (i) => setState(() {
                _photoBytes.removeAt(i);
                _photoNames.removeAt(i);
              }),
            ),
            const SizedBox(height: 16),

            // ── Documents section ────────────────────────────
            _DocumentsSection(
              registryPicked: _registryBytes != null,
              registryName: _registryName,
              nocPicked: _nocBytes != null,
              nocName: _nocName,
              onPickRegistry: () => _pickDocument('registry'),
              onPickNoc: () => _pickDocument('noc'),
              onClearRegistry: () => setState(() {
                _registryBytes = null;
                _registryName = null;
              }),
              onClearNoc: () => setState(() {
                _nocBytes = null;
                _nocName = null;
              }),
              idType: _idType,
              onIdTypeChanged: (v) => setState(() => _idType = v),
              idFrontPicked: _idFrontBytes != null,
              idFrontName: _idFrontName,
              idBackPicked: _idBackBytes != null,
              idBackName: _idBackName,
              onPickIdFront: () => _pickDocument('idFront'),
              onPickIdBack: () => _pickDocument('idBack'),
              onClearIdFront: () => setState(() {
                _idFrontBytes = null;
                _idFrontName = null;
              }),
              onClearIdBack: () => setState(() {
                _idBackBytes = null;
                _idBackName = null;
              }),
            ),
            const SizedBox(height: 20),

            // ── Basic info ───────────────────────────────────
            _Section(title: 'Basic Info ($typeLabel)', children: [
              _Field(label: 'Property Name', ctrl: _nameCtrl),
              _Field(label: 'Location', ctrl: _locationCtrl),
              _Field(label: 'Local Landmark (optional)', ctrl: _landmarkCtrl),
              _Field(label: 'Google Maps link (optional)', ctrl: _mapLinkCtrl),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openMapsToCopyLink,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Find on Google Maps & copy link'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Tip: open Google Maps, find the exact spot, tap Share → Copy link, '
                  'and paste it above. Customers can tap it to open the location.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            if (_type == 'plot') ...[
              ..._plotFields(),
              const SizedBox(height: 16)
            ],
            if (_type == 'pg') ...[..._pgFields(), const SizedBox(height: 16)],
            if (_type == 'guest') ...[
              ..._guestFields(),
              const SizedBox(height: 16)
            ],

            _Section(title: 'Description', children: [
              _Field(
                  label: 'Description (optional)',
                  ctrl: _descCtrl,
                  maxLines: 3),
            ]),
            const SizedBox(height: 16),

            _FacilitiesEditor(
              selected: _facilities,
              type: _type,
              onChange: (v) => setState(() {
                _facilities
                  ..clear()
                  ..addAll(v);
              }),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _mediaComplete ? AppColors.primary : AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text(
                        _mediaComplete
                            ? 'Submit Property'
                            : 'Add required uploads to submit',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Type-specific field groups ────────────────────────────────
  List<Widget> _plotFields() => [
        _Section(title: 'Plot Details', children: [
          _Field(label: 'Plot ID (optional)', ctrl: _plotIdCtrl),
          _DropdownField(
              label: 'Plot Type',
              value: _plotType,
              options: const [
                'Agricultural',
                'Residential',
                'Commercial',
                'Industrial'
              ],
              onChanged: (v) => setState(() => _plotType = v)),
          _DropdownField(
              label: 'Facing',
              value: _facing,
              options: const [
                'North',
                'South',
                'East',
                'West',
                'North-East',
                'North-West',
                'South-East',
                'South-West'
              ],
              onChanged: (v) => setState(() => _facing = v)),
          _Field(
              label: 'Plot Size (sq ft)', ctrl: _plotSizeCtrl, numeric: true),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Length (ft)',
                    ctrl: _plotLengthCtrl,
                    numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(
                    label: 'Width (ft)', ctrl: _plotWidthCtrl, numeric: true)),
          ]),
          _Field(
              label: 'Total Price (₹)', ctrl: _totalPriceCtrl, numeric: true),
          _DropdownField(
              label: 'Ownership Type',
              value: _ownershipType,
              options: const ['Freehold', 'Leasehold', 'Cooperative'],
              onChanged: (v) => setState(() => _ownershipType = v)),
        ]),
      ];

  List<Widget> _pgFields() => [
        _Section(title: 'Room Details', children: [
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Total Rooms',
                    ctrl: _totalRoomsCtrl,
                    numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(
                    label: 'AC Rooms', ctrl: _acRoomsCtrl, numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _Field(label: 'Non-AC', ctrl: _nonAcCtrl, numeric: true)),
          ]),
          _DropdownField(
              label: 'Occupancy Type',
              value: _occupancy,
              options: const ['any', 'male', 'female'],
              onChanged: (v) => setState(() => _occupancy = v ?? 'any')),
          _DropdownField(
              label: 'Room Type',
              value: _roomType,
              options: const ['sharing', 'private'],
              onChanged: (v) => setState(() => _roomType = v ?? 'sharing')),
        ]),
        const SizedBox(height: 16),
        _Section(title: 'Pricing', children: [
          const _SubLabel('Single Room'),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Price/mo (₹)',
                    ctrl: _singlePriceCtrl,
                    numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(
                    label: 'Deposit (₹)', ctrl: _singleDepCtrl, numeric: true)),
          ]),
          const SizedBox(height: 4),
          const _SubLabel('Double Room'),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Price/mo (₹)',
                    ctrl: _doublePriceCtrl,
                    numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(
                    label: 'Deposit (₹)', ctrl: _doubleDepCtrl, numeric: true)),
          ]),
          const SizedBox(height: 4),
          _SwitchRow(
              label: 'Common Kitchen',
              value: _commonKitchen,
              onChanged: (v) => setState(() => _commonKitchen = v)),
          _SwitchRow(
              label: 'Private Kitchen',
              value: _privateKitchen,
              onChanged: (v) => setState(() => _privateKitchen = v)),
        ]),
      ];

  List<Widget> _guestFields() => [
        _Section(title: 'Room Details', children: [
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Total Rooms',
                    ctrl: _totalRoomsCtrl,
                    numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(
                    label: 'AC Rooms', ctrl: _acRoomsCtrl, numeric: true)),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _Field(label: 'Non-AC', ctrl: _nonAcCtrl, numeric: true)),
          ]),
        ]),
        const SizedBox(height: 16),
        _Section(title: 'Pricing per Night', children: [
          _PricingRow(
              label: 'Single Room',
              priceCtrl: _gSinglePriceCtrl,
              depCtrl: _gSingleDepCtrl),
          const SizedBox(height: 10),
          _PricingRow(
              label: 'Double Room',
              priceCtrl: _gDoublePriceCtrl,
              depCtrl: _gDoubleDepCtrl),
          const SizedBox(height: 10),
          _PricingRow(
              label: 'Family Room',
              priceCtrl: _gFamilyPriceCtrl,
              depCtrl: _gFamilyDepCtrl),
          const SizedBox(height: 4),
          _SwitchRow(
              label: 'Common Kitchen',
              value: _commonKitchen,
              onChanged: (v) => setState(() => _commonKitchen = v)),
          _SwitchRow(
              label: 'Private Kitchen',
              value: _privateKitchen,
              onChanged: (v) => setState(() => _privateKitchen = v)),
        ]),
      ];
}

// ── Property type selector ───────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final types = const [
      {'key': 'pg', 'label': 'PG Room', 'icon': '🛏️'},
      {'key': 'guest', 'label': 'Guest Room', 'icon': '🏨'},
      {'key': 'plot', 'label': 'Plot', 'icon': '🌿'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Property Type',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
            children: types.map((t) {
          final on = selected == t['key'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onChanged(t['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: on ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: on ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(children: [
                    Text(t['icon']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(t['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: on ? Colors.white : AppColors.textDark,
                        )),
                  ]),
                ),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }
}

// ── Photos Section (create flow) ─────────────────────────────────
class _PhotosSection extends StatelessWidget {
  final List<Uint8List> photoBytes;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  const _PhotosSection(
      {required this.photoBytes, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final hasAny = photoBytes.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (hasAny ? AppColors.primary : AppColors.error)
              .withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.add_photo_alternate_outlined,
              color: hasAny ? AppColors.primary : AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Property Photos',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasAny ? AppColors.textDark : AppColors.error))),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(hasAny ? 'Add More' : 'Add Photos',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        if (!hasAny) ...[
          const SizedBox(height: 10),
          const Text('At least 1 photo is required',
              style: TextStyle(fontSize: 12, color: AppColors.error)),
        ],
        if (hasAny) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoBytes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(clipBehavior: Clip.none, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(photoBytes[i],
                      width: 80, height: 80, fit: BoxFit.cover),
                ),
                Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            size: 12, color: Colors.white),
                      ),
                    )),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Documents Section (create flow) ──────────────────────────────
class _DocumentsSection extends StatelessWidget {
  final bool registryPicked, nocPicked;
  final String? registryName, nocName;
  final VoidCallback onPickRegistry, onPickNoc, onClearRegistry, onClearNoc;
  final String idType;
  final ValueChanged<String> onIdTypeChanged;
  final bool idFrontPicked, idBackPicked;
  final String? idFrontName, idBackName;
  final VoidCallback onPickIdFront, onPickIdBack, onClearIdFront, onClearIdBack;
  const _DocumentsSection({
    required this.registryPicked,
    required this.registryName,
    required this.nocPicked,
    required this.nocName,
    required this.onPickRegistry,
    required this.onPickNoc,
    required this.onClearRegistry,
    required this.onClearNoc,
    required this.idType,
    required this.onIdTypeChanged,
    required this.idFrontPicked,
    required this.idFrontName,
    required this.idBackPicked,
    required this.idBackName,
    required this.onPickIdFront,
    required this.onPickIdBack,
    required this.onClearIdFront,
    required this.onClearIdBack,
  });

  @override
  Widget build(BuildContext context) {
    final idDone = idFrontPicked && idBackPicked;
    final allDone = registryPicked && nocPicked && idDone;
    final idLabel = idType == 'pan' ? 'PAN' : 'Aadhaar';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (allDone ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.description_outlined,
              color: allDone ? AppColors.success : AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Legal Documents',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: allDone ? AppColors.textDark : AppColors.error))),
        ]),
        const SizedBox(height: 14),
        _DocRow(
          label: 'Registry / Ownership Document',
          isPicked: registryPicked,
          pickedName: registryName,
          onPick: onPickRegistry,
          onClear: onClearRegistry,
        ),
        const SizedBox(height: 10),
        _DocRow(
          label: 'NOC Document',
          isPicked: nocPicked,
          pickedName: nocName,
          onPick: onPickNoc,
          onClear: onClearNoc,
        ),

        // ── ID Proof (Aadhaar / PAN) ───────────────────────────
        const SizedBox(height: 18),
        const Divider(height: 1),
        const SizedBox(height: 14),
        Row(children: [
          Icon(idDone ? Icons.verified_user : Icons.badge_outlined,
              color: idDone ? AppColors.success : AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Owner ID Proof',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: idDone ? AppColors.textDark : AppColors.error))),
        ]),
        const SizedBox(height: 4),
        const Text('Upload front & back of one ID — Aadhaar or PAN card.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        // type toggle
        Row(children: [
          _IdTypeChip(
              label: 'Aadhaar Card',
              value: 'aadhaar',
              selected: idType == 'aadhaar',
              onTap: () => onIdTypeChanged('aadhaar')),
          const SizedBox(width: 8),
          _IdTypeChip(
              label: 'PAN Card',
              value: 'pan',
              selected: idType == 'pan',
              onTap: () => onIdTypeChanged('pan')),
        ]),
        const SizedBox(height: 10),
        _DocRow(
          label: '$idLabel — Front',
          isPicked: idFrontPicked,
          pickedName: idFrontName,
          onPick: onPickIdFront,
          onClear: onClearIdFront,
        ),
        const SizedBox(height: 10),
        _DocRow(
          label: '$idLabel — Back',
          isPicked: idBackPicked,
          pickedName: idBackName,
          onPick: onPickIdBack,
          onClear: onClearIdBack,
        ),
      ]),
    );
  }
}

// ── ID type selector chip ────────────────────────────────────────
class _IdTypeChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _IdTypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textDark)),
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final String label;
  final bool isPicked;
  final String? pickedName;
  final VoidCallback onPick, onClear;
  const _DocRow({
    required this.label,
    required this.isPicked,
    required this.pickedName,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPicked ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPicked
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(children: [
        Icon(isPicked ? Icons.file_present_rounded : Icons.upload_file_rounded,
            color: isPicked ? AppColors.primary : AppColors.textLight,
            size: 22),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          if (isPicked)
            Text(pickedName ?? 'File selected',
                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
          else
            const Text('Required — tap to upload',
                style: TextStyle(fontSize: 11, color: AppColors.error)),
        ])),
        if (isPicked)
          GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, color: AppColors.error, size: 18))
        else
          TextButton(
            onPressed: onPick,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Upload',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}

// ── Shared form widgets ──────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1) spaced.add(const SizedBox(height: 10));
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        ...spaced,
      ]),
    );
  }
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool numeric;
  final int maxLines;
  const _Field(
      {required this.label,
      required this.ctrl,
      this.numeric = false,
      this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: AppColors.background,
        ),
      );
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final void Function(String?) onChanged;
  const _DropdownField(
      {required this.label,
      required this.value,
      required this.options,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        value: options.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: AppColors.background,
        ),
        items: options
            .map((o) => DropdownMenuItem(
                value: o, child: Text(o, style: const TextStyle(fontSize: 14))))
            .toList(),
        onChanged: onChanged,
      );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
          Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
              thumbColor: WidgetStateProperty.all(Colors.white)),
        ],
      );
}

class _PricingRow extends StatelessWidget {
  final String label;
  final TextEditingController priceCtrl, depCtrl;
  const _PricingRow(
      {required this.label, required this.priceCtrl, required this.depCtrl});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child:
                  _Field(label: 'Price (₹)', ctrl: priceCtrl, numeric: true)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  _Field(label: 'Deposit (₹)', ctrl: depCtrl, numeric: true)),
        ]),
      ]);
}

class _FacilitiesEditor extends StatelessWidget {
  final List<String> selected;
  final String type;
  final void Function(List<String>) onChange;
  const _FacilitiesEditor(
      {required this.selected, required this.type, required this.onChange});
  @override
  Widget build(BuildContext context) {
    final all = type == 'plot'
        ? [
            'Road Access',
            'Water Supply',
            'Electricity',
            'Sewage',
            'Boundary Wall',
            'Gated Community',
            'Parking'
          ]
        : [
            'WiFi',
            'Parking',
            'AC',
            'Laundry',
            'CCTV',
            'Security',
            'Power Backup',
            'Water Supply',
            'Gym',
            'Common Room'
          ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Facilities',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: all.map((f) {
              final on = selected.contains(f);
              return GestureDetector(
                onTap: () {
                  final updated = List<String>.from(selected);
                  if (on) {
                    updated.remove(f);
                  } else {
                    updated.add(f);
                  }
                  onChange(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: on ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: on ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: on ? Colors.white : AppColors.textDark,
                      )),
                ),
              );
            }).toList()),
      ]),
    );
  }
}
