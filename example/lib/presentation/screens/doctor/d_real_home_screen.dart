import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';

// ✅ DoctorDrawer 위젯: 모든 의사 관련 화면에서 재사용할 수 있는 Drawer
class DoctorDrawer extends StatelessWidget {
  final String baseUrl;

  const DoctorDrawer({Key? key, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // ✅ TOOTH AI 닥터 메뉴와 로그아웃 버튼을 포함하는 커스텀 DrawerHeader
          Container(
            height: 120, // 헤더 높이 조절
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'TOOTH AI 닥터 메뉴',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ✅ 로그아웃 버튼
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      // 로그아웃 로직 구현
                      context.go('/login'); // 로그인 화면으로 이동
                    },
                    tooltip: '로그아웃',
                  ),
                ],
              ),
            ),
          ),
          // ✅ 홈 버튼 추가
          _buildDrawerItem(
            context,
            icon: Icons.home, // 홈 아이콘
            title: '홈',
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              context.go('/d_home', extra: baseUrl); // d_real_home_screen.dart로 이동
            },
          ),
          // ✅ 메뉴 항목들
          _buildDrawerItem(
            context,
            icon: Icons.personal_injury, // 비대면 진료 신청 아이콘
            title: '비대면 진료 신청',
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              context.go('/d_dashboard', extra: baseUrl); // 해당 라우트로 이동
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today, // 예약 현황 아이콘
            title: '예약 현황',
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              context.go('/d_appointments', extra: baseUrl); // 해당 라우트로 이동
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment, // 진료 결과 아이콘
            title: '진료 결과',
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              context.go('/d_inference_result', extra: baseUrl); // 해당 라우트로 이동
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event, // 진료 캘린더 아이콘
            title: '진료 캘린더',
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              context.go('/d_calendar', extra: baseUrl); // 해당 라우트로 이동
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people, // 환자 목록 아이콘
            title: '환자 목록',
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              context.go('/d_patients', extra: baseUrl); // 해당 라우트로 이동
            },
          ),
        ],
      ),
    );
  }

  // Drawer 메뉴 항목을 위한 헬퍼 위젯 (DoctorDrawer 내부에 정의)
  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.blueGrey[800],
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white,
      hoverColor: Colors.blue.withOpacity(0.1),
    );
  }
}


// DRealHomeScreen 클래스 정의
class DRealHomeScreen extends StatefulWidget {
  final String baseUrl;

  const DRealHomeScreen({Key? key, required this.baseUrl}) : super(key: key);

  @override
  State<DRealHomeScreen> createState() => _DRealHomeScreenState();
}

class _DRealHomeScreenState extends State<DRealHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DoctorDashboardViewModel>(context, listen: false);
      viewModel.loadDashboardData(widget.baseUrl);
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
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      // ✅ 분리된 DoctorDrawer 위젯 사용
      drawer: DoctorDrawer(baseUrl: widget.baseUrl),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '환영합니다, 의사 선생님!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '연결된 서버: ${widget.baseUrl}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 진료 현황',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
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
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDashboardListItem(context, Icons.person_add, '새로운 진료 요청 확인', () {
                    // GoRouter를 사용하여 다른 화면으로 이동
                    // context.go('/d_new_consultations');
                  }),
                  _buildDashboardListItem(context, Icons.history, '과거 진료 기록 조회', () {
                    // context.go('/d_history');
                  }),
                  _buildDashboardListItem(context, Icons.settings, '설정', () {
                    // context.go('/d_settings');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 통계 항목 위젯
  Widget _buildStatItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // 대시보드 리스트 아이템 위젯
  Widget _buildDashboardListItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 30),
              const SizedBox(width: 15),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
