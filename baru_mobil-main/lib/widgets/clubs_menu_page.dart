import 'package:baru_mobil/widgets/edit_post_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:baru_mobil/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ClubsMenuPage extends StatefulWidget {
  const ClubsMenuPage({super.key});

  @override
  State<ClubsMenuPage> createState() => _ClubsMenuPageState();
}

class _ClubsMenuPageState extends State<ClubsMenuPage> {
  List<Map<String, dynamic>> clubPosts = [];
  bool isLoading = true;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    fetchClubPosts();

    // Türkçe dil desteği
    _checkLoginStatus();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> fetchClubPosts() async {
    try {
      final response = await http.get(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs-posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Debug için her postun bilgilerini yazdır
        /* for (var post in data) {
          print('=== Post Debug ===');
          print('Title: ${post['post_title']}');
          print('Content: ${post['post_content']}');
          print('Media Files: ${post['media_files']}');
          print('Has Media: ${post['has_media']}');
          print('==================\n');
        }*/

        setState(() {
          clubPosts = List<Map<String, dynamic>>.from(data);
          isLoading = false;
          _currentIndexNotifier.value = 0;
        });
      } else {
        throw Exception('Gönderiler yüklenirken hata oluştu');
      }
    } catch (e) {
      print('Fetch Error: $e'); // Debug için
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderiler yüklenirken hata: $e')),
        );
      }
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      print('Silinecek post ID: $postId'); // Debug log

      final response = await http.delete(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs-posts/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Silme işlemi yanıtı: ${response.statusCode}'); // Debug log
      print('Yanıt içeriği: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        await fetchClubPosts(); // Listeyi yenile
        if (mounted) {
          ToastMessage.showToast(context, 'Gönderi silindi', 3);
        }
      } else {
        throw Exception(
            'Gönderi silinirken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Silme hatası detayı: $e'); // Debug log
      rethrow; // Hatayı yukarı fırlat
    }
  }

  Future<void> editPost(
      int postId, String postTitle, String postContent) async {
    try {
      print('Düzenlecek post ID: $postId'); // Debug log

      final response = await http.put(
          Uri.parse('http://${ApiURL.url}:3000/api/clubs-posts/$postId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'post_title': postTitle, 'post_content': postContent}));

      print('Düzenleme işlemi yanıtı: ${response.statusCode}'); // Debug log
      if (response.statusCode == 200) {
        await fetchClubPosts(); // Listeyi yenile
        if (mounted) {
          ToastMessage.showToast(context, 'Gönderi düzenlendi', 3);
        }
      } else {
        throw Exception(
            'Gönderi düzenlenirken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Düzenleme hatası detayı: $e'); // Debug log
      rethrow; // Hatayı yukarı fırlat
    }
  }

  bool isLoggedIn = false;
  String? clubName;
  int? clubId;
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

  Widget _buildClubLogo(String? logoUrl, String clubName) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: DecorationTheme.iconsDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          /*child: Image.asset(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo(clubName);
            },
          ),*/
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _buildFallbackLogo(clubName),
          ),
        ),
      );
    }
    return _buildFallbackLogo(clubName);
  }

  Widget _buildFallbackLogo(String clubName) {
    return Container(
      width: 50,
      height: 50,
      decoration: DecorationTheme.iconsDecoration(),
      padding: const EdgeInsets.all(14),
      child: Text(
        clubName.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildPopUpMenu(BuildContext context, Map<String, dynamic> post) {
    return PopupMenuButton(
      color: AppTheme.background,
      icon: const Icon(Icons.more_horiz, size: 20),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: "delete_post",
            child: Text("Gönderi Sil", style: TextStyle(color: Colors.red))),
        const PopupMenuItem(
            value: "Gönderi Düzenle",
            child: Text("Gönderi Düzenle")), //Test için yoruma alındı
      ],
      onSelected: (value) async {
        if (value == "delete_post") {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Gönderi Silinecek'),
              content:
                  const Text('Bu gönderiyi silmek istediğinize emin misiniz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await deletePost(post['id']);
                    } catch (e) {
                      if (mounted) {
                        print('Silme hatası: $e'); // Debug log
                        ToastMessage.showToast(
                            context, "Gönderi silinemedi: $e", 3);
                      }
                    }
                  },
                  child: const Text('Sil'),
                ),
              ],
            ),
          );
        }
        if (value == "Gönderi Düzenle") {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPostPage(
                postId: post['id'],
                postTitle: post['post_title'],
                postContent: post['post_content'],
              ),
            ),
          );

          if (result == true) {
            setState(() => isLoading = true);
            await fetchClubPosts();
          }
        }
      },
    );
  }

  // Tam ekran resim görüntüleme widget'ı
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Resim
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error_outline,
                          color: Colors.red, size: 50),
                    ),
                  ),
                ),
              ),
              // Kapatma butonu
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Kulüp Gönderileri"),
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
              });
              fetchClubPosts();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: fetchClubPosts,
                  child: clubPosts.isEmpty
                      ? Center(
                          child: AppTheme.defaultEmptyText(
                              'Henüz gönderi bulunmamaktadır'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: clubPosts.length,
                          itemBuilder: (context, index) {
                            final post = clubPosts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration:
                                    DecorationTheme.boxDecoration().copyWith(
                                  boxShadow: [AppTheme.cardShadow],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kulüp başlığı ve tarih
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildClubLogo(post['club_logo'],
                                              post['club_name'] ?? ''),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  post['club_name'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  timeago.format(
                                                    DateTime.parse(
                                                        post['post_date']),
                                                    locale: 'tr',
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isLoggedIn &&
                                              clubName != null &&
                                              clubId == post['club_id'])
                                            buildPopUpMenu(context, post),
                                        ],
                                      ),
                                    ),

                                    // Post başlığı
                                    if (post['post_title'] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          post['post_title'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),

                                    // Medya içeriği
                                    if (post['has_media'] == 1 &&
                                        post['media_files'] != null &&
                                        post['media_files'].isNotEmpty)
                                      Container(
                                        height: 400,
                                        child: Stack(
                                          children: [
                                            CarouselSlider(
                                              options: CarouselOptions(
                                                height: 400,
                                                viewportFraction: 1.0,
                                                enableInfiniteScroll: false,
                                                enlargeCenterPage: false,
                                                onPageChanged: (index, reason) {
                                                  _currentIndexNotifier.value =
                                                      index;
                                                },
                                              ),
                                              items: List<Widget>.from(
                                                (post['media_files'] as List)
                                                    .map((media) {
                                                  return SizedBox(
                                                    width: double.infinity,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _showFullScreenImage(
                                                              context,
                                                              media[
                                                                  'image_url']),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            media['image_url'],
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                        errorWidget: (context,
                                                            url, error) {
                                                          print(
                                                              'Resim yüklenirken hata oluştu');
                                                          return const Center(
                                                            child: Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color:
                                                                    Colors.red),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                            // Resim sayacı
                                            if ((post['media_files'] as List)
                                                    .length >
                                                1)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: ValueListenableBuilder<
                                                      int>(
                                                    valueListenable:
                                                        _currentIndexNotifier,
                                                    builder: (context,
                                                        currentIndex, _) {
                                                      return Text(
                                                        '${currentIndex + 1}/${(post['media_files'] as List).length}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                    // Post içeriği
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        post['post_content'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
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
