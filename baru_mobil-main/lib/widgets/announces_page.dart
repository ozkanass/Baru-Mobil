import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

class AnnouncePage extends StatefulWidget {
  const AnnouncePage({super.key});

  @override
  _AnnouncePageState createState() => _AnnouncePageState();
}

class _AnnouncePageState extends State<AnnouncePage> {
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link açılırken bir hata oluştu')),
        );
      }
    }
  }

  Future<void> fetchAnnouncements() async {
    try {
      // Önce web sitesinden çekmeyi dene
      final response = await http
          .get(Uri.parse('https://w3.bartin.edu.tr/arsiv/duyuru-arsiv.html'));

      if (response.statusCode == 200) {
        try {
          // HTML parse etmeyi dene
          final document = html_parser.parse(response.body);
          final elements = document.getElementsByClassName('col-75');

          if (elements.isNotEmpty && elements.length > 6) {
            final elements2 = elements[6].getElementsByTagName('a');

            if (elements2.isNotEmpty) {
              setState(() {
                announcements = elements2.map((element) {
                  final title = element.text.toString().trim();
                  return {
                    'title': title.isNotEmpty ? title : 'Başlık bulunamadı',
                    if (element.attributes['href'] != null &&
                        element.attributes['href']?.contains('https://') ==
                            true)
                      'url': element.attributes['href']
                    else
                      'url':
                          'https://w3.bartin.edu.tr${element.attributes['href']}' ??
                              '',
                  };
                }).toList();
                isLoading = false;
                isError = false;
              });
              return; // Başarılı olursa fonksiyondan çık
            }
          }
          // HTML yapısı beklediğimiz gibi değilse veritabanından çek
          // await fetchAnnouncementsFromDatabase();
        } catch (e) {
          print('HTML parse hatası: $e');
          // Parse hatası olursa veritabanından çek
          //await fetchAnnouncementsFromDatabase();
        }
      } else {
        // HTTP hatası olursa veritabanından çek
        // await fetchAnnouncementsFromDatabase();
      }
    } catch (e) {
      print('Genel hata: $e');
      // Herhangi bir hata durumunda veritabanından çek
      //await fetchAnnouncementsFromDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle('Duyurular'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                isError = false;
              });
              fetchAnnouncements();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Duyurular yükleniyor...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppTheme.errorColor),
                      const SizedBox(height: 16),
                      const Text(
                        'Duyurular yüklenirken bir hata oluştu',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            isError = false;
                          });
                          fetchAnnouncements();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAnnouncements,
                  child: announcements.isEmpty
                      ? Center(
                          child: AppTheme.defaultEmptyText(
                              'Henüz duyuru bulunmamaktadır'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: announcements.length,
                          itemBuilder: (context, index) {
                            final announcement = announcements[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: DecorationTheme.boxDecoration(),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    if (announcement['url']?.isNotEmpty ==
                                        true) {
                                      print(
                                          "URL Link : ${announcement['url']}");
                                      _launchUrl(announcement['url']!);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration:
                                              DecorationTheme.iconsDecoration(),
                                          child: const Icon(
                                            Icons.campaign_outlined,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                announcement['title']!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
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
