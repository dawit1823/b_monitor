import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cloud_data_models.dart';

class ReadProfile extends StatelessWidget {
  final CloudProfile profile;

  const ReadProfile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
                const Divider(
                  color: Colors.grey,
                  height: 40,
                  thickness: 1,
                ),
                _buildProfileDetail(
                    icon: Icons.business,
                    label: 'Company Name',
                    value: profile.companyName),
                _buildProfileDetail(
                    icon: Icons.person,
                    label: 'Full Name',
                    value: '${profile.firstName} ${profile.lastName}'),
                _buildProfileDetail(
                    icon: Icons.confirmation_number,
                    label: 'TIN',
                    value: profile.tin),
                _buildProfileDetail(
                    icon: Icons.email,
                    label: 'Email',
                    value: profile.email,
                    isEmail: true),
                _buildProfileDetail(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: profile.phoneNumber,
                    isPhoneNumber: true),
                _buildProfileDetail(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: profile.address),
                _buildProfileDetail(
                    icon: Icons.file_copy,
                    label: 'Contract Info',
                    value: profile.contractInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.teal,
          child: Text(
            profile.firstName[0] + profile.lastName[0],
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${profile.firstName} ${profile.lastName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.companyName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetail({
    required IconData icon,
    required String label,
    required String value,
    bool isEmail = false,
    bool isPhoneNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (isEmail) {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: value,
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                } else if (isPhoneNumber) {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: value,
                  );
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          isEmail || isPhoneNumber ? Colors.teal : Colors.black,
                      decoration: isEmail || isPhoneNumber
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
