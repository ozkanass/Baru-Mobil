import 'package:baru_mobil/widgets/clubs_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:baru_mobil/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPostPage extends StatefulWidget {
  final int postId;
  final String postTitle;
  final String postContent;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.postTitle,
    required this.postContent,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mevcut değerleri form alanlarına yerleştir
    titleController.text = widget.postTitle;
    contentController.text = widget.postContent;
  }

  Future<void> updatePost() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ToastMessage.showToast(context, "Lütfen tüm alanları doldurun", 3);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs-posts/${widget.postId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_title': titleController.text,
          'post_content': contentController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ToastMessage.showToast(context, "Gönderi güncellendi", 3);
          Navigator.pop(
              context, true); // Başarılı güncelleme durumunda geri dön
        }
      } else {
        throw Exception('Gönderi güncellenirken hata oluştu');
      }
    } catch (e) {
      if (mounted) {
        ToastMessage.showToast(context, "Gönderi güncellenemedi: $e", 3);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Gönderi Düzenle"),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: updatePost,
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
