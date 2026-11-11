class Donor {
  final String id;
  final String name;
  final String bloodGroup;
  final String city;
  final String phone;
  final String lastDonationDate;

  const Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.city,
    required this.phone,
    required this.lastDonationDate,
  });

  Donor copyWith({
    String? id,
    String? name,
    String? bloodGroup,
    String? city,
    String? phone,
    String? lastDonationDate,
  }) {
    return Donor(
      id: id ?? this.id,
      name: name ?? this.name,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bloodGroup': bloodGroup,
      'city': city,
      'phone': phone,
      'lastDonationDate': lastDonationDate,
    };
  }

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] as String,
      name: json['name'] as String,
      bloodGroup: json['bloodGroup'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      lastDonationDate: json['lastDonationDate'] as String,
    );
  }
}