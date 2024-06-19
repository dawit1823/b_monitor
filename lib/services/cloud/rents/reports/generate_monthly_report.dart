import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';

class GenerateMonthlyReport extends StatefulWidget {
  final String companyId;

  GenerateMonthlyReport({Key? key, required this.companyId}) : super(key: key);

  @override
  _GenerateMonthlyReportState createState() => _GenerateMonthlyReportState();
}

class _GenerateMonthlyReportState extends State<GenerateMonthlyReport> {
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  DateTimeRange? selectedDateRange;

  Future<List<Map<String, dynamic>>> _fetchRentsWithDetails() async {
    final rents =
        await _rentService.getRentsByCompanyId(companyId: widget.companyId);
    List<Map<String, dynamic>> rentDetailsList = [];

    for (var rent in rents) {
      if (rent.endContract != 'Contract_Ended') {
        final property =
            await _propertyService.getProperty(id: rent.propertyId);
        final profile = await _rentService.getProfile(id: rent.profileId);

        // Parse payment status and description for payment date
        final payments = rent.paymentStatus.split('; ');
        final firstPaymentDate =
            payments.isNotEmpty ? payments.first.split(', ')[3] : '';
        final lastAdvancePayment =
            payments.isNotEmpty ? payments.last.split(', ')[1] : '';
        final paymentDate = rent.paymentStatus.split(', ').length > 3
            ? rent.paymentStatus.split(', ')[3]
            : '';

        rentDetailsList.add({
          'rent': rent,
          'property': property,
          'profile': profile,
          'firstPaymentDate': firstPaymentDate,
          'lastAdvancePayment': lastAdvancePayment,
          'paymentDate': paymentDate,
        });
      }
    }

    return rentDetailsList;
  }

  List<Map<String, dynamic>> _filterRentsByDateRange(
      List<Map<String, dynamic>> rentDetails, DateTimeRange dateRange) {
    return rentDetails.where((rentDetail) {
      final rent = rentDetail['rent'] as CloudRent;
      final paymentDate = DateTime.parse(rent.paymentStatus.split(', ')[3]);
      return paymentDate.isAfter(dateRange.start) &&
          paymentDate.isBefore(dateRange.end);
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ??
          DateTimeRange(
              start: DateTime.now().subtract(Duration(days: 30)),
              end: DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Monthly Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: Text('Select Date Range'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRentsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found'));
                } else {
                  final rentDetailsList = selectedDateRange != null
                      ? _filterRentsByDateRange(
                          snapshot.data!, selectedDateRange!)
                      : snapshot.data!;

                  double totalRentAmount =
                      rentDetailsList.fold(0.0, (sum, rentDetail) {
                    final rent = rentDetail['rent'] as CloudRent;
                    return sum + rent.rentAmount;
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Property No')),
                        DataColumn(label: Text('Floor No')),
                        DataColumn(label: Text('Profile Name')),
                        DataColumn(label: Text('Rent Amount')),
                        DataColumn(label: Text('Payment Type')),
                        DataColumn(label: Text('Deposited On')),
                        DataColumn(label: Text('Advance Payment')),
                        DataColumn(label: Text('Payment Date')),
                      ],
                      rows: List<DataRow>.generate(rentDetailsList.length,
                          (index) {
                        final rentDetail = rentDetailsList[index];
                        final rent = rentDetail['rent'] as CloudRent;
                        final property =
                            rentDetail['property'] as DatabaseProperty;
                        final profile = rentDetail['profile'] as CloudProfile;
                        final paymentDate = rentDetail['paymentDate'];

                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(property.propertyNumber)),
                            DataCell(Text(property.floorNumber)),
                            DataCell(Text(
                                '${profile.firstName} ${profile.lastName}')),
                            DataCell(Text(rent.rentAmount.toString())),
                            DataCell(Text(rent.paymentStatus.split(', ')[2])),
                            DataCell(Text(rent.paymentStatus.split(', ')[4])),
                            DataCell(Text(rent.paymentStatus.split(', ')[1])),
                            DataCell(Text(paymentDate)),
                          ],
                        );
                      })
                        ..add(DataRow(
                          cells: [
                            DataCell(Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text(totalRentAmount.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        )),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
