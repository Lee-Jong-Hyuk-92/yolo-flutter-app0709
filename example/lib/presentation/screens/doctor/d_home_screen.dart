import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import 'd_patient_list_screen.dart';
import 'd_inference_result_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Text(
        '진료 캘린더 화면 (임시)',
        style: textTheme.bodyMedium,
      ),
    );
  }
}

enum DoctorMenu { inferenceResult, calendar, patientList }

class DoctorDashboardViewModel with ChangeNotifier {
  DoctorMenu _selectedMenu = DoctorMenu.inferenceResult;

  DoctorMenu get selectedMenu => _selectedMenu;

  void setSelectedMenu(DoctorMenu menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  int get selectedIndex => _selectedMenu.index;

  void setSelectedIndex(int index) {
    setSelectedMenu(DoctorMenu.values[index]);
  }
}

class DoctorHomeScreen extends StatelessWidget {
  final String baseUrl;

  const DoctorHomeScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.watch<DoctorDashboardViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    final textTheme = Theme.of(context).textTheme;

    if (currentUser == null || !currentUser.isDoctor) {
      return Scaffold(
        body: Center(
          child: Text(
            '의사 계정으로 로그인해야 합니다.',
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    Widget mainContent;
    switch (dashboardViewModel.selectedMenu) {
      case DoctorMenu.inferenceResult:
        mainContent = DInferenceResultScreen(baseUrl: baseUrl);
        break;
      case DoctorMenu.calendar:
        mainContent = const CalendarScreen();
        break;
      case DoctorMenu.patientList:
        mainContent = const PatientListScreen();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TOOTH AI',
          style: textTheme.headlineLarge?.copyWith(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: mainContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dashboardViewModel.selectedIndex,
        onTap: dashboardViewModel.setSelectedIndex,
        selectedLabelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(color: Colors.grey),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '진단 결과',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '진료 캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: '환자 목록',
          ),
        ],
      ),
    );
  }
}
