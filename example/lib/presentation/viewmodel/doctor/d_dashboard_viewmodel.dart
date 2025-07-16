import 'package:flutter/material.dart';

class DoctorDashboardViewModel extends ChangeNotifier {
  int _newPatientsToday = 0;
  int _completedConsultationsToday = 0;
  int _pendingConsultations = 0;

  bool _hasNewNotification = true;
  List<String> _newConsultations = ['환자 A - 치통', '환자 B - 충치 의심'];
  List<String> _pastConsultations = ['환자 C - 스케일링', '환자 D - 치아 미백 완료'];

  int get newPatientsToday => _newPatientsToday;
  int get completedConsultationsToday => _completedConsultationsToday;
  int get pendingConsultations => _pendingConsultations;

  bool get hasNewNotification => _hasNewNotification;
  List<String> get newConsultations => _newConsultations;
  List<String> get pastConsultations => _pastConsultations;

  void updateDashboardData({int? newPatients, int? completed, int? pending}) {
    if (newPatients != null) _newPatientsToday = newPatients;
    if (completed != null) _completedConsultationsToday = completed;
    if (pending != null) _pendingConsultations = pending;
    notifyListeners();
  }

  void clearNotifications() {
    _hasNewNotification = false;
    notifyListeners();
  }

  void addNewConsultation(String consultation) {
    _newConsultations.insert(0, consultation);
    _hasNewNotification = true;
    notifyListeners();
  }

  Future<void> loadDashboardData(String baseUrl) async {
    print('Loading dashboard data from: $baseUrl');
    await Future.delayed(const Duration(seconds: 1));
    updateDashboardData(newPatients: 7, completed: 15, pending: 4);
  }
}
