import 'package:flutter/material.dart';

import '../../../property_mangement/new/property_service.dart';

class ReadPropertyPage extends StatelessWidget {
  final int propertyId;
  final PropertyService _propertyService = PropertyService();

  ReadPropertyPage({Key? key, required this.propertyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Property')),
      body: FutureBuilder<DatabaseProperty>(
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Property Type: ${property.propertyType}'),
                  Text('floor Number: ${property.floorNumber}'),
                  Text('property Number: ${property.propertyNumber}'),
                  Text('price Per Month: ${property.pricePerMonth}'),
                  Text('size In Square Meters: ${property.sizeInSquareMeters}'),
                  Text('description: ${property.description}'),
                  Text('Rented: ${property.isRented ? "Rented" : "Free"}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
