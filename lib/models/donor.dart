/// A registered blood donor.
class Donor {
  /// Minimum days between whole-blood donations.
  static const int eligibilityDays = 90;

  final String id;
  final String? ownerUserId;
  final String name;
  final String bloodGroup;
  final String city;
  final String phone;
  final String? email;
  final String? notes;
  final DateTime? lastDonationDate;
  final bool isAvailable;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Donor({
    required this.id,
    this.ownerUserId,
    required this.name,
    required this.bloodGroup,
    required this.city,
    required this.phone,
    this.email,
    this.notes,
    this.lastDonationDate,
    this.isAvailable = true,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DateTime? get nextEligibleDate {
    final last = lastDonationDate;
    if (last == null) return null;
    return last.add(const Duration(days: eligibilityDays));
  }

  bool isEligibleAt(DateTime now) {
    final next = nextEligibleDate;
    if (next == null) return true;
    return !now.isBefore(next);
  }

  bool get isEligible => isEligibleAt(DateTime.now());

  /// Donor has declared availability and is medically eligible.
  bool get isReadyToDonate => isAvailable && isEligible;

  int daysUntilEligibleAt(DateTime now) {
    final next = nextEligibleDate;
    if (next == null) return 0;
    final diff = next.difference(now);
    if (diff.isNegative) return 0;
    return diff.inHours <= 0 ? 0 : (diff.inHours / 24).ceil();
  }

  int get daysUntilEligible => daysUntilEligibleAt(DateTime.now());

  Donor copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    String? bloodGroup,
    String? city,
    String? phone,
    String? email,
    String? notes,
    DateTime? lastDonationDate,
    bool? isAvailable,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Donor(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'name': name,
      'blood_group': bloodGroup,
      'city': city,
      'phone': phone,
      'email': email,
      'notes': notes,
      'last_donation_date': lastDonationDate?.toIso8601String(),
      'is_available': isAvailable ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Donor.fromMap(Map<String, Object?> map) {
    return Donor(
      id: map['id'] as String,
      ownerUserId: map['owner_user_id'] as String?,
      name: map['name'] as String,
      bloodGroup: map['blood_group'] as String,
      city: map['city'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      notes: map['notes'] as String?,
      lastDonationDate: _parseDate(map['last_donation_date']),
      isAvailable: (map['is_available'] as int? ?? 1) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updated_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}

const List<String> kBloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];
