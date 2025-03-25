import 'package:flutter/material.dart';

import 'ethiopian_gregorian_converter.dart';

class EthiopianDatePicker extends StatefulWidget {
  final EthiopianDate initialDate;

  const EthiopianDatePicker({super.key, required this.initialDate});

  @override
  State<EthiopianDatePicker> createState() => _EthiopianDatePickerState();
}

class _EthiopianDatePickerState extends State<EthiopianDatePicker> {
  late EthiopianDate _selectedDate;
  final List<String> _months = [
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Ethiopian Date',
          style: TextStyle(color: Colors.black)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildYearSelector(),
            const SizedBox(height: 10),
            _buildMonthSelector(),
            const SizedBox(height: 10),
            _buildDayGrid(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedDate),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildYearSelector() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => _updateYear(-1),
        ),
        Expanded(
          child: Text(
            _selectedDate.year.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.black),
          onPressed: () => _updateYear(1),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return DropdownButton<int>(
      value: _selectedDate.month - 1,
      style: TextStyle(color: Colors.black),
      items: List.generate(
          13,
          (index) => DropdownMenuItem(
                value: index,
                child: Text(_months[index],
                    style: const TextStyle(color: Colors.black)),
              )),
      onChanged: (value) => setState(() {
        _selectedDate = EthiopianDate(
          _selectedDate.year,
          value! + 1,
          _selectedDate.day,
        );
      }),
    );
  }

  Widget _buildDayGrid() {
    final daysInMonth = EthiopianGregorianConverter.daysInEthiopianMonth(
        _selectedDate.year, _selectedDate.month);
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        return InkWell(
          onTap: () => setState(() => _selectedDate = EthiopianDate(
                _selectedDate.year,
                _selectedDate.month,
                day,
              )),
          child: Container(
            decoration: BoxDecoration(
              color: day == _selectedDate.day
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: day == _selectedDate.day ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateYear(int delta) {
    setState(() {
      _selectedDate = EthiopianDate(
        _selectedDate.year + delta,
        _selectedDate.month,
        _selectedDate.day,
      );
    });
  }
}
