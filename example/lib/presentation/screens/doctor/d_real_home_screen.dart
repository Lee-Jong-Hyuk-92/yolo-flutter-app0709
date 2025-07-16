import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';

class DoctorDrawer extends StatelessWidget {
  final String baseUrl;

  const DoctorDrawer({Key? key, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOOTH AI 닥터 메뉴',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => context.go('/login'),
                    tooltip: '로그아웃',
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.home, '홈', () {
            Navigator.pop(context);
            context.go('/d_home', extra: baseUrl);
          }),
          _buildDrawerItem(context, Icons.personal_injury, '비대면 진료 현황', () {
            Navigator.pop(context);
            context.go('/d_dashboard', extra: baseUrl);
          }),
          _buildDrawerItem(context, Icons.assignment, '진료 결과', () {
            Navigator.pop(context);
            context.go('/d_inference_result', extra: baseUrl);
          }),
          _buildDrawerItem(context, Icons.event, '진료 캘린더', () {
            Navigator.pop(context);
            context.go('/d_calendar', extra: baseUrl);
          }),
          _buildDrawerItem(context, Icons.people, '환자 목록', () {
            Navigator.pop(context);
            context.go('/d_patients', extra: baseUrl);
          }),
          _buildDrawerItem(context, Icons.settings, '설정', () {
            Navigator.pop(context);
            context.go('/d_settings', extra: baseUrl);
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueGrey[800])),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white,
      hoverColor: Colors.blue.withOpacity(0.1),
    );
  }
}

class DRealHomeScreen extends StatefulWidget {
  final String baseUrl;

  const DRealHomeScreen({Key? key, required this.baseUrl}) : super(key: key);

  @override
  State<DRealHomeScreen> createState() => _DRealHomeScreenState();
}

class _DRealHomeScreenState extends State<DRealHomeScreen> {
  bool showNewConsultations = false;
  bool showPastRecords = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DoctorDashboardViewModel>(context, listen: false);
      viewModel.loadDashboardData(widget.baseUrl);

      // 💡 예시 알림 추가 (나중에 서버/소켓 등에서 연결 가능)
      Future.delayed(const Duration(seconds: 5), () {
        viewModel.addNewConsultation('환자 E - 임플란트 상담 요청');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DoctorDashboardViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('의사 대시보드 홈'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: viewModel.hasNewNotification ? Colors.red : Colors.white,
            ),
            onPressed: () => viewModel.clearNotifications(),
          ),
        ],
      ),
      drawer: DoctorDrawer(baseUrl: widget.baseUrl),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('환영합니다, 의사 선생님!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    )),
            const SizedBox(height: 10),
            Text('연결된 서버: ${widget.baseUrl}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _buildStatCard(viewModel),
            const SizedBox(height: 20),
            ExpansionTile(
              initiallyExpanded: showNewConsultations,
              onExpansionChanged: (val) => setState(() => showNewConsultations = val),
              leading: const Icon(Icons.person_add),
              title: const Text('새로운 진료 요청 확인'),
              children: viewModel.newConsultations
                  .map((e) => ListTile(
                        leading: const Icon(Icons.medical_services),
                        title: Text(e),
                        onTap: () => context.go('/d_dashboard', extra: widget.baseUrl),
                      ))
                  .toList(),
            ),
            ExpansionTile(
              initiallyExpanded: showPastRecords,
              onExpansionChanged: (val) => setState(() => showPastRecords = val),
              leading: const Icon(Icons.history),
              title: const Text('과거 진료 기록 조회'),
              children: viewModel.pastConsultations
                  .map((e) => ListTile(
                        leading: const Icon(Icons.assignment_turned_in),
                        title: Text(e),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(DoctorDashboardViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 진료 현황',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    )),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(context, '신규 환자', viewModel.newPatientsToday.toString()),
                _buildStatItem(context, '진료 완료', viewModel.completedConsultationsToday.toString()),
                _buildStatItem(context, '대기 환자', viewModel.pendingConsultations.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                )),
        const SizedBox(height: 5),
        Text(title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
      ],
    );
  }
}
