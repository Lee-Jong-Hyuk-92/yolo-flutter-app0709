import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/presentation/viewmodel/doctor/d_consultation_record_viewmodel.dart';
import '/presentation/model/doctor/d_consultation_record.dart';
import 'd_result_detail_screen.dart';

class InferenceResultScreen extends StatefulWidget {
  final String baseUrl;

  const InferenceResultScreen({super.key, required this.baseUrl});

  @override
  State<InferenceResultScreen> createState() => _InferenceResultScreenState();
}

class _InferenceResultScreenState extends State<InferenceResultScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ConsultationRecordViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConsultationRecordViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 결과 목록'),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('오류: ${viewModel.error}'))
              : _buildListView(viewModel.records),
    );
  }

  Widget _buildListView(List<ConsultationRecord> records) {
    final Map<String, int> dailyIndexMap = {};
    final List<ConsultationRecord> sortedRecords = List.from(records)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 최신순

    // base URL에서 "/api" 제거 (정적 파일 경로용)
    final imageBaseUrl = widget.baseUrl.replaceAll('/api', '');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final timestamp = record.timestamp;
        final formattedTime = DateFormat('yyyy-MM-dd-HH-mm').format(timestamp);
        final dateKey = DateFormat('yyyyMMdd').format(timestamp);

        dailyIndexMap[dateKey] = (dailyIndexMap[dateKey] ?? 0) + 1;
        final dailyIndex = dailyIndexMap[dateKey]!;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('[$dailyIndex] $formattedTime'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('사용자 ID: ${record.userId}'),
                Text('파일명: ${record.originalImageFilename}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultDetailScreen(
                    originalImageUrl: '$imageBaseUrl${record.originalImagePath}',
                    processedImageUrl: '$imageBaseUrl${record.processedImagePath}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
