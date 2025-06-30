import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class Faculties2Page extends StatefulWidget {
  const Faculties2Page({super.key});
  @override
  State<Faculties2Page> createState() => _Faculties2PageState();
}

class _Faculties2PageState extends State<Faculties2Page> {
  List<Map<String, dynamic>> colleges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  final String apiUrl = ApiURL.url;
  Future<void> fetchColleges() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://$apiUrl:3000/api/faculties2'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          colleges = List<Map<String, dynamic>>.from(data);
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
          SnackBar(
              content: Text('Yüksekokullar yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Hata oluştu", 3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Yüksekokullar"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchColleges,
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
              onRefresh: fetchColleges,
              child: colleges.isEmpty
                  ? Center(
                      child: AppTheme.defaultEmptyText(
                          'Henüz Yüksekokul Bulunmamaktadır'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: colleges.length,
                      itemBuilder: (context, index) {
                        final college = colleges[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: DecorationTheme.boxDecoration(),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    college['colleges_name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (college['url'] != null &&
                                    college['url'].isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.language,
                                        color: AppTheme.primaryColor),
                                    title: Text(college['url']),
                                    onTap: () => _launchUrl(college['url']),
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
