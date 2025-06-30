import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UniversityMenuPage extends StatefulWidget {
  const UniversityMenuPage({super.key});

  @override
  State<UniversityMenuPage> createState() => _UniversityMenuPageState();
}

class _UniversityMenuPageState extends State<UniversityMenuPage> {
  List<dynamic> menuItems = [];
  bool isLoading = true;
  List<dynamic> todayMenu = [];

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse('http://${ApiURL.url}:3000/api/yemekler'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> menuList = [];

        // JSON'dan gelen veriyi işle
        data.forEach((date, menuItems) {
          menuList.add({
            'tarih': date,
            'yemekler': menuItems as List<dynamic>,
            //'kalori': '750-850', // Sabit kalori değeri veya null olarak bırakabilirsiniz
          });
        });

        // Tarihe göre sırala
        menuList.sort(
            (a, b) => a['tarih'].toString().compareTo(b['tarih'].toString()));

        setState(() {
          menuItems = menuList;
          isLoading = false;
        });
      } else {
        throw Exception('Yemek listesi yüklenemedi');
      }
    } catch (e) {
      print('Hata: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ToastMessage.showToast(context, "Yemek listesi yüklenemedi", 3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.appBarTitle('Yemekhane Menüsü'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 30.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMenu,
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
              onRefresh: fetchMenu,
              child: menuItems.isEmpty
                  ? Center(
                      child: AppTheme.defaultEmptyText('Menü bulunamadı'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final menu = menuItems[index];
                        //bugünün tarihini al
                        final today =
                            "${DateTime.now().day}/0${DateTime.now().month}/${DateTime.now().year}";
                        //bugün ile jsondaki tarih eşleşiyorsa true döndür
                        print("Today : $today");
                        final isToday = menu['tarih'] == today;
                        final getDailyMenu = menu['tarih'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: Container(
                              decoration: isToday
                                  ? DecorationTheme.todayMenuDecoration()
                                  : DecorationTheme.boxDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tarih başlığı
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          menu['tarih'] ?? '',
                                          style: TextStyle(
                                            fontSize: isToday ? 16 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Yemek listesi
                                  Container(
                                    color: isToday
                                        ? AppTheme.primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...(menu['yemekler'] as List<dynamic>)
                                              .map(
                                                (yemek) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.restaurant,
                                                        size: 16,
                                                        color: isToday
                                                            ? AppTheme
                                                                .successColor
                                                            : AppTheme
                                                                .primaryColor,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          yemek.toString(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: isToday
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          //const Divider(),
                                          // Kalori bilgisi (deaktif)
                                          /*Row(
                                              children: [
                                                const Icon(
                                                  Icons.local_fire_department,
                                                  size: 16,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${menu['kalori']} kcal',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),*/
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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


/**
 
 
  
 */