import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class VocationCollegesPage extends StatefulWidget {
  const VocationCollegesPage({super.key});
  @override
  State<VocationCollegesPage> createState() => _VocationCollegesPageState();
}

class _VocationCollegesPageState extends State<VocationCollegesPage> {
  List<Map<String, dynamic>> vocationColleges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVocationColleges();
  }

  final String apiUrl = ApiURL.url;
  Future<void> fetchVocationColleges() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://$apiUrl:3000/api/vocation_colleges'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vocationColleges = List<Map<String, dynamic>>.from(data);
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
            onPressed: fetchVocationColleges,
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
              onRefresh: fetchVocationColleges,
              child: vocationColleges.isEmpty
                  ? Center(
                      child: AppTheme.defaultEmptyText(
                          'Henüz Yüksekokul Bulunmamaktadır'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vocationColleges.length,
                      itemBuilder: (context, index) {
                        final vocationCollege = vocationColleges[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    vocationCollege['vocation_colleges_name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (vocationCollege['url'] != null &&
                                    vocationCollege['url'].isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.language,
                                        color: AppTheme.primaryColor),
                                    title: Text(vocationCollege['url']),
                                    onTap: () =>
                                        _launchUrl(vocationCollege['url']),
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
