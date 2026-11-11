import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/blood_request.dart';
import '../models/donor.dart';
import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _requesterController;
  final _patientController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _notesController = TextEditingController();

  String _bloodGroup = 'O+';
  int _units = 1;
  RequestUrgency _urgency = RequestUrgency.normal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _requesterController = TextEditingController(
      text: context.read<AuthProvider>().user?.name ?? '',
    );
  }

  @override
  void dispose() {
    _requesterController.dispose();
    _patientController.dispose();
    _cityController.dispose();
    _contactController.dispose();
    _hospitalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final request = BloodRequest(
      id: const Uuid().v4(),
      requesterName: _requesterController.text.trim(),
      patientName: _patientController.text.trim(),
      bloodGroup: _bloodGroup,
      city: _cityController.text.trim(),
      units: _units,
      contactPhone: _contactController.text.trim(),
      hospital: _optional(_hospitalController.text),
      urgency: _urgency,
      notes: _optional(_notesController.text),
      status: RequestStatus.open,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<RequestProvider>().addRequest(request);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not post request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New blood request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const _SectionLabel('Patient'),
            TextFormField(
              controller: _patientController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Patient name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the patient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _bloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood group',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items: kBloodGroups
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _bloodGroup = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _units,
                    decoration: const InputDecoration(
                      labelText: 'Units',
                      prefixIcon: Icon(Icons.water_drop_outlined),
                    ),
                    items: const [1, 2, 3, 4, 5, 6]
                        .map(
                          (units) => DropdownMenuItem(
                            value: units,
                            child: Text('$units'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _units = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the city';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _hospitalController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Hospital (optional)',
                prefixIcon: Icon(Icons.local_hospital_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<RequestUrgency>(
              initialValue: _urgency,
              decoration: const InputDecoration(
                labelText: 'Urgency',
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: RequestUrgency.values
                  .map(
                    (urgency) => DropdownMenuItem(
                      value: urgency,
                      child: Text(urgency.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _urgency = value);
              },
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Contact'),
            TextFormField(
              controller: _requesterController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Requester name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the requester name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Contact phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.isEmpty) return 'Enter a contact number';
                if (digits.length < 7) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Additional notes (optional)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.campaign_outlined),
                label: const Text('Post request'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Donors with compatible blood groups in this city will be '
              'shown first when you search for matches.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
