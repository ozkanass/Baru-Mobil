import 'package:baru_mobil/main.dart';
import 'package:baru_mobil/widgets/login_page.dart';
import 'package:baru_mobil/widgets/notification_test_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:baru_mobil/services/notification_service.dart';
import 'package:flutter/foundation.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> faculties = [];
  List<Map<String, dynamic>> departments = [];
  int? selectedFacultyId;
  int? selectedDepartmentId;
  bool isLoading = true;
  bool notificationsEnabled = true;
  bool clubNotificationsEnabled = true;
  bool isLoggedIn = false;
  String? clubName;
  int? clubId;

  @override
  void initState() {
    super.initState();
    _fetchFaculties().then((_) => _loadSettings());
    _checkLoginStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final facultyId = prefs.getInt('faculty_id');
    final departmentId = prefs.getInt('department_id');

    // Fakülte ID'si geçerli mi kontrol et
    if (facultyId != null &&
        faculties.any((faculty) => faculty['id'] == facultyId)) {
      setState(() {
        selectedFacultyId = facultyId;
      });
      await _fetchDepartments(facultyId);

      // Bölüm ID'si geçerli mi kontrol et
      if (departmentId != null &&
          departments.any((dept) => dept['id'] == departmentId)) {
        setState(() {
          selectedDepartmentId = departmentId;
        });
      }
    }

    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      clubNotificationsEnabled = prefs.getBool('clubs_notifications') ?? true;
    });
  }

  Future<void> _fetchFaculties() async {
    try {
      final response =
          await http.get(Uri.parse('http://${ApiURL.url}:3000/api/faculties'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          faculties = data
              .map((item) => {
                    'id': item['id'] as int,
                    'faculty_name': item['faculty_name'] as String,
                  })
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Fakülteler yüklenirken hata: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDepartments(int facultyId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://${ApiURL.url}:3000/api/departmentsForFaculty/$facultyId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          departments = data
              .map((item) => {
                    'id': item['id'] as int,
                    'department_name': item['department_name'] as String,
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Bölümler yüklenirken hata: $e');
      setState(() {
        departments = [];
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('is_logged_in') ?? false;
    final id = prefs.getInt('club_id');

    if (loggedIn && id != null) {
      try {
        final response = await http.get(
          Uri.parse('http://${ApiURL.url}:3000/api/clubs/$id'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            clubName = data['name'];
          });
        }
      } catch (e) {
        print('Kulüp bilgisi alınamadı: $e');
      }
    }

    setState(() {
      isLoggedIn = loggedIn;
      clubId = id;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Sadece kulüp yöneticisi ile ilgili verileri temizle
    await prefs.remove('is_logged_in');
    await prefs.remove('club_id');
    await prefs.remove('username');

    setState(() {
      isLoggedIn = false;
      clubName = null;
      clubId = null;
    });

    if (mounted) {
      ToastMessage.showToast(context, "Çıkış yapıldı", 3);
    }
  }

  Future<void> _updateClubNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('clubs_notifications', value);
    await NotificationService.updateNotificationSubscription();
    setState(() {
      clubNotificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle('Ayarlar'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fakülte ve Bölüm Seçimi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Fakülte Seçimi
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButtonFormField<int>(
                                    value: selectedFacultyId,
                                    hint: const Text(
                                      'Fakülte Seçin',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    items: faculties.map((faculty) {
                                      return DropdownMenuItem<int>(
                                        value: faculty['id'],
                                        child: Text(
                                          faculty['faculty_name'],
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      if (value == null) return;
                                      setState(() {
                                        selectedFacultyId = value;
                                        selectedDepartmentId = null;
                                        departments.clear();
                                      });
                                      await _fetchDepartments(value);
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setInt('faculty_id', value);
                                      await prefs.remove('department_id');
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              ),
                            ),
                            // Bölüm seçimi
                            if (selectedFacultyId != null &&
                                departments.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButtonFormField<int>(
                                        value: selectedDepartmentId,
                                        hint: const Text(
                                          'Bölüm Seçin',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        items: departments.map((department) {
                                          return DropdownMenuItem<int>(
                                            value: department['id'],
                                            child: Text(
                                              department['department_name'],
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          if (value == null) return;
                                          setState(() {
                                            selectedDepartmentId = value;
                                          });
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setInt(
                                              'department_id', value);
                                        },
                                        isExpanded: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Bildirim Ayarları
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bildirim Ayarları',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Genel bildirim ayarı
                          SwitchListTile(
                            title: const Text('Tüm Bildirimler'),
                            subtitle:
                                const Text('Uygulama bildirimlerini aç/kapat'),
                            value: notificationsEnabled,
                            onChanged: (bool value) async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool(
                                  'notifications_enabled', value);
                              setState(() {
                                notificationsEnabled = value;
                                // Tüm bildirimler kapatıldığında kulüp bildirimlerini de kapat
                                if (!value) {
                                  clubNotificationsEnabled = false;
                                  _updateClubNotifications(false);
                                }
                              });
                            },
                          ),
                          // Kulüp bildirimleri ayarı
                          if (notificationsEnabled)
                            SwitchListTile(
                              title: const Text('Kulüp Gönderi Bildirimleri'),
                              subtitle: const Text(
                                  'Yeni kulüp gönderilerinden haberdar ol'),
                              value: clubNotificationsEnabled,
                              onChanged: (bool value) =>
                                  _updateClubNotifications(value),
                            ),
                        ],
                      ),
                    ),
                    if (!isLoggedIn)
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                          if (result == true) {
                            _checkLoginStatus();
                          }
                        },
                        child: const Text('Yetki Girişi'),
                      ),
                    if (isLoggedIn && clubName != null) ...[
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/club-profile',
                              arguments: clubId);
                        },
                        child: Text('Kulübünüz: $clubName'),
                      ),
                      TextButton(
                        onPressed: _logout,
                        child: const Text(
                          'Çıkış Yap',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    // Debug modda test widget'ı göster
                    if (kDebugMode)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: DecorationTheme.boxDecoration(),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bildirim Testi (Debug)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            NotificationTestWidget(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
