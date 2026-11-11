import 'package:blood_donor_finder/models/donor.dart';

class SeedData {
  static const bloodGroups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  static List<Donor> donors() {
    return [
      Donor(id: '1', name: 'Ahmed Khan', bloodGroup: 'O+', city: 'Karachi', phone: '03001234567', lastDonationDate: '2026-06-15'),
      Donor(id: '2', name: 'Sara Ali', bloodGroup: 'O-', city: 'Lahore', phone: '03011234567', lastDonationDate: '2026-05-20'),
      Donor(id: '3', name: 'Bilal Hussain', bloodGroup: 'A+', city: 'Islamabad', phone: '03021234567', lastDonationDate: '2026-04-10'),
      Donor(id: '4', name: 'Ayesha Malik', bloodGroup: 'A-', city: 'Karachi', phone: '03031234567', lastDonationDate: '2026-07-01'),
      Donor(id: '5', name: 'Usman Tariq', bloodGroup: 'B+', city: 'Faisalabad', phone: '03041234567', lastDonationDate: '2026-03-25'),
      Donor(id: '6', name: 'Fatima Noor', bloodGroup: 'AB+', city: 'Lahore', phone: '03051234567', lastDonationDate: '2026-06-30'),
      Donor(id: '7', name: 'Hassan Raza', bloodGroup: 'O+', city: 'Peshawar', phone: '03061234567', lastDonationDate: '2026-02-18'),
      Donor(id: '8', name: 'Zainab Iqbal', bloodGroup: 'B-', city: 'Rawalpindi', phone: '03071234567', lastDonationDate: '2026-05-05'),
      Donor(id: '9', name: 'Omar Farooq', bloodGroup: 'A+', city: 'Karachi', phone: '03081234567', lastDonationDate: '2026-01-12'),
      Donor(id: '10', name: 'Maria Joseph', bloodGroup: 'O+', city: 'Multan', phone: '03091234567', lastDonationDate: '2026-07-08'),
      Donor(id: '11', name: 'Ali Akbar', bloodGroup: 'AB+', city: 'Hyderabad', phone: '03101234567', lastDonationDate: '2026-04-22'),
      Donor(id: '12', name: 'Hina Shahid', bloodGroup: 'A-', city: 'Islamabad', phone: '03111234567', lastDonationDate: '2026-06-02'),
    ];
  }
}