import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/models/donor.dart';
import 'package:blood_donor_finder/providers/auth_provider.dart';
import 'package:blood_donor_finder/providers/donor_list_provider.dart';
import 'package:blood_donor_finder/services/seed_data.dart';
import 'package:blood_donor_finder/theme.dart';

class AddEditDonorScreen extends ConsumerStatefulWidget {
  final Donor? donor;

  const AddEditDonorScreen({super.key, this.donor});

  @override
  ConsumerState<AddEditDonorScreen> createState() => _AddEditDonorScreenState();
}

class _AddEditDonorScreenState extends ConsumerState<AddEditDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  String? _bloodGroup;
  String? _lastDonationDate;
  bool _saving = false;
  String? _profileId;

  bool get _isEditing => widget.donor != null;

  @override
  void initState() {
    super.initState();
    final donor = widget.donor;
    _nameController = TextEditingController(text: donor?.name ?? '');
    _cityController = TextEditingController(text: donor?.city ?? '');
    _phoneController = TextEditingController(text: donor?.phone ?? '');
    _bloodGroup = donor?.bloodGroup;
    _lastDonationDate = donor?.lastDonationDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _setProfileId() {
    if (_profileId != null) return;
    final authEmail = ref.read(authEmailProvider);
    _profileId = _isEditing ? widget.donor!.id : (authEmail ?? 'profile-${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(_lastDonationDate) ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      helpText: 'Select last donation date',
    );
    if (picked != null) {
      setState(() {
        _lastDonationDate = _formatDate(picked);
      });
    }
  }

  DateTime? _parseDate(String? date) {
    if (date == null) return null;
    final parts = date.split('-');
    if (parts.length != 3) return null;
    return DateTime.tryParse(date);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }
    if (_lastDonationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the last donation date')),
      );
      return;
    }

    setState(() => _saving = true);
    _setProfileId();

    final donor = Donor(
      id: _profileId!,
      name: _nameController.text.trim(),
      bloodGroup: _bloodGroup!,
      city: _cityController.text.trim(),
      phone: _phoneController.text.trim(),
      lastDonationDate: _lastDonationDate!,
    );

    final notifier = ref.read(donorListProvider.notifier);
    if (_isEditing) {
      await notifier.updateDonor(donor);
    } else {
      await notifier.addDonor(donor);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Profile' : 'Create Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _bloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items: SeedData.bloodGroups
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => setState(() => _bloodGroup = value),
                  validator: (value) => value == null ? 'Select your blood group' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'City is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 10) {
                      return 'Enter a valid phone number (at least 10 digits)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _DonationDateField(
                  date: _lastDonationDate,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Create Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonationDateField extends StatelessWidget {
  final String? date;
  final VoidCallback onTap;

  const _DonationDateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Last Donation Date',
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          date ?? 'Tap to select a date',
          style: TextStyle(
            color: date == null ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}