import 'dart:ui';

import 'package:flutter/material.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_property_service.dart';

class ReadPropertyPage extends StatelessWidget {
  final String propertyId;
  final PropertyService _propertyService = PropertyService();

  ReadPropertyPage({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Property'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Image

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
          FutureBuilder<CloudProperty>(
            future: _propertyService.getProperty(id: propertyId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data found'));
              } else {
                final property = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPropertyDetailCard(
                        icon: Icons.home,
                        label: 'Property Type',
                        value: property.propertyType,
                      ),
                      _buildPropertyDetailCard(
                        icon: Icons.layers,
                        label: 'Floor Number',
                        value: property.floorNumber.toString(),
                      ),
                      _buildPropertyDetailCard(
                        icon: Icons.confirmation_number,
                        label: 'Property Number',
                        value: property.propertyNumber,
                      ),
                      _buildPropertyDetailCard(
                        icon: Icons.attach_money,
                        label: 'Price Per Month',
                        value: '\$${property.pricePerMonth}',
                      ),
                      _buildPropertyDetailCard(
                        icon: Icons.square_foot,
                        label: 'Size in Square Meters',
                        value: property.sizeInSquareMeters.toString(),
                      ),
                      _buildPropertyDetailCard(
                        icon: Icons.description,
                        label: 'Description',
                        value: property.description,
                      ),
                      _buildPropertyDetailCard(
                        icon: property.isRented
                            ? Icons.check_circle
                            : Icons.cancel,
                        label: 'Rented Status',
                        value: property.isRented ? "Rented" : "Free",
                        iconColor:
                            property.isRented ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build property details card
  Widget _buildPropertyDetailCard({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = Colors.white,
  }) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
