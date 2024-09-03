// list_company.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/company/create_or_update_companies.dart';
import 'package:r_and_e_monitor/services/cloud/rents/company_detail.dart';
import '../../auth/auth_service.dart';
import '../employee_services/cloud_rent_service.dart';

class ListCompany extends StatelessWidget {
  ListCompany({super.key});
  final RentService _rentService = RentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
      ),
      body: StreamBuilder<Iterable<CloudCompany>>(
        stream: _rentService.allCompanies(
          creatorId: AuthService.firebase().currentUser!.id,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final companies = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 3 / 2,
            ),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailPage(company: company),
                    ),
                  );
                },
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.companyName,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Owner: ${company.companyOwner}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10.0),
                        Expanded(
                          child: Text(
                            'Address: ${company.address}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Restricting text to 2 lines
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateOrUpdateCompany()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
