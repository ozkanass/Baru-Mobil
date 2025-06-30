import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baru_mobil/main.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClubCard extends StatelessWidget {
  final String title;
  final String logoPath;
  final String description;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? twitterUrl;

  const ClubCard({
    super.key,
    required this.title,
    required this.logoPath,
    required this.description,
    this.websiteUrl,
    this.instagramUrl,
    this.twitterUrl,
  });

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      debugPrint('URL açılırken hata oluştu: $e');
    }
  }

  Widget _buildLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: logoPath.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logoPath,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => _buildFallbackLogo(),
              )
            : _buildFallbackLogo(),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : 'K',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor.withOpacity(0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (websiteUrl != null && websiteUrl != '')
                    ListTile(
                      leading: const Icon(Icons.language,
                          color: AppTheme.primaryColor),
                      title: const Text('Web Sitesi'),
                      onTap: () => _launchUrl(websiteUrl!),
                    ),
                  if (instagramUrl != null && instagramUrl != '')
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined,
                          color: Colors.pink),
                      title: const Text('Instagram'),
                      onTap: () => _launchUrl(instagramUrl!),
                    ),
                  if (twitterUrl != null && twitterUrl != '')
                    ListTile(
                      leading: const Icon(Icons.flutter_dash,
                          color: AppTheme.primaryColor),
                      title: const Text('Twitter'),
                      onTap: () => _launchUrl(twitterUrl!),
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
              _buildLogo(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
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
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
