import 'package:flutter/material.dart';
import '../database/models/assessment.dart';
import '../database/models/patient.dart';
import '../database/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final String patientId;

  const HistoryScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<PatientHistoryRecord?> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.getCompletePatientHistory(widget.patientId);
  }

  Color _getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return Colors.red;
      case 'MODERATE':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Assessment History'),
      ),
      body: FutureBuilder<PatientHistoryRecord?>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('No history found or error loading records.'),
            );
          }

          final record = snapshot.data!;
          final Patient patient = record.patient;
          final List<Assessment> assessments = record.assessments;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Patient Summary Card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${patient.identifier}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Age: ${patient.age} | Sex: ${patient.sex}'),
                      Text('Total Assessments: ${record.totalAssessments}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Past Assessments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Assessments List
              if (assessments.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Text('No assessments recorded yet.'),
                  ),
                )
              else
                ...assessments.map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRiskColor(item.riskLevel),
                        child: Text(
                          item.riskLevel.isNotEmpty ? item.riskLevel[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('${item.riskLevel} Risk'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${item.assessmentDate}'),
                          Text('Referral: ${item.referral}'),
                          Text(
                            'Reason: ${item.explanation}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text('${(item.confidence * 100).toInt()}%'),
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}