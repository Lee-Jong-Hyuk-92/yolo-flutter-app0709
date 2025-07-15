import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Provider is used for ChangeNotifierProvider

// 필요한 화면들 임포트
import '/presentation/screens/doctor/d_inference_result_screen.dart';
import '/presentation/screens/doctor/d_real_home_screen.dart'; // 의사 첫 홈
import '/presentation/screens/main_scaffold.dart'; // 일반 사용자용 스캐폴드
import '/presentation/screens/login_screen.dart';
import '/presentation/screens/register_screen.dart';
import '/presentation/screens/home_screen.dart';
import '/presentation/screens/camera_inference_screen.dart';
import '/presentation/screens/web_placeholder_screen.dart';

// 하단 탭 바 화면들
import '/presentation/screens/chatbot_screen.dart';
import '/presentation/screens/mypage_screen.dart';
import '/presentation/screens/upload_screen.dart';
import '/presentation/screens/history_screen.dart';
import '/presentation/screens/clinics_screen.dart';

// DoctorDashboardViewModel은 전용 파일에서만 임포트합니다.
import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart'; // ViewModel의 정식 경로

GoRouter createRouter(String baseUrl) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(baseUrl: baseUrl),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/web',
        builder: (context, state) => const WebPlaceholderScreen(),
      ),

      // ✅ 의사 전용 ShellRoute 추가: 이 ShellRoute 내의 모든 화면은 Drawer를 유지합니다.
      ShellRoute(
        builder: (context, state, child) {
          // DRealHomeScreen이 Drawer를 가지고 있으므로,
          // 의사 관련 모든 화면에서 Drawer를 유지하려면 DRealHomeScreen이 ShellRoute의 child가 되어야 합니다.
          // 하지만 DRealHomeScreen 자체가 Scaffold와 Drawer를 가지고 있으므로,
          // 여기서는 단순히 child를 반환하여 DRealHomeScreen이 자체적으로 Drawer를 렌더링하도록 합니다.
          // 만약 모든 의사 화면에 공통된 AppBar나 다른 요소가 필요하다면,
          // 별도의 DoctorScaffold 같은 위젯을 만들고 그 안에 child를 넣을 수 있습니다.
          return child;
        },
        routes: [
          // ✅ 의사 로그인 후 메인 홈
          GoRoute(
            path: '/d_home',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return ChangeNotifierProvider(
                create: (_) => DoctorDashboardViewModel(),
                child: DRealHomeScreen(baseUrl: passedBaseUrl),
              );
            },
          ),

          // ✅ 의사 메뉴: 비대면 진료 신청 화면 (기존 /d_dashboard)
          GoRoute(
            path: '/d_dashboard',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              // DInferenceResultScreen도 Drawer를 가지도록 하려면 이 화면도 Scaffold를 포함해야 합니다.
              return DInferenceResultScreen(baseUrl: passedBaseUrl);
            },
          ),

          // ✅ 의사 메뉴: 예약 현황
          GoRoute(
            path: '/d_appointments',
            builder: (context, state) {
              // TODO: 실제 예약 현황 화면 위젯으로 교체하세요. (이 화면도 Scaffold를 포함해야 Drawer가 보입니다.)
              return Scaffold(
                appBar: AppBar(title: const Text('예약 현황')),
                drawer: const Drawer(), // 임시 Drawer 추가 (실제 화면에 맞춰야 함)
                body: const Center(child: Text('예약 현황 화면입니다.')),
              );
            },
          ),

          // ✅ 의사 메뉴: 진료 결과 (기존 DInferenceResultScreen을 재사용하거나, 필요시 별도 화면 생성)
          GoRoute(
            path: '/d_inference_result',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              // DInferenceResultScreen도 Drawer를 가지도록 하려면 이 화면도 Scaffold를 포함해야 합니다.
              return DInferenceResultScreen(baseUrl: passedBaseUrl);
            },
          ),

          // ✅ 의사 메뉴: 진료 캘린더
          GoRoute(
            path: '/d_calendar',
            builder: (context, state) {
              // TODO: 실제 진료 캘린더 화면 위젯으로 교체하세요. (이 화면도 Scaffold를 포함해야 Drawer가 보입니다.)
              return Scaffold(
                appBar: AppBar(title: const Text('진료 캘린더')),
                drawer: const Drawer(), // 임시 Drawer 추가 (실제 화면에 맞춰야 함)
                body: const Center(child: Text('진료 캘린더 화면입니다.')),
              );
            },
          ),

          // ✅ 의사 메뉴: 환자 목록
          GoRoute(
            path: '/d_patients',
            builder: (context, state) {
              // TODO: 실제 환자 목록 화면 위젯으로 교체하세요. (이 화면도 Scaffold를 포함해야 Drawer가 보입니다.)
              return Scaffold(
                appBar: AppBar(title: const Text('환자 목록')),
                drawer: const Drawer(), // 임시 Drawer 추가 (실제 화면에 맞춰야 함)
                body: const Center(child: Text('환자 목록 화면입니다.')),
              );
            },
          ),
        ],
      ),

      // ✅ 일반 사용자 ShellRoute (기존 유지)
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(
            child: child,
            currentLocation: state.uri.toString(),
          );
        },
        routes: [
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final authViewModel = state.extra as Map<String, dynamic>?;
              final userId = authViewModel?['userId'] ?? 'guest';
              return HomeScreen(baseUrl: baseUrl, userId: userId);
            },
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => const MyPageScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return UploadScreen(baseUrl: passedBaseUrl);
            },
          ),
          GoRoute(
            path: '/diagnosis/realtime',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? '',
                userId: data['userId'] ?? 'guest',
              );
            },
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return HistoryScreen(baseUrl: passedBaseUrl);
            },
          ),
          GoRoute(
            path: '/clinics',
            builder: (context, state) => const ClinicsScreen(),
          ),
          GoRoute(
            path: '/camera',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? '',
                userId: data['userId'] ?? 'guest',
              );
            },
          ),
        ],
      ),
    ],
  );
}
