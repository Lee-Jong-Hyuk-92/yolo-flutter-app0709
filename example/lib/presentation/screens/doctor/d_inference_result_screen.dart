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
    final List<ConsultationRecord> sortedRecords = List.from(records)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 최신순

    final imageBaseUrl = widget.baseUrl.replaceAll('/api', '');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final listIndex = sortedRecords.length - index; // 최신이 [n], 오래된게 [1]

        String? formattedTime;
        try {
          final imagePath = record.originalImagePath;
          final filename = imagePath.split('/').last;
          final parts = filename.split('_');

          print('🧪 filename: $filename');
          print('🧪 split("_") 결과: $parts');

          if (parts.length >= 2) {
            final timePart = parts[1];
            final y = timePart.substring(0, 4);
            final m = timePart.substring(4, 6);
            final d = timePart.substring(6, 8);
            final h = timePart.substring(8, 10);
            final min = timePart.substring(10, 12);

            final dateString = '$y-$m-$d $h:$min:00'.replaceAll(' ', 'T');
            final parsed = DateTime.parse(dateString);
            formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(parsed);
          } else {
            formattedTime = '시간 정보 없음';
          }
        } catch (e) {
          print('❌ 시간 파싱 오류: $e');
          formattedTime = '시간 파싱 오류';
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('[$listIndex] $formattedTime'),
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
