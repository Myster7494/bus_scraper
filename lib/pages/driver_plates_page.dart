import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/driving_record_list.dart';
import '../widgets/empty_state_indicator.dart'; // 【修改】1. 引入 EmptyStateIndicator
import '../widgets/theme_provider.dart';

class DriverPlatesPage extends StatefulWidget {
  const DriverPlatesPage({super.key});

  @override
  State<DriverPlatesPage> createState() => _DriverPlatesPageState();
}

class _DriverPlatesPageState extends State<DriverPlatesPage> {
  final _driverIdController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  final _displayDateFormat = DateFormat('yyyy/MM/dd');

  bool _hasSearched = false;
  String _currentDriverId = '';

  @override
  void dispose() {
    _driverIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          if (_startDate.isAfter(_endDate)) _endDate = _startDate;
        } else {
          _endDate = pickedDate;
          if (_endDate.isBefore(_startDate)) _startDate = _endDate;
        }
      });
    }
  }

  void _triggerSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _hasSearched = true;
      _currentDriverId = _driverIdController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      builder: (BuildContext context, ThemeData themeData) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 8),
            Expanded(
              child: _hasSearched
                  ? DrivingRecordList(
                      key: ValueKey('driver_$_currentDriverId'),
                      queryType: QueryType.byDriver,
                      queryValue: _currentDriverId,
                      startDate: _startDate,
                      endDate: _endDate,
                      driverIdForListItem: _currentDriverId,
                    )
                  : _buildInitialMessage(), // <-- 這個方法現在更簡潔了
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    // ... 此處程式碼不變 ...
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _driverIdController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: "駕駛員 ID",
                hintText: "如：120031",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search_outlined),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: "起始日期",
                    value: _startDate,
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDatePicker(
                    label: "結束日期",
                    value: _endDate,
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _triggerSearch,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text("查詢"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime value,
    required VoidCallback onPressed,
  }) {
    // ... 此處程式碼不變 ...
    final theme = Theme.of(context);
    final displayText = _displayDateFormat.format(value);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  displayText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.calendar_month_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  // 【修改】2. 將此方法的實作替換為 EmptyStateIndicator
  Widget _buildInitialMessage() {
    return const EmptyStateIndicator(
      icon: Icons.person_search_outlined, // 也可以用 Icons.search_off_rounded
      title: "開始查詢",
      subtitle: "請輸入駕駛員 ID 並選擇日期範圍\n然後點擊查詢按鈕\n(註：ID 前方若有 0 可能需去除)",
    );
  }
}
