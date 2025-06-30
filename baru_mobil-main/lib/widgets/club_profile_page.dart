import 'package:flutter/material.dart';
import 'package:baru_mobil/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClubProfilePage extends StatefulWidget {
  final int clubId;

  const ClubProfilePage({super.key, required this.clubId});

  @override
  State<ClubProfilePage> createState() => _ClubProfilePageState();
}

class _ClubProfilePageState extends State<ClubProfilePage> {
  Map<String, dynamic> clubInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubInfo();
  }

  Future<void> _loadClubInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs/${widget.clubId}'),
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

  Future<void> _updateLogo() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 1000,
        maxWidth: 1000,
      );

      if (image == null) return;

      setState(() => isLoading = true);

      // Imgur'a yükle
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://${ApiURL.url}:3000/api/upload-image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        // Logo URL'ini güncelle
        final updateResponse = await http.put(
          Uri.parse(
              'http://${ApiURL.url}:3000/api/clubs/${widget.clubId}/logo'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'logo_url': jsonData['url']}),
        );

        if (updateResponse.statusCode == 200) {
          await _loadClubInfo(); // Kulüp bilgilerini yeniden yükle
          if (mounted) {
            ToastMessage.showToast(context, "Logo güncellendi", 3);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Logo güncellenirken hata oluştu", 3);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showLogoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Logoyu Görüntüle'),
            onTap: () {
              Navigator.pop(context);
              if (clubInfo['logo_url'] != null && clubInfo['logo_url'] != "") {
                print("logo_url: ${clubInfo['logo_url']}");
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: CachedNetworkImage(
                      imageUrl: clubInfo['logo_url'],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              } else {
                print("logo_url yok");
                ToastMessage.showToast(context, "Logo bulunamadı", 3);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Logoyu Değiştir'),
            onTap: () {
              Navigator.pop(context);
              _updateLogo();
              if (isLoading) {
                // ToastMessage.showToast(context, "Logo güncellendi", 3);
                print("Kulüp Logosu güncellendi");
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle('Kulüp Profili'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Logo
                  Center(
                    child: GestureDetector(
                      onTap: _showLogoOptions,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: clubInfo['logo_url'] != null
                            ? CachedNetworkImageProvider(clubInfo['logo_url'])
                            : null,
                        child: clubInfo['logo_url'] == null
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Kulüp Adı
                  Text(
                    clubInfo['name'] ?? 'Kulüp Adı',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Post Oluştur Kartı - HomePage'deki stil ile aynı
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildQuickAccessItem(
                      context,
                      "/create-post-page",
                      "Gönderi Oluştur",
                      Icons.post_add_outlined,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
    );
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
