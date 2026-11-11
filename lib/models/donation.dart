/// A recorded blood donation.
class Donation {
  final String id;
  final String donorId;
  final DateTime donationDate;
  final int units;
  final String? location;
  final String? notes;
  final DateTime createdAt;

  const Donation({
    required this.id,
    required this.donorId,
    required this.donationDate,
    this.units = 1,
    this.location,
    this.notes,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'donor_id': donorId,
      'donation_date': donationDate.toIso8601String(),
      'units': units,
      'location': location,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Donation.fromMap(Map<String, Object?> map) {
    return Donation(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      donationDate:
          DateTime.tryParse(map['donation_date'] as String) ?? DateTime.now(),
      units: (map['units'] as int?) ?? 1,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
    );
  }
}
