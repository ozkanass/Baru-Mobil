import 'dart:convert';

import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DepartmentsAnnouncesPage extends StatefulWidget {
  const DepartmentsAnnouncesPage({super.key});

  @override
  State<DepartmentsAnnouncesPage> createState() =>
      _DepartmentsAnnouncesPageState();
}

class _DepartmentsAnnouncesPageState extends State<DepartmentsAnnouncesPage> {
  List<Map<String, dynamic>> announces = [];
  bool isLoading = true;
  bool isError = false;
  String? departmentUrl;
  String? departmentName;

  @override
  void initState() {
    super.initState();
    _loadDepartmentInfo();
  }

  Future<void> _loadDepartmentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final departmentId = prefs.getInt('department_id');

    if (departmentId != null) {
      try {
        print('Requesting department info for ID: $departmentId'); // Debug log

        final response = await http.get(
          Uri.parse('http://${ApiURL.url}:3000/api/departments/$departmentId'),
        );

        print('API Response Status: ${response.statusCode}'); // Debug log
        print('API Response Body: ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            departmentUrl = data['url'];
            departmentName = data['department_name'];
          });

          print('Department URL: $departmentUrl'); // Debug log
          print('Department Name: $departmentName'); // Debug log

          await fetchDepartmentAnnounces();
        } else {
          print('API Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Bölüm bilgisi yükleme hatası: $e');
      }
    } else {
      print('No department ID found in SharedPreferences');
    }
  }

  Future<void> fetchDepartmentAnnounces() async {
    print('Bölüm URL: $departmentUrl');
    print('Bölüm Adı: $departmentName');
    if (departmentUrl == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(departmentUrl!));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Duyuru listesi container'ı
        final announceContainer = document.querySelector('.duyuru');
        if (announceContainer == null) {
          print('Duyuru listesi bulunamadı');
          return;
        }

        // Tüm duyuruları al
        final announceElements = announceContainer.getElementsByTagName('li');
        List<Map<String, dynamic>> tempAnnounces = [];

        for (var element in announceElements) {
          try {
            // Başlık ve link
            final titleLink = element.querySelector('.duyuru-icerik');
            final title = titleLink?.text.trim() ?? '';
            var link = element.querySelector('a')?.attributes['href'] ?? '';

            // linkin baş tarafında departmentUrl yoksa ekle
            if (!link.contains('https://')) {
              link = '$departmentUrl$link';
            }

            // Tarih
            final dateElement = element.querySelector('.duyuru-tarih');
            final date = dateElement?.text.trim() ?? '';

            if (title.isNotEmpty) {
              tempAnnounces.add({
                'title': title,
                'date': date,
                'link': link.startsWith('http') ? link : '$departmentUrl$link',
              });
            }
          } catch (e) {
            print('Duyuru ayrıştırma hatası: $e');
          }
        }

        setState(() {
          announces = tempAnnounces;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Duyuru çekme hatası: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, 'Link açılırken bir hata oluştu', 3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle(departmentName ?? 'Bölüm Duyuruları',
            fontSize: 16),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                isError = false;
              });
              fetchDepartmentAnnounces();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : announces.isEmpty
              ? const Center(child: Text('Duyuru bulunamadı'))
              : ListView.builder(
                  itemCount: announces.length,
                  itemBuilder: (context, index) {
                    final announce = announces[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: DecorationTheme.boxDecoration(),
                      child: ListTile(
                        title: Text(
                          announce['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(announce['date'] ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _launchUrl(announce['link']);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
