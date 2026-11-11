enum RequestUrgency { normal, urgent, critical }

enum RequestStatus { open, fulfilled, cancelled }

extension RequestUrgencyX on RequestUrgency {
  String get label {
    switch (this) {
      case RequestUrgency.normal:
        return 'Normal';
      case RequestUrgency.urgent:
        return 'Urgent';
      case RequestUrgency.critical:
        return 'Critical';
    }
  }

  static RequestUrgency fromDb(String? value) {
    return RequestUrgency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RequestUrgency.normal,
    );
  }
}

extension RequestStatusX on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.open:
        return 'Open';
      case RequestStatus.fulfilled:
        return 'Fulfilled';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  static RequestStatus fromDb(String? value) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RequestStatus.open,
    );
  }
}

/// A request for blood from a patient or hospital.
class BloodRequest {
  final String id;
  final String requesterName;
  final String patientName;
  final String bloodGroup;
  final String city;
  final int units;
  final String contactPhone;
  final String? hospital;
  final RequestUrgency urgency;
  final String? notes;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? fulfilledAt;

  const BloodRequest({
    required this.id,
    required this.requesterName,
    required this.patientName,
    required this.bloodGroup,
    required this.city,
    this.units = 1,
    required this.contactPhone,
    this.hospital,
    this.urgency = RequestUrgency.normal,
    this.notes,
    this.status = RequestStatus.open,
    required this.createdAt,
    this.fulfilledAt,
  });

  bool get isOpen => status == RequestStatus.open;

  BloodRequest copyWith({
    RequestStatus? status,
    DateTime? fulfilledAt,
  }) {
    return BloodRequest(
      id: id,
      requesterName: requesterName,
      patientName: patientName,
      bloodGroup: bloodGroup,
      city: city,
      units: units,
      contactPhone: contactPhone,
      hospital: hospital,
      urgency: urgency,
      notes: notes,
      status: status ?? this.status,
      createdAt: createdAt,
      fulfilledAt: fulfilledAt ?? this.fulfilledAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'requester_name': requesterName,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'city': city,
      'units': units,
      'contact_phone': contactPhone,
      'hospital': hospital,
      'urgency': urgency.name,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'fulfilled_at': fulfilledAt?.toIso8601String(),
    };
  }

  factory BloodRequest.fromMap(Map<String, Object?> map) {
    return BloodRequest(
      id: map['id'] as String,
      requesterName: map['requester_name'] as String,
      patientName: map['patient_name'] as String,
      bloodGroup: map['blood_group'] as String,
      city: map['city'] as String,
      units: (map['units'] as int?) ?? 1,
      contactPhone: map['contact_phone'] as String,
      hospital: map['hospital'] as String?,
      urgency: RequestUrgencyX.fromDb(map['urgency'] as String?),
      notes: map['notes'] as String?,
      status: RequestStatusX.fromDb(map['status'] as String?),
      createdAt:
          DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
      fulfilledAt: map['fulfilled_at'] == null
          ? null
          : DateTime.tryParse(map['fulfilled_at'] as String),
    );
  }
}
