//rent_overdue_reminder.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_rent_page.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

class RentOverdueReminder extends StatefulWidget {
  const RentOverdueReminder({super.key});

  @override
  State<RentOverdueReminder> createState() => _RentOverdueReminderState();
}

class _RentOverdueReminderState extends State<RentOverdueReminder> {
  late final RentService _rentService;
  late final PropertyService _propertyService;
  Map<String, String> _companyNames = {};
  List<CloudProfile> _profiles = [];
  List<CloudProperty> _properties = [];
  bool _isInitialized = false;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _rentService = RentService();
    _propertyService = PropertyService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    LoadingScreen().show(
      context: context,
      text: 'Loading profiles, properties, and company names...',
    );
    try {
      final profilesStream = _rentService.allProfiles(creatorId: userId);
      final propertiesStream =
          _propertyService.allProperties(creatorId: userId);

      final profiles = await profilesStream.first;
      final properties = await propertiesStream.first;

      // Fetching unique companyIds from properties
      final companyIds =
          properties.map((property) => property.companyId).toSet().toList();

      // Fetching company names
      _companyNames = await _getCompanyNames(companyIds);

      setState(() {
        _profiles = profiles.toList();
        _properties = properties.toList();
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      await showErrorDialog(context, 'Error loading data: ${e.toString()}');
    } finally {
      LoadingScreen().hide();
    }
  }

  Future<Map<String, String>> _getCompanyNames(List<String> companyIds) async {
    final companyNames = <String, String>{};
    for (var companyId in companyIds) {
      final company = await _rentService.getCompanyById(companyId: companyId);
      companyNames[companyId] = company.companyName;
    }
    return companyNames;
  }

  bool isOverdueOrDueInFiveDays(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff <= 5;
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Overdue Rent Notice&body=Your rent is overdue, please take action immediately.',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else if (mounted) {
      await showErrorDialog(context, 'Could not launch email client.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overdue Rent Reminder'),
      ),
      body: Stack(
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
          // Main Content
          _isInitialized
              ? StreamBuilder<Iterable<CloudRent>>(
                  stream: _rentService.allRents(creatorId: userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      LoadingScreen().show(
                        context: context,
                        text: 'Loading rents...',
                      );
                      return Container();
                    } else {
                      LoadingScreen().hide();
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading rents: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No rents available.'),
                      );
                    }

                    final allRents = snapshot.data!;
                    final filteredRents = allRents.where((rent) {
                      final dueDate = DateTime.parse(rent.dueDate);
                      return isOverdueOrDueInFiveDays(dueDate) &&
                          rent.endContract != 'Contract_Ended';
                    }).toList();

                    if (filteredRents.isEmpty) {
                      return const Center(
                        child: Text(
                            'No rents are overdue or due in 5 days or less.'),
                      );
                    }

                    // Grouping rents by companyId
                    final groupedRents =
                        groupBy(filteredRents, (CloudRent rent) {
                      final property = _properties.firstWhere(
                        (prop) => prop.id == rent.propertyId,
                      );
                      return property.companyId; // group by companyId
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: groupedRents.keys.length,
                      itemBuilder: (context, index) {
                        final companyId = groupedRents.keys.elementAt(index);
                        final companyRents = groupedRents[companyId]!;
                        final companyName =
                            _companyNames[companyId] ?? "Unknown Company";

                        return ExpansionTile(
                          collapsedIconColor: Colors.white,
                          iconColor: Colors.lightBlue,
                          collapsedBackgroundColor:
                              Colors.black.withValues(alpha: 0.1),
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          title: Text(
                            'Company: $companyName (${companyRents.length} overdue)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          children: companyRents.map((rent) {
                            final property = _properties.firstWhere(
                              (prop) => prop.id == rent.propertyId,
                            );
                            final profile = _profiles.firstWhere(
                              (prof) => prof.id == rent.profileId,
                            );
                            final dueDate = DateTime.parse(rent.dueDate);
                            final formattedDueDate =
                                DateFormat.yMMMd().format(dueDate);
                            final daysRemaining =
                                dueDate.difference(DateTime.now()).inDays;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              elevation: 6.0,
                              color: Colors.transparent,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: ListTile(
                                title: Text(
                                  'Property: ${property.propertyNumber}',
                                  style: const TextStyle(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile: ${profile.companyName}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                    Text(
                                      'Email: ${profile.email}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                    Text(
                                      'Due Date: $formattedDueDate',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                    Text(
                                      daysRemaining >= 0
                                          ? 'Days remaining: $daysRemaining'
                                          : 'Overdue by: ${daysRemaining.abs()} days',
                                      style: TextStyle(
                                        color: daysRemaining < 0
                                            ? Colors.red
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'View') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReadRentPage(rentId: rent.id),
                                        ),
                                      );
                                    } else if (value == 'Send Email') {
                                      _sendEmail(profile.email);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'View',
                                      child: Text('View Rent'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Send Email',
                                      child: Text('Send Email'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: Text('Initializing...'),
                ),
        ],
      ),
    );
  }
}
