import 'package:baru_mobil/firebase_options.dart';
import 'package:baru_mobil/services/notification_service.dart';
import 'package:baru_mobil/widgets/announces_page.dart';
import 'package:baru_mobil/widgets/cafeteria_page.dart';
import 'package:baru_mobil/widgets/clubs_page.dart';
import 'package:baru_mobil/widgets/create_post_page.dart';
import 'package:baru_mobil/widgets/departments_announces.dart';
import 'package:baru_mobil/widgets/dorms_page.dart';
import 'package:baru_mobil/widgets/faculties2_page.dart';
import 'package:baru_mobil/widgets/faculties_announces.dart';
import 'package:baru_mobil/widgets/faculties_page.dart';
import 'package:baru_mobil/widgets/home_page.dart';
import 'package:baru_mobil/widgets/news_page.dart';
import 'package:baru_mobil/widgets/pharmacies_page.dart';
import 'package:baru_mobil/widgets/settings_page.dart';
import 'package:baru_mobil/widgets/university_menu.dart';
import 'package:baru_mobil/widgets/vocation_colleges.dart';
import 'package:baru_mobil/widgets/clubs_menu_page.dart';
import 'package:baru_mobil/widgets/club_profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:toastification/toastification.dart';

//import 'package:baru_mobil/services/notification_service.dart';

class ApiURL {
  static const String url = '';
}

class DecorationTheme {
  static BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.primaryColor.withOpacity(0.2),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration iconsDecoration() {
    return BoxDecoration(
      color: AppTheme.primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration todayMenuDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.primaryColor.withOpacity(0.2),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withOpacity(0.5),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class ToastMessage {
  static void showToast(BuildContext context, String message, int duration) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      primaryColor: AppTheme.primaryColor,
      foregroundColor: AppTheme.textPrimary,
      autoCloseDuration: Duration(seconds: duration),
      alignment: Alignment.bottomCenter,
      showIcon: true,
      icon: const Icon(
        Icons.info,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
    );
  }

  /* static void showToast(BuildContext context, String message, int duration) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: Toast.BOTTOM,
      timeInSecForIosWeb: duration,
      backgroundColor: AppTheme.primaryColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }*/
}

// Ana renkler ve tema sabitleri
class AppTheme {
  static Text appBarTitle(String title, {double? fontSize = 24}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Text defaultEmptyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Ana renkler
  static const Color primaryColor =
      Color.fromARGB(255, 23, 123, 206); // Ana mavi
  static const Color secondaryColor =
      Color.fromARGB(255, 16, 116, 255); // Açık mavi
  static const Color accentColor =
      Color.fromARGB(255, 41, 98, 255); // Vurgu mavisi
  static const Color successColor =
      Color.fromARGB(255, 27, 238, 38); // Başarı renk

  // Metin renkleri
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF6C6C6C);

  // Arka plan renkleri
  static const Color background = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);

  // Diğer renkler
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFDC3545);

  // Gölge
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  // Tema verileri
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 23, 123, 206),
      scaffoldBackgroundColor: background,
      fontFamily: 'Montserrat',

      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // centerTitle: true,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 16, 116, 255)),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),

      // Card teması
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dividerColor),
        ),
      ),

      // Buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Liste teması
      listTileTheme: const ListTileThemeData(
        iconColor: primaryColor,
        textColor: textPrimary,
      ),

      // Drawer teması
      drawerTheme: const DrawerThemeData(
        backgroundColor: background,
      ),

      // Icon teması
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),

      // Metin temaları
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 23, 123, 206),
      scaffoldBackgroundColor: const Color.fromARGB(255, 31, 30, 30),
      fontFamily: 'Montserrat',

      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 200, 200, 200)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),

      // Card teması
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
        color: Colors.grey[900],
      ),

      // Buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Liste teması
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
      ),

      // Drawer teması
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.black,
      ),

      // Icon teması
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),

      // Metin temaları
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await FirebaseMessaging.instance.subscribeToTopic('clubs_notifications');

  await NotificationService.initialize();
  //final fmcToken = await FirebaseMessaging.instance.getToken();
  //print('FMC Token: $fmcToken');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baru Mobil',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', //  Ana sayfa, başlangıç rotası
      routes: {
        '/announce-page': (context) => const AnnouncePage(),
        '/faculties-announces-page': (context) =>
            const FacultiesAnnouncesPage(),
        '/departments-announces-page': (context) =>
            const DepartmentsAnnouncesPage(),
        '/news-page': (context) => const NewsPage(),
        '/cafeteria-page': (context) => const CafeteriaPage(),
        '/clubs-page': (context) => const ClubsPage(),
        '/university-menu': (context) => const UniversityMenuPage(),
        '/settings-page': (context) => const SettingsPage(),
        '/dorms-page': (context) => const DormsPage(),
        '/faculties-page': (context) => const FacultiesPage(),
        '/vocation-colleges-page': (context) => const VocationCollegesPage(),
        '/faculties2-page': (context) => const Faculties2Page(), // YDYO
        '/pharmacies-page': (context) => const PharmaciesPage(), // YDYO
        '/clubs-menu-page': (context) => const ClubsMenuPage(),
        '/create-post-page': (context) => CreatePostPage(),
        '/club-profile': (context) => ClubProfilePage(
              clubId: ModalRoute.of(context)!.settings.arguments as int,
            ),
      },
    );
  }
}
