import 'package:flutter/material.dart';
import '../models/project.dart';
import '../utils/app_theme.dart';

class ReportScreen extends StatelessWidget {
  final List<Project> projects;
  const ReportScreen({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FULL SHEET VIEW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.navy.withOpacity(0.05)),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('S.No')),
              DataColumn(label: Text('Invoice No')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Customer ID')),
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Project Title')),
              DataColumn(label: Text('Fee')),
              DataColumn(label: Text('Payment Status')),
              DataColumn(label: Text('Method')),
              DataColumn(label: Text('Transaction ID')),
              DataColumn(label: Text('Date')),
            ],
            rows: projects.map((p) => DataRow(
              cells: [
                DataCell(Text(p.sNo)),
                DataCell(Text(p.invoiceNo)),
                DataCell(_statusBadge(p.status)),
                DataCell(Text(p.customerId)),
                DataCell(Text(p.fullName)),
                DataCell(SizedBox(width: 150, child: Text(p.projectTitle, overflow: TextOverflow.ellipsis))),
                DataCell(Text('₹${p.feeAmount}')),
                DataCell(Text(p.paymentStatus, style: TextStyle(color: p.isPaid ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold))),
                DataCell(Text(p.paymentMethod)),
                DataCell(Text(p.transactionId)),
                DataCell(Text(p.paymentDate)),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.toLowerCase().contains('complet') ? AppColors.successBg : AppColors.infoBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: const TextStyle(fontSize: 11)),
    );
  }
}