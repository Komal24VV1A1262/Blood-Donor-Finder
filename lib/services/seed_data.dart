import '../models/donation.dart';
import '../models/donor.dart';

/// Initial data inserted the first time the database is created.
class SeedData {
  SeedData._();

  static const String demoEmail = 'demo@bloodlink.app';
  static const String demoPassword = 'demo1234';
  static const String demoName = 'Demo User';
  static const String demoUserId = 'demo-user';

  static List<Donor> donors() {
    final createdAt = DateTime(2026, 1, 1);
    Donor make({
      required String id,
      required String name,
      required String bloodGroup,
      required String city,
      required String phone,
      required String email,
      DateTime? lastDonationDate,
      bool isAvailable = true,
      bool isFavorite = false,
      String? notes,
    }) {
      return Donor(
        id: id,
        name: name,
        bloodGroup: bloodGroup,
        city: city,
        phone: phone,
        email: email,
        notes: notes,
        lastDonationDate: lastDonationDate,
        isAvailable: isAvailable,
        isFavorite: isFavorite,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
    }

    return [
      make(
        id: 'seed-1',
        name: 'Aarav Sharma',
        bloodGroup: 'O+',
        city: 'Mumbai',
        phone: '+91 98200 12345',
        email: 'aarav.sharma@example.com',
        lastDonationDate: DateTime(2026, 6, 12),
        isFavorite: true,
        notes: 'Regular donor, prefers morning appointments.',
      ),
      make(
        id: 'seed-2',
        name: 'Priya Patel',
        bloodGroup: 'A+',
        city: 'Mumbai',
        phone: '+91 98200 54321',
        email: 'priya.patel@example.com',
      ),
      make(
        id: 'seed-3',
        name: 'Rahul Verma',
        bloodGroup: 'B+',
        city: 'Delhi',
        phone: '+91 98110 22334',
        email: 'rahul.verma@example.com',
        lastDonationDate: DateTime(2026, 9, 25),
      ),
      make(
        id: 'seed-4',
        name: 'Sneha Reddy',
        bloodGroup: 'O-',
        city: 'Hyderabad',
        phone: '+91 99850 44556',
        email: 'sneha.reddy@example.com',
        lastDonationDate: DateTime(2026, 3, 1),
        isFavorite: true,
      ),
      make(
        id: 'seed-5',
        name: 'Vikram Singh',
        bloodGroup: 'AB+',
        city: 'Delhi',
        phone: '+91 98110 77889',
        email: 'vikram.singh@example.com',
        lastDonationDate: DateTime(2026, 10, 20),
      ),
      make(
        id: 'seed-6',
        name: 'Ananya Iyer',
        bloodGroup: 'A-',
        city: 'Bengaluru',
        phone: '+91 98860 33445',
        email: 'ananya.iyer@example.com',
        lastDonationDate: DateTime(2026, 7, 15),
      ),
      make(
        id: 'seed-7',
        name: 'Karan Malhotra',
        bloodGroup: 'B-',
        city: 'Pune',
        phone: '+91 90220 66778',
        email: 'karan.malhotra@example.com',
        lastDonationDate: DateTime(2026, 11, 1),
        isAvailable: false,
      ),
      make(
        id: 'seed-8',
        name: 'Meera Nair',
        bloodGroup: 'AB-',
        city: 'Kochi',
        phone: '+91 98470 99880',
        email: 'meera.nair@example.com',
      ),
      make(
        id: 'seed-9',
        name: 'Rohan Das',
        bloodGroup: 'O+',
        city: 'Kolkata',
        phone: '+91 98300 11223',
        email: 'rohan.das@example.com',
        lastDonationDate: DateTime(2026, 5, 30),
      ),
      make(
        id: 'seed-10',
        name: 'Ishita Gupta',
        bloodGroup: 'A+',
        city: 'Jaipur',
        phone: '+91 98290 55667',
        email: 'ishita.gupta@example.com',
        lastDonationDate: DateTime(2026, 8, 1),
      ),
      make(
        id: 'seed-11',
        name: 'Arjun Rao',
        bloodGroup: 'B+',
        city: 'Bengaluru',
        phone: '+91 99450 12390',
        email: 'arjun.rao@example.com',
        lastDonationDate: DateTime(2026, 4, 18),
      ),
      make(
        id: 'seed-12',
        name: 'Fatima Khan',
        bloodGroup: 'O-',
        city: 'Delhi',
        phone: '+91 98990 45612',
        email: 'fatima.khan@example.com',
      ),
      make(
        id: 'seed-13',
        name: 'Daniel Mathew',
        bloodGroup: 'A+',
        city: 'Kochi',
        phone: '+91 98460 77123',
        email: 'daniel.mathew@example.com',
        lastDonationDate: DateTime(2026, 9, 5),
      ),
      make(
        id: 'seed-14',
        name: 'Neha Joshi',
        bloodGroup: 'AB+',
        city: 'Mumbai',
        phone: '+91 98210 88991',
        email: 'neha.joshi@example.com',
      ),
    ];
  }

  static List<Donation> donations() {
    final now = DateTime(2026, 1, 1);
    return [
      Donation(
        id: 'donation-1',
        donorId: 'seed-1',
        donationDate: DateTime(2026, 6, 12),
        units: 1,
        location: 'City Blood Bank, Mumbai',
        notes: 'Whole blood donation.',
        createdAt: now,
      ),
      Donation(
        id: 'donation-2',
        donorId: 'seed-1',
        donationDate: DateTime(2026, 1, 5),
        units: 1,
        location: 'Red Cross Centre, Mumbai',
        createdAt: now,
      ),
      Donation(
        id: 'donation-3',
        donorId: 'seed-4',
        donationDate: DateTime(2026, 3, 1),
        units: 1,
        location: 'Apollo Hospital, Hyderabad',
        createdAt: now,
      ),
      Donation(
        id: 'donation-4',
        donorId: 'seed-4',
        donationDate: DateTime(2025, 9, 20),
        units: 1,
        location: 'Apollo Hospital, Hyderabad',
        createdAt: now,
      ),
      Donation(
        id: 'donation-5',
        donorId: 'seed-9',
        donationDate: DateTime(2026, 5, 30),
        units: 1,
        location: 'City Blood Bank, Kolkata',
        createdAt: now,
      ),
      Donation(
        id: 'donation-6',
        donorId: 'seed-11',
        donationDate: DateTime(2026, 4, 18),
        units: 1,
        location: 'Manipal Hospital, Bengaluru',
        createdAt: now,
      ),
    ];
  }
}
