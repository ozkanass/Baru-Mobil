import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:baru_mobil/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class DormsPage extends StatefulWidget {
  const DormsPage({super.key});

  @override
  State<DormsPage> createState() => _DormsPageState();
}

class _DormsPageState extends State<DormsPage> {
  List<Map<String, dynamic>> dorms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDorms();
  }

  final String apiUrl = ApiURL.url;
  Future<void> fetchDorms() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse('http://$apiUrl:3000/api/dorms'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          dorms = List<Map<String, dynamic>>.from(data);
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
          SnackBar(content: Text('Yurtlar yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        //add toast message
        ToastMessage.showToast(context, "Hata oluştu", 3);
      }
    }
  }

  Future<void> copyClipboard(String copyText) async {
    await Clipboard.setData(ClipboardData(text: copyText));
    if (mounted) {}
  }

  Future<void> openMap(String location) async {
    try {
      final String encodedAddress = Uri.encodeComponent(location);
      final String mapUrl = Platform.isIOS
          ? "https://maps.apple.com/?q=$encodedAddress"
          : "https://www.google.com/maps/search/?api=1&query=$encodedAddress";

      final Uri url = Uri.parse(mapUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Yurtlar"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDorms,
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
              onRefresh: fetchDorms,
              child: dorms.isEmpty
                  ? Center(
                      child: AppTheme.defaultEmptyText(
                          'Henüz yurt bulunmamaktadır'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dorms.length,
                      itemBuilder: (context, index) {
                        final dorm = dorms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: DecorationTheme.boxDecoration(),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              Text(
                                                dorm['name'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                dorm['location'] ?? '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => copyClipboard(
                                                    dorm['location']),
                                                icon: const Icon(Icons.copy),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (dorm['url'] != null &&
                                            dorm['url'].isNotEmpty)
                                          ListTile(
                                            leading: const Icon(Icons.language,
                                                color: AppTheme.primaryColor),
                                            title: const Text('Web Sitesi'),
                                            onTap: () =>
                                                _launchUrl(dorm['url']),
                                          ),
                                        if (dorm['telNo'] != null &&
                                            dorm['telNo'].isNotEmpty)
                                          ListTile(
                                            leading: const Icon(Icons.phone,
                                                color: AppTheme.primaryColor),
                                            title: Text(dorm['telNo']),
                                            onTap: () => _launchUrl(
                                                'tel:${dorm['telNo']}'),
                                          ),
                                        if (dorm['location'] != null &&
                                            dorm['location'].isNotEmpty)
                                          ListTile(
                                            leading: const Icon(
                                                Icons.location_on,
                                                color: AppTheme.primaryColor),
                                            title:
                                                const Text('Haritada Göster'),
                                            onTap: () =>
                                                openMap(dorm['location']),
                                          ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.apartment,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dorm['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (dorm['location'] != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              dorm['location'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.more_vert,
                                      size: 24,
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
