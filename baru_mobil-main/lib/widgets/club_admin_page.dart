import 'package:flutter/material.dart';
import 'package:baru_mobil/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClubAdminPage extends StatefulWidget {
  const ClubAdminPage({super.key});

  @override
  State<ClubAdminPage> createState() => _ClubAdminPageState();
}

class _ClubAdminPageState extends State<ClubAdminPage> {
  Map<String, dynamic> clubInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubInfo();
  }

  Future<void> _loadClubInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final clubId = prefs.getInt('club_id');

    try {
      final response = await http.get(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs/$clubId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          clubInfo = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Kulüp bilgileri yüklenemedi", 3);
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle('Kulübünüz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (clubInfo['logo_url'] != null)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(clubInfo['logo_url']),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    clubInfo['name'] ?? 'Kulüp Adı',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-post-page');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Gönderi Oluştur'),
                  ),
                  // Diğer kulüp yönetimi özellikleri buraya eklenebilir
                ],
              ),
            ),
    );
  }
}
