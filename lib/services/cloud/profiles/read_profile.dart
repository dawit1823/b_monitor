import 'dart:ui';

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
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(
                    alpha: 0.2), // Optional tint for better contrast
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Card(
              elevation: 8.0,
              color: Colors.white.withValues(alpha: 0.1),
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
                      color: Colors.white,
                      height: 40,
                      thickness: 1,
                    ),
                    _buildProfileDetail(
                      icon: Icons.business,
                      label: 'Company Name',
                      value: profile.companyName,
                    ),
                    _buildProfileDetail(
                      icon: Icons.person,
                      label: 'Full Name',
                      value: '${profile.firstName} ${profile.lastName}',
                    ),
                    _buildProfileDetail(
                      icon: Icons.confirmation_number,
                      label: 'TIN',
                      value: profile.tin,
                    ),
                    _buildProfileDetail(
                      icon: Icons.email,
                      label: 'Email',
                      value: profile.email,
                      isEmail: true,
                    ),
                    _buildProfileDetail(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: profile.phoneNumber,
                      isPhoneNumber: true,
                    ),
                    _buildProfileDetail(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: profile.address,
                    ),
                    _buildProfileDetail(
                      icon: Icons.file_copy,
                      label: 'Contract Info',
                      value: profile.contractInfo,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.lightBlue,
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
              selectionColor: Colors.black,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.companyName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
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
          Icon(icon, color: Colors.lightBlue),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      backgroundColor: isEmail || isPhoneNumber
                          ? Colors.black
                          : Colors.transparent,
                      color: isEmail || isPhoneNumber
                          ? Colors.lightBlue
                          : Colors.white,
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
