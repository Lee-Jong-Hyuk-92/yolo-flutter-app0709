import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'presentation/viewmodel/userinfo_viewmodel.dart';
import 'services/router.dart';
import '/presentation/screens/doctor/d_home_screen.dart';
import '/presentation/viewmodel/doctor/d_consultation_record_viewmodel.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import '/presentation/viewmodel/doctor/d_patient_viewmodel.dart';
import 'core/theme/app_theme.dart'; // ✅ 테마 임포트 추가

void main() {
  const String globalBaseUrl = "http://192.168.0.19:5000/api";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => UserInfoViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorDashboardViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => DPatientViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => ConsultationRecordViewModel(baseUrl: globalBaseUrl),
        ),
      ],
      child: YOLOExampleApp(baseUrl: globalBaseUrl),
    ),
  );
}

class YOLOExampleApp extends StatelessWidget {
  final String baseUrl;

  const YOLOExampleApp({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      debugShowCheckedModeBanner: false,
      routerConfig: createRouter(baseUrl),
      theme: AppTheme.lightTheme, // ✅ 테마 적용
    );
  }
}
