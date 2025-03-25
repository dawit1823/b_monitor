import 'dart:ui';

import 'package:flutter/material.dart';

import 'ethiopian_date_picker.dart';
import 'ethiopian_gregorian_converter.dart';

class CalendarConverterScreen extends StatefulWidget {
  const CalendarConverterScreen({super.key});

  @override
  State<CalendarConverterScreen> createState() =>
      _CalendarConverterScreenState();
}

class _CalendarConverterScreenState extends State<CalendarConverterScreen> {
  final TextEditingController _ethiopianController = TextEditingController();
  final TextEditingController _gregorianController = TextEditingController();
  EthiopianDate? _ethiopianDate;
  DateTime? _gregorianDate;
  String _errorMessage = '';

  // Ethiopian month names
  final List<String> _ethiopianMonths = [
    'Meskerem',
    'Tikimit',
    'Hidar',
    'Tahesas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miazia',
    'Genbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume'
  ];

  // Gregorian month names
  final List<String> _gregorianMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _initializeWithCurrentDate();
  }

  void _initializeWithCurrentDate() {
    final now = DateTime.now();
    _gregorianDate = now;
    _ethiopianDate = EthiopianGregorianConverter.gregorianToEthiopian(now);
    _updateControllers();
  }

  void _updateControllers() {
    _ethiopianController.text = _ethiopianDate != null
        ? '${_ethiopianDate!.day}/${_ethiopianDate!.month}/${_ethiopianDate!.year}'
        : '';
    _gregorianController.text = _gregorianDate != null
        ? '${_gregorianDate!.day}/${_gregorianDate!.month}/${_gregorianDate!.year}'
        : '';
  }

  String _getEthiopianMonthName() {
    if (_ethiopianDate == null) return '';
    final monthIndex = _ethiopianDate!.month - 1;
    return monthIndex < _ethiopianMonths.length
        ? _ethiopianMonths[monthIndex]
        : '';
  }

  String _getGregorianMonthName() {
    if (_gregorianDate == null) return '';
    return _gregorianMonths[_gregorianDate!.month - 1];
  }

  void _handleEthiopianInput(String value) {
    setState(() {
      _errorMessage = '';
      try {
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          if (EthiopianGregorianConverter.isValidEthiopianDate(
              year, month, day)) {
            _ethiopianDate = EthiopianDate(year, month, day);
            _gregorianDate = EthiopianGregorianConverter.ethiopianToGregorian(
                year, month, day);
            _updateControllers();
          } else {
            _errorMessage = 'Invalid Ethiopian date';
          }
        }
      } catch (e) {
        _errorMessage = 'Invalid date format (dd/mm/yyyy)';
      }
    });
  }

  void _handleGregorianInput(String value) {
    setState(() {
      _errorMessage = '';
      try {
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          if (date.year == year && date.month == month && date.day == day) {
            _gregorianDate = date;
            _ethiopianDate =
                EthiopianGregorianConverter.gregorianToEthiopian(date);
            _updateControllers();
          } else {
            _errorMessage = 'Invalid Gregorian date';
          }
        }
      } catch (e) {
        _errorMessage = 'Invalid date format (dd/mm/yyyy)';
      }
    });
  }

  Future<void> _selectGregorianDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _gregorianDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _gregorianDate) {
      setState(() {
        _gregorianDate = picked;
        _ethiopianDate =
            EthiopianGregorianConverter.gregorianToEthiopian(picked);
        _updateControllers();
      });
    }
  }

  Future<void> _selectEthiopianDate(BuildContext context) async {
    final selectedDate = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: EthiopianDatePicker(
          initialDate: _ethiopianDate ??
              EthiopianGregorianConverter.gregorianToEthiopian(DateTime.now()),
        ),
      ),
    );
    if (selectedDate != null) {
      setState(() {
        _ethiopianDate = selectedDate;
        _gregorianDate = EthiopianGregorianConverter.ethiopianToGregorian(
            selectedDate.year, selectedDate.month, selectedDate.day);
        _updateControllers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ethiopian-Gregorian Calendar Converter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF81C784),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDateCard(
                  title: 'Ethiopian Date',
                  controller: _ethiopianController,
                  onTap: () => _selectEthiopianDate(context),
                  onChanged: _handleEthiopianInput,
                  iconColor: const Color(0xFFFBC02D),
                  monthName: _getEthiopianMonthName(),
                ),
                const SizedBox(height: 24),
                _buildDateCard(
                  title: 'Gregorian Date',
                  controller: _gregorianController,
                  onTap: () => _selectGregorianDate(context),
                  onChanged: _handleGregorianInput,
                  iconColor: const Color(0xFF1976D2),
                  monthName: _getGregorianMonthName(),
                ),
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard({
    required String title,
    required TextEditingController controller,
    required VoidCallback onTap,
    required Function(String) onChanged,
    required Color iconColor,
    required String monthName,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'dd/mm/yyyy',
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: iconColor),
                  onPressed: onTap,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: onChanged,
              keyboardType: TextInputType.datetime,
            ),
            if (monthName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
