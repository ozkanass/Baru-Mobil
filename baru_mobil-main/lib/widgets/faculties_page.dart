import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class FacultiesPage extends StatefulWidget {
  const FacultiesPage({super.key});
  @override
  State<FacultiesPage> createState() => _FacultiesPageState();
}

class _FacultiesPageState extends State<FacultiesPage> {
  List<Map<String, dynamic>> faculties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFaculties();
  }

  final String apiUrl = ApiURL.url;
  Future<void> fetchFaculties() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://$apiUrl:3000/api/faculties'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          faculties = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Yurtlar yüklenirken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fakülteler yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Link açılırken hata oluştu", 3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Fakülteler"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFaculties,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchFaculties,
              child: faculties.isEmpty
                  ? Center(
                      child: AppTheme.defaultEmptyText(
                          'Henüz Fakülte Bulunmamaktadır'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: faculties.length,
                      itemBuilder: (context, index) {
                        final faculty = faculties[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: DecorationTheme.boxDecoration(),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    faculty['faculty_name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (faculty['url'] != null &&
                                    faculty['url'].isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.language,
                                        color: AppTheme.primaryColor),
                                    title: Text(faculty['url']),
                                    onTap: () => _launchUrl(faculty['url']),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
