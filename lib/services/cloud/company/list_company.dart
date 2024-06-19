//list_company.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/company/create_or_update_companies.dart';

import '../../auth/auth_service.dart';
import '../employee_services/cloud_rent_service.dart';

class ListCompany extends StatelessWidget {
  const ListCompany({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RentService rentService = RentService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Companies'),
      ),
      body: StreamBuilder<Iterable<CloudCompany>>(
        stream: rentService.allCompanies(
          creatorId: AuthService.firebase().currentUser!.id,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final companies = snapshot.data!;
          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies.elementAt(index);
              return ListTile(
                title: Text(company.companyName),
                subtitle: Text(company.companyOwner),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateOrUpdateCompany(company: company),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateOrUpdateCompany()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
