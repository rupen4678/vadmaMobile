import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onBook;

  const BookingBottomSheet({super.key, required this.product, required this.onBook});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isRental = widget.product['listing_type'] == 'RENTAL';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRental ? 'Book Rental' : 'Book Service',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    child: Text(_startDate == null ? 'Select Date' : DateFormat.yMMMd().format(_startDate!)),
                  ),
                ),
              ),
              if (isRental) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _endDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Date'),
                      child: Text(_endDate == null ? 'Select Date' : DateFormat.yMMMd().format(_endDate!)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note to Seller',
              hintText: 'Any special requirements...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: (_startDate != null && (!isRental || _endDate != null))
                ? () {
                    widget.onBook({
                      'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
                      'end_date': _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
                      'renter_note': _noteController.text,
                    });
                  }
                : null,
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
