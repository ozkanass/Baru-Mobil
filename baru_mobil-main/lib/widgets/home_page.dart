import 'package:flutter/material.dart';
import 'package:baru_mobil/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  bool isError = false;
  bool isLoggedIn = false;
  int? clubId;
  int? facultyId;
  int? departmentId;
  List<Map<String, dynamic>> faculties = [];
  Map<String, dynamic>? lastClubPost;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
    _checkLoginStatus();
    fetchLastClubPost();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final response = await http
          .get(Uri.parse('https://w3.bartin.edu.tr/arsiv/duyuru-arsiv.html'));

      if (response.statusCode == 200) {
        try {
          final document = html_parser.parse(response.body);
          final elements = document.getElementsByClassName('col-75');

          if (elements.isNotEmpty && elements.length > 6) {
            final elements2 = elements[6].getElementsByTagName('a');

            if (elements2.isNotEmpty) {
              setState(() {
                // Sadece ilk 5 duyuruyu al
                announcements = elements2.take(5).map((element) {
                  final title = element.text.toString().trim();
                  final url = element.attributes['href']
                              ?.contains('https://') ==
                          true
                      ? element.attributes['href']
                      : 'https://w3.bartin.edu.tr${element.attributes['href']}';

                  return {
                    'title': title.isNotEmpty ? title : 'Başlık bulunamadı',
                    'url': url ?? '',
                    'date': DateTime.now().toString(), // Şimdilik geçici tarih
                  };
                }).toList();
                isLoading = false;
                isError = false;
              });
              return;
            }
          }
          throw Exception('Duyurular bulunamadı');
        } catch (e) {
          print('HTML parse hatası: $e');
          setState(() {
            isError = true;
            isLoading = false;
          });
        }
      } else {
        throw Exception('HTTP hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Genel hata: $e');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final clubIdFromPrefs = prefs.getInt('club_id');
    final facultyIdFromPrefs = prefs.getInt('faculty_id'); // Fakülte ID'sini al
    final departmentIdFromPrefs = prefs.getInt('department_id');

    setState(() {
      isLoggedIn = clubIdFromPrefs != null;
      clubId = clubIdFromPrefs;
      facultyId = facultyIdFromPrefs; // Fakülte ID'sini state'e kaydet
      departmentId = departmentIdFromPrefs;
    });
  }

  Future<void> fetchLastClubPost() async {
    try {
      final response = await http.get(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs-last-posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            lastClubPost =
                data.isNotEmpty ? Map<String, dynamic>.from(data.first) : null;
          });
        }
      } else {
        throw Exception('Gönderi yüklenemedi');
      }
    } catch (e) {
      print('Son kulüp gönderisi yüklenirken hata: $e');
      if (mounted) {
        ToastMessage.showToast(context, "Gönderi yüklenirken hata oluştu", 3);
      }
    }
  }

  Widget _buildAnnouncementSlider() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError) {
      return Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Duyurular yüklenirken bir hata oluştu'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: fetchAnnouncements,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (announcements.isEmpty) {
      return const Center(child: Text('Duyuru bulunamadı'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: Swiper(
            itemCount: announcements.length,
            autoplay: true,
            autoplayDelay: 5000,
            duration: 800,
            viewportFraction: 0.85,
            scale: 0.9,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return GestureDetector(
                onTap: () {
                  if (announcement['url'] != null &&
                      announcement['url'].isNotEmpty) {
                    launchUrl(Uri.parse(announcement['url']));
                  }
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: DecorationTheme.boxDecoration(),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              announcement['date'] != null
                                  ? DateTime.parse(announcement['date'])
                                      .toString()
                                      .split('.')[0]
                                  : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppTheme.appBarTitle("Barü Mobil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Bildirimler sayfasına yönlendirme
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings-page');
              // Ayarlardan dönünce login durumunu kontrol et
              _checkLoginStatus();
            },
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          await fetchLastClubPost();
          setState(() {});
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arama çubuğu
              /*Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Ne aramak istersiniz?",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),*/
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Hızlı Erişim",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Hızlı erişim grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: const EdgeInsets.all(24),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: _buildQuickAccessItems(),
              ),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Son Duyurular',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildAnnouncementSlider(),

              // Son atılan kulüp gönderisi , tarihe göre
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Bileşenleri iki uca iter
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Son Kulüp Gönderisi",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/clubs-menu-page');
                    },
                    child: const Text(
                      "Tümünü Gör",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              _buildLastClubPost(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuickAccessItems() {
    List<Widget> items = [
      _buildQuickAccessItem(
        context,
        "/announce-page",
        "Duyurular",
        Icons.campaign_outlined,
        AppTheme.primaryColor,
      ),
      _buildQuickAccessItem(
        context,
        "/cafeteria-page",
        "Yemekhane",
        Icons.restaurant_outlined,
        AppTheme.secondaryColor,
      ),
      _buildQuickAccessItem(
        context,
        "/dorms-page",
        "Yurtlar",
        Icons.apartment_outlined,
        AppTheme.primaryColor.withOpacity(0.8),
      ),
      _buildQuickAccessItem(
        context,
        "/clubs-menu-page",
        "Kulüp Gönderileri",
        Icons.my_library_books_outlined,
        AppTheme.primaryColor.withOpacity(0.8),
      ),
    ];

    /* if (isLoggedIn && clubId != null) {
      items.add(
        _buildQuickAccessItem(
          context,
          "/create-post-page",
          "Gönderi Oluştur",
          Icons.post_add_outlined,
          AppTheme.primaryColor.withOpacity(0.8),
        ),
      );
    }*/
    if (facultyId != null) {
      items.add(
        _buildQuickAccessItem(
          context,
          "/faculties-announces-page",
          "Fakülte Duyuruları",
          Icons.school,
          AppTheme.primaryColor.withOpacity(0.8),
        ),
      );
    }
    if (departmentId != null) {
      items.add(
        _buildQuickAccessItem(
          context,
          "/departments-announces-page",
          "Bölüm Duyuruları",
          Icons.class_,
          AppTheme.primaryColor.withOpacity(0.8),
        ),
      );
    }

    return items;
  }

  Widget _buildQuickAccessItem(BuildContext context, String route, String title,
      IconData icon, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildDrawerHeader(),
                buildDrawerr(context, "/announce-page", "Duyurular",
                    Icons.campaign_outlined,
                    kategori: "Duyurular"),

                // Fakülte ID'si varsa fakülte duyurularını göster
                if (facultyId != null)
                  buildDrawerr(context, "/faculties-announces-page",
                      "Fakülte Duyuruları", Icons.school),

                // Bölüm ID'si varsa bölüm duyurularını göster
                if (departmentId != null)
                  buildDrawerr(context, "/departments-announces-page",
                      "Bölüm Duyuruları", Icons.class_),

                buildDrawerr(
                    context, "/cafeteria-page", "Yemekhane", Icons.restaurant,
                    kategori: "Sayfalar"),
                buildDrawerr(context, "/clubs-menu-page", "Kulüp Gönderileri",
                    Icons.groups_2_sharp),
                buildDrawerr(
                    context, "/clubs-page", "Kulüp Listesi", Icons.group),
                buildDrawerr(context, "/pharmacies-page", "Nöbetçi Eczaneler",
                    Icons.heart_broken_outlined),

                buildDrawerr(context, "/dorms-page", "Yurtlar", Icons.schema),
                buildDrawerr(context, "/faculties-page", "Akademik Birimler",
                    Icons.screen_share,
                    kategori: "Akademik"),
                /*buildDrawerr(context, "/faculties2-page",
                    "Yabancı Diller Yüksekokulu", Icons.screen_share,
                    kategori: "Yüksekokullar"),
                buildDrawerr(
                  context,
                  "/vocation-colleges-page",
                  "Meslek Yüksekokulları",
                  Icons.screen_share,
                ),*/
                buildDrawerr(
                    context, "/settings-page", "Ayarlar", Icons.settings,
                    kategori: "Ayarlar"),
                buildDrawerr(
                    context, "/", "Geri Bildirim Gonder", Icons.screen_share,
                    kategori: "Destek"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildDrawerHeader() {
    return const SizedBox(
      height: 80, // Yüksekliği düşür
      child: const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.transparent, // Arka plan rengi
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25, // Avatar boyutunu küçült
              backgroundColor: Colors.white,
              child: Icon(
                Icons.school,
                size: 30, // İkon boyutunu küçült
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 10), // Boşluğu azalt
            Text(
              "Barü Mobil",
              style: TextStyle(
                fontSize: 24, // Font boyutunu küçült
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerr(
      BuildContext context, String route, String title, IconData icon,
      {String? kategori}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Başlığı (Eğer varsa)
        if (kategori != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              kategori,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        // Menü Elemanı
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: ListTile(
            leading: Icon(
              icon,
              color: Colors.blue,
              size: 20.0,
            ),
            title: Text(title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildLastClubPost() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          if (lastClubPost == null)
            Container(
              height: 200, // Minimum yükseklik için
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Henüz gönderi bulunmamaktadır',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            _buildLastClubPostCard(),
        ],
      ),
    );
  }

  Widget _buildLastClubPostCard() {
    List<String> mediaUrls = [];
    if (lastClubPost!['media_urls'] != null) {
      mediaUrls = lastClubPost!['media_urls'].toString().split(',');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: DecorationTheme.boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kulüp son post bilgisi
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/clubs-menu-page');
              },
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: lastClubPost!['club_logo'] != null
                    ? CachedNetworkImageProvider(lastClubPost!['club_logo'])
                    : null,
                child: lastClubPost!['club_logo'] == null
                    ? Text(
                        lastClubPost!['club_name']
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'K',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                lastClubPost!['club_name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                lastClubPost!['post_date'] != null
                    ? timeago.format(
                        DateTime.parse(lastClubPost!['post_date']),
                        locale: 'tr',
                      )
                    : '',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            // Post başlığı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lastClubPost!['post_title'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Post içeriği (içerik gösterimi şuanlık kapalı)
            /*Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                lastClubPost!['post_content'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),*/
            SizedBox(height: 12),
            // Medya varsa ilk resmi göster
            if (mediaUrls.isNotEmpty && mediaUrls.first.isNotEmpty)
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: mediaUrls.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}
