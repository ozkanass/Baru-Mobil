import 'dart:typed_data';
import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';
import 'package:baru_mobil/widgets/clubs_menu_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostPage extends StatefulWidget {
  final int? postId;
  final String? postTitle;
  final String? postContent;

  CreatePostPage({this.postId, this.postTitle, this.postContent});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  List<String> imageUrls = [];
  bool isLoading = false;
  bool isPermissionGranted = false;
  static const int maxImages = 5; // Maximum resim sayısı
  int? clubId;
  String? postTitle;
  String? postContent;
  @override
  void initState() {
    super.initState();
    _loadClubId();
    titleController.text = widget.postTitle ?? '';
    contentController.text = widget.postContent ?? '';
    setState(() {
      postTitle = widget.postTitle;
      postContent = widget.postContent;
    });
  }

  initialValue() {
    titleController.text = widget.postTitle ?? '';
    contentController.text = widget.postContent ?? '';
  }

  Future<void> _loadClubId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      clubId = prefs.getInt('club_id');
    });
  }

  Future<void> checkPermission() async {
    // Resim sayısı kontrolü
    if (imageUrls.length >= maxImages) {
      ToastMessage.showToast(context, "En fazla 5 resim ekleyebilirsiniz", 3);
      return;
    }

    try {
      Permission permission = Permission.photos;
      var status = await permission.status;

      if (status.isDenied) {
        status = await permission.request();
        if (!status.isGranted) {
          if (mounted) {
            ToastMessage.showToast(
                context, "Galeriye erişim izni reddedildi", 3);
          }
          return;
        }
      }

      if (status.isGranted) {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxHeight: 1000,
          maxWidth: 1000,
        );

        if (image == null) return;

        setState(() => isLoading = true);

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
          setState(() {
            imageUrls.add(jsonData['url']);
          });
        } else {
          throw Exception('Resim yüklenemedi');
        }
      }
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Resim yüklenemedi!", 3);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => isLoading = true);

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
        setState(() {
          imageUrls.add(jsonData['url']);
        });
      } else {
        throw Exception('Resim yüklenemedi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim yükleme hatası: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> createPost() async {
    if (clubId == null) {
      ToastMessage.showToast(context, "Yetkiniz bulunmamaktadır", 3);
      return;
    }

    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ToastMessage.showToast(
          context, "Başlık ya da içerik kısmı girilmelidir", 3);
      return;
    }

    if (contentController.text.trim().length < 10) {
      ToastMessage.showToast(context, "İçerik en az 10 karakter olmalıdır", 3);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs-posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'club_id': clubId,
          'post_title': titleController.text.trim(),
          'post_content': contentController.text.trim(),
          'image_urls': imageUrls,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ToastMessage.showToast(context, "Post başarıyla oluşturuldu", 3);
          Navigator.pop(context);
        }
      } else {
        throw Exception('Post oluşturulamadı');
      }
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Bir hata oluştu", 3);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Resim ekleme butonunun görünürlüğünü kontrol eden getter
  bool get canAddMoreImages => imageUrls.length < maxImages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Yeni Gönderi"),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: createPost,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'İçerik',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  imageUrls.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (canAddMoreImages) // Resim ekleme butonu koşullu gösterimi
              ElevatedButton.icon(
                onPressed: () {
                  checkPermission();
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text(
                    'Resim Ekle'), //Text('Resim Ekle (${imageUrls.length}/$maxImages)'),
              ),
          ],
        ),
      ),
    );
  }
}
