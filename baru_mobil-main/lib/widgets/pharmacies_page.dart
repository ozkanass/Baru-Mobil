import 'dart:io';

import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class PharmaciesPage extends StatefulWidget {
  const PharmaciesPage({super.key});

  @override
  State<PharmaciesPage> createState() => _PharmaciesPageState();
}

class _PharmaciesPageState extends State<PharmaciesPage> {
  List<dynamic> pharmacies = [];
  bool isLoading = false;
  bool hasError = false;
  bool hasData = false;

  static const String apiKey = "0gHg2w63NHKfwLLJc3E9YI:7gDJlxhsuqAU6z0aXKpyLT";
  static const String apiUrl =
      "https://api.collectapi.com/health/dutyPharmacy?il=Bartin";

  Future<void> fetchPharmacies() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'apikey $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pharmacies = data['result'];
          hasData = pharmacies.isNotEmpty;
        });
      } else {
        throw Exception(
            'Eczaneler yüklenirken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('API Hatası: $e'); // Debug için
      setState(() => hasError = true);
      if (mounted) {
        ToastMessage.showToast(context, "Eczaneler yüklenirken hata oluştu", 3);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> copyClipboard(String copyText) async {
    await Clipboard.setData(ClipboardData(text: copyText));
    if (mounted) {}
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
        title: AppTheme.appBarTitle("Nöbetçi Eczaneler"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
      ),
      body: Column(
        children: [
          if (!hasData && !isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_pharmacy_outlined,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nöbetçi Eczaneleri Görüntüle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bartın\'daki nöbetçi eczaneleri listelemek için\ntıklayın',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: fetchPharmacies,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Eczaneleri Göster'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (hasData)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacies[index];
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              decoration: DecorationTheme.boxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          pharmacy['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          pharmacy['address'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.copy),
                                    title: const Text('Adresi Kopyala'),
                                    onTap: () {
                                      copyClipboard(pharmacy['address']);
                                      Navigator.pop(context);
                                      ToastMessage.showToast(
                                          context, "Adres kopyalandı", 3);
                                    },
                                  ),
                                  if (pharmacy['phone'] != null)
                                    ListTile(
                                      leading: const Icon(Icons.phone),
                                      title: const Text('Ara'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        launchUrl(Uri.parse(
                                            'tel:${pharmacy['phone']}'));
                                      },
                                    ),
                                  //Haritada görüntüleme
                                  ListTile(
                                    leading:
                                        const Icon(Icons.location_on_sharp),
                                    title: const Text('Haritada Görüntüle'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      openMap(pharmacy['address']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: DecorationTheme.boxDecoration(),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: DecorationTheme.iconsDecoration(),
                              child: const Icon(
                                Icons.local_pharmacy_outlined,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              pharmacy['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  pharmacy['dist'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pharmacy['address'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: AppTheme.primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


/*
FutureBuilder<List<dynamic>>(
        future: fetchPharmacies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Veri bulunamadı"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var pharmacy = snapshot.data![index];
              return ListTile(
                title: Text(pharmacy['name'] ?? "Bilinmiyor"),
                subtitle: Text(pharmacy['address'] ?? "Adres yok"),
              );
            },
          );
        },
      ),
    );
 */