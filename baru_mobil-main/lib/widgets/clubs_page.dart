import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:baru_mobil/main.dart';
import 'club_card.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});
  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  List<Map<String, dynamic>> clubs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClubs();
  }

  final String apiUrl = ApiURL.url;
  Future<void> fetchClubs() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse('http://${ApiURL.url}:3000/api/clubs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clubs = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Kulüpler yüklenirken hata oluştu: ${response.statusCode}');
      }
      // logo_url i al CachedNetworkImage ile göster
      clubs.forEach((club) {
        print("logo_url ${club['name']}: ${club['logo_url']}");
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kulüpler yüklenirken bir hata oluştu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle("Öğrenci Kulüpleri"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchClubs,
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
              onRefresh: fetchClubs,
              child: clubs.isEmpty
                  ? Center(
                      child: AppTheme.defaultEmptyText(
                          'Henüz kulüp bulunmamaktadır'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ClubCard(
                            title: club['name'] ?? '',
                            logoPath: club['logo_url'] ?? '',
                            description: club['description'] ?? '',
                            websiteUrl: club['website_url'],
                            instagramUrl: club['instagram_url'],
                            twitterUrl: club['twitter_url'],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
