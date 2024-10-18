import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/create_or_update_properties.dart';
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
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/bg/background_dashboard.jpg', // Replace with your background image path
                fit: BoxFit.cover,
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
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NewPropertyView(
                                  property:
                                      property, // Pass the current property
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Property'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
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
    Color iconColor = Colors.black,
  }) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.2),
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
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
