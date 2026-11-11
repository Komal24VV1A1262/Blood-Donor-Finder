import '../models/donor.dart';

/// Blood group compatibility rules.
///
/// Defines which donor blood groups can safely donate to a given recipient.
class BloodCompatibility {
  BloodCompatibility._();

  /// Map of donor group -> recipient groups that group can donate to.
  static const Map<String, List<String>> _canDonateTo = {
    'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
    'O+': ['O+', 'A+', 'B+', 'AB+'],
    'A-': ['A-', 'A+', 'AB-', 'AB+'],
    'A+': ['A+', 'AB+'],
    'B-': ['B-', 'B+', 'AB-', 'AB+'],
    'B+': ['B+', 'AB+'],
    'AB-': ['AB-', 'AB+'],
    'AB+': ['AB+'],
  };

  /// Recipient groups that [donorGroup] can donate to.
  static List<String> canDonateTo(String donorGroup) {
    return List<String>.unmodifiable(_canDonateTo[donorGroup] ?? const []);
  }

  /// All donor groups that can donate to [recipientGroup].
  static List<String> compatibleDonorGroups(String recipientGroup) {
    return kBloodGroups
        .where((donor) => canDonate(donor, recipientGroup))
        .toList(growable: false);
  }

  /// Whether a donor with [donorGroup] can donate to [recipientGroup].
  static bool canDonate(String donorGroup, String recipientGroup) {
    return _canDonateTo[donorGroup]?.contains(recipientGroup) ?? false;
  }
}
