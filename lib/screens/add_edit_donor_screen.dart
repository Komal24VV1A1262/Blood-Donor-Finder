import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/donor.dart';
import '../providers/auth_provider.dart';
import '../providers/donor_provider.dart';
import '../theme.dart';
import '../utils/formatters.dart';

class AddEditDonorScreen extends StatefulWidget {
  final String? donorId;

  const AddEditDonorScreen({super.key, this.donorId});

  @override
  State<AddEditDonorScreen> createState() => _AddEditDonorScreenState();
}

class _AddEditDonorScreenState extends State<AddEditDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  String _bloodGroup = 'O+';
  bool _isAvailable = true;
  DateTime? _lastDonationDate;
  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.donorId != null;
    if (_isEditing) {
      final donor = context.read<DonorProvider>().getById(widget.donorId!);
      if (donor != null) {
        _nameController.text = donor.name;
        _cityController.text = donor.city;
        _phoneController.text = donor.phone;
        _emailController.text = donor.email ?? '';
        _notesController.text = donor.notes ?? '';
        _bloodGroup = donor.bloodGroup;
        _isAvailable = donor.isAvailable;
        _lastDonationDate = donor.lastDonationDate;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickLastDonationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Last donation date',
    );
    if (picked != null) {
      setState(() => _lastDonationDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final provider = context.read<DonorProvider>();
    final auth = context.read<AuthProvider>();
    final now = DateTime.now();
    final existing = _isEditing
        ? provider.getById(widget.donorId!)
        : null;

    final donor = Donor(
      id: _isEditing ? widget.donorId! : const Uuid().v4(),
      ownerUserId: existing?.ownerUserId ?? auth.user?.id,
      name: _nameController.text.trim(),
      bloodGroup: _bloodGroup,
      city: _cityController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _trimmedOrNull(_emailController.text),
      notes: _trimmedOrNull(_notesController.text),
      lastDonationDate: _lastDonationDate,
      isAvailable: _isAvailable,
      isFavorite: existing?.isFavorite ?? false,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await provider.updateDonor(donor);
      } else {
        await provider.addDonor(donor);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save donor. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete donor?'),
        content: const Text(
          'This removes the donor and all recorded donations permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await context.read<DonorProvider>().deleteDonor(widget.donorId!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete donor.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _trimmedOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit donor' : 'Add donor'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete donor',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const _FieldLabel('Basic information'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return 'Enter the donor name';
                if (name.length < 2) return 'Name is too short';
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
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
            const SizedBox(height: 24),
            const _FieldLabel('Contact details'),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                final digits =
                    (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.isEmpty) return 'Enter a phone number';
                if (digits.length < 7) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return null;
                final valid =
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                return valid ? null : 'Enter a valid email address';
              },
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Donation information'),
            _DateField(
              label: 'Last donation date',
              value: _lastDonationDate,
              onTap: _saving ? null : _pickLastDonationDate,
              onClear: _saving || _lastDonationDate == null
                  ? null
                  : () => setState(() => _lastDonationDate = null),
            ),
            const SizedBox(height: 8),
            Text(
              'Donors become eligible again ${Donor.eligibilityDays} days '
              'after their last donation.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isAvailable,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _isAvailable = value),
              title: const Text('Available for donation'),
              subtitle: const Text(
                'Turn off if the donor is temporarily unavailable',
              ),
              activeThumbColor: AppTheme.bloodRed,
              contentPadding: EdgeInsets.zero,
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
                    : const Icon(Icons.save_outlined),
                label: Text(_isEditing ? 'Update donor' : 'Add donor'),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete donor'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  tooltip: 'Clear date',
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
        ),
        child: Text(
          value == null ? 'Not recorded' : formatDate(value),
          style: TextStyle(
            fontSize: 15,
            color: value == null ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
