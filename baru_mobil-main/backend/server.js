const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const admin = require('firebase-admin');
const serviceAccount = require('./config/serviceAccountKey.json');
const AnnouncementService = require('./services/AnnouncementService');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const axios = require('axios');
const FormData = require('form-data');
const bcrypt = require('bcrypt');
const app = express();
const { updateIfChanged } = require("./fetch_meals"); // fetch_meals.js dosyasını içe aktar


app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST'],
  credentials: true
}));

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'baru_mobil_data'
});

// Firebase admin başlatma
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'baru-mobil-110e6' // Firebase projenizin ID'si
});

// Debug log ekleyelim
console.log('Firebase Admin başlatıldı, proje:', admin.app().options.projectId);

// Imgur API yapılandırması
const IMGUR_CLIENT_ID = 'b720c7bb12041bd'; // Imgur'dan alınacak
const upload = multer({ storage: multer.memoryStorage() });

// Resim yükleme endpoint'i
app.post('/api/upload-image', upload.single('image'), async (req, res) => {
  try {
    const formData = new FormData();
    formData.append('image', req.file.buffer.toString('base64'));

    const response = await axios.post('https://api.imgur.com/3/image', formData, {
      headers: {
        Authorization: `Client-ID ${IMGUR_CLIENT_ID}`,
        ...formData.getHeaders()
      }
    });

    res.json({
      success: true,
      url: response.data.data.link
    });
  } catch (err) {
    console.error('Resim yükleme hatası:', err);
    res.status(500).json({ error: 'Resim yükleme hatası' });
  }
});




// Duyurular için endpoint
app.get('/api/announces', (req, res) => {
  connection.query('SELECT * FROM announces ORDER BY date DESC', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    res.json(results);
  });
});

// Haberler için endpoint
app.get('/api/news', (req, res) => {
  connection.query('SELECT * FROM news', (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

// Kulüpler için endpoint
app.get('/api/clubs', (req, res) => {
  console.log('Clubs endpoint called');
  connection.query('SELECT * FROM clubs', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    console.log('Query results:', results);
    res.json(results);
  });
});

// Kulüp ekleme endpoint'i
app.post('/api/clubs', (req, res) => {
  const { name, description, logo_url } = req.body;
  const query = 'INSERT INTO clubs (name, description, logo_url) VALUES (?, ?, ?)';
  
  connection.query(query, [name, description, logo_url], (err, results) => {
    if (err) throw err;
    res.json({ message: 'Kulüp başarıyla eklendi', id: results.insertId });
  });
});

// Yurtlar için endpoint
app.get('/api/dorms', (req, res) => {
  console.log('Dorms endpoint called');
  connection.query('SELECT * FROM dorms', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    console.log('Query results:', results);
    res.json(results);
  });
});

// Yurt ekleme endpoint'i
app.post('/api/dorms', (req, res) => {
  const { name, location, url, telNo } = req.body;
  const query = 'INSERT INTO dorms (name, location, url, telNo) VALUES (?, ?, ?, ?)';
  
  connection.query(query, [name, location, url, telNo], (err, results) => {
    if (err) throw err;
    res.json({ message: 'Yurt başarıyla eklendi', id: results.insertId });
  });
});

// Fakülteler için endpoint
app.get('/api/faculties', (req, res) => {
  console.log('Faculties endpoint called');
  connection.query('SELECT id, faculty_name, url FROM faculties', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    // ID'leri number olarak dönüştür
    const formattedResults = results.map(item => ({
      ...item,
      id: Number(item.id)
    }));
    console.log('Query results:', formattedResults);
    res.json(formattedResults);
  });
});

// Fakülte ekleme endpoint'i
app.post('/api/faculties', (req, res) => {
  const { faculty_name, url } = req.body;
  const query = 'INSERT INTO faculties (faculty_name, url) VALUES (?, ?)';
  
  connection.query(query, [faculty_name, url], (err, results) => {
    if (err) throw err;
    res.json({ message: 'Fakülte başarıyla eklendi', id: results.insertId });
  });
});

// Yurtlar için endpoint
app.get('/api/vocation_colleges', (req, res) => {
  console.log('Dorms endpoint called');
  connection.query('SELECT * FROM vocation_colleges', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    console.log('Query results:', results);
    res.json(results);
  });
});

// Yurt ekleme endpoint'i
app.post('/api/vocation_colleges', (req, res) => {
  const { vocation_colleges_name, url } = req.body;
  const query = 'INSERT INTO vocation_colleges (vocation_colleges_name, url) VALUES (?, ?)';
  
  connection.query(query, [vocation_colleges_name, url], (err, results) => {
    if (err) throw err;
    res.json({ message: 'Yüksekokul başarıyla eklendi', id: results.insertId });
  });
});

// Yurtlar için endpoint
app.get('/api/faculties2', (req, res) => {
  console.log('Dorms endpoint called');
  connection.query('SELECT * FROM faculties2', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    console.log('Query results:', results);
    res.json(results);
  });
});

// Yurt ekleme endpoint'i
app.post('/api/faculties2', (req, res) => {
  const { colleges_name, url } = req.body;
  const query = 'INSERT INTO faculties2 (colleges_name, url) VALUES (?, ?)';
  
  connection.query(query, [colleges_name, url], (err, results) => {
    if (err) throw err;
    res.json({ message: 'Yüksekokul başarıyla eklendi', id: results.insertId });
  });
});

// Fakülteler için endpoint
app.get('/api/departments', (req, res) => {
  console.log('Departments endpoint called');
  connection.query('SELECT * FROM departments', (err, results) => {
    if (err) {
      console.error('Database error:', err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    console.log('Query results:', results);
    res.json(results);
  });
});

// Bölümler için endpoint
app.get('/api/departmentsForFaculty/:faculty_id', (req, res) => {
  console.log('Faculty Departments endpoint called');
  connection.query(
    'SELECT id, department_name FROM departments WHERE faculty_id = ?', 
    [req.params.faculty_id], 
    (err, results) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
      // Sadece ID'yi number'a çevir, department_name'i koru
      const formattedResults = results.map(item => ({
        id: Number(item.id),
        department_name: item.department_name
      }));
      console.log('Query results for departments:', formattedResults);
      res.json(formattedResults);
    }
  );
});

// Fakülte URL'si için endpoint
app.get('/api/faculties/:id', (req, res) => {
  const facultyId = req.params.id;
  connection.query(
    'SELECT url, faculty_name FROM faculties WHERE id = ?',
    [facultyId],
    (err, results) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
        res.json(results[0] || {});
    }
  );
});

// Bölüm URL'si için endpoint
app.get('/api/departments/:id', (req, res) => {
  connection.query(
    'SELECT url, department_name FROM departments WHERE id = ?',
    [req.params.id],
    (err, results) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
      res.json(results[0] || {});
    }
  );
});

// Fakülte adı için endpoint
app.get('/api/faculties/:id', (req, res) => {
  const facultyId = req.params.id;
  connection.query(
    'SELECT faculty_name FROM faculties WHERE id = ?',
    [facultyId],
    (err, results) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
      res.json(results[0] || { faculty_name: 'Bilinmeyen Fakülte' });
    }
  );
});

// clubs_posts kısmındaki son postu çekme
app.get('/api/clubs-last-posts', async (req,res) => {
  try {
    const [results] = await connection.promise().query(
      'SELECT * FROM club_posts_with_media ORDER BY post_date DESC LIMIT 1'
    );
    const formattedResults = results.map(post => {
      // Debug için
      console.log('Post data:', {
        title: post.post_title,
        content: post.post_content,
        mediaUrls: post.media_urls
      });

      return {
        ...post,
        post_date: post.post_date.toISOString(),
        media_files: post.media_urls 
          ? post.media_urls.split(',').map(url => ({
              id: Math.random(), // Geçici ID
              image_url: url
            }))
          : []
      };
    });
    res.json(formattedResults);
  } catch (error) {
    console.error('Son kulüp gönderisi yüklenirken hata:', error);
    res.status(500).json({ error: 'Veritabanı hatası' });
  }
});

// Medya ile birlikte kulüp gönderilerini getiren endpoint
app.get('/api/clubs-posts', async (req, res) => {
  try {
    const [results] = await connection.promise().query(
      'SELECT * FROM club_posts_with_media'
    );

    const formattedResults = results.map(post => {
      // Debug için
      console.log('Post data:', {
        title: post.post_title,
        content: post.post_content,
        mediaUrls: post.media_urls
      });

      return {
        ...post,
        post_date: post.post_date.toISOString(),
        media_files: post.media_urls 
          ? post.media_urls.split(',').map(url => ({
              id: Math.random(), // Geçici ID
              image_url: url
            }))
          : []
      };
    });

    res.json(formattedResults);
  } catch (err) {
    console.error('Kulüp gönderileri yüklenirken hata:', err);
    res.status(500).json({ error: 'Veritabanı hatası' });
  }
});

// Login endpoint'i ekle
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    // Kullanıcıyı bul
    const [users] = await connection.promise().query(
      'SELECT id, username, password_hash, club_id FROM users WHERE username = ?',
      [username]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'Kullanıcı bulunamadı' });
    }

    const user = users[0];

    // Şifreyi kontrol et
    const isValid = await bcrypt.compare(password, user.password_hash);

    if (!isValid) {
      return res.status(401).json({ message: 'Hatalı şifre' });
    }

    // Son giriş zamanını güncelle
    await connection.promise().query(
      'UPDATE users SET last_login = NOW() WHERE id = ?',
      [user.id]
    );

    // Kullanıcı bilgilerini gönder (şifre hariç)
    res.json({
      id: user.id,
      username: user.username,
      club_id: user.club_id
    });

  } catch (error) {
    console.error('Login hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Kulüp bilgilerini getir
app.get('/api/clubs/:id', async (req, res) => {
  try {
    const [clubs] = await connection.promise().query(
      'SELECT id, name, description, logo_url FROM clubs WHERE id = ?',
      [req.params.id]
    );

    if (clubs.length === 0) {
      return res.status(404).json({ message: 'Kulüp bulunamadı' });
    }

    res.json(clubs[0]);
  } catch (error) {
    console.error('Kulüp bilgileri getirme hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Post oluşturma endpoint'ini güncelle
app.post('/api/clubs-posts', async (req, res) => {
  const { club_id, post_title, post_content, image_urls } = req.body;

  try {
    // Post'u ekle
    const [result] = await connection.promise().query(
      'INSERT INTO clubs_posts (club_id, post_title, post_content, post_date, has_media) VALUES (?, ?, ?, NOW(), ?)',
      [club_id, post_title, post_content, image_urls.length > 0]
    );

    const postId = result.insertId;

    // Resimleri ekle
    if (image_urls && image_urls.length > 0) {
      const mediaValues = image_urls.map(url => [postId, url]);
      await connection.promise().query(
        'INSERT INTO post_media (post_id, image_url) VALUES ?',
        [mediaValues]
      );
    }

    // Kulüp bilgilerini al
    const [clubInfo] = await connection.promise().query(
      'SELECT name FROM clubs WHERE id = ?',
      [club_id]
    );

    // FCM topic'e bildirim gönder
    if (clubInfo.length > 0) {
      console.log('Bildirim gönderiliyor...');
      console.log('Kulüp adı:', clubInfo[0].name);
      console.log('Post başlığı:', post_title);

      const message = {
        topic: 'clubs_notifications',
        notification: {
          title: `${clubInfo[0].name} yeni gönderi paylaştı`,
          body: post_title
        },
        android: {
          notification: {
            channelId: 'clubs_channel',
            icon: '@mipmap/ic_launcher',
            color: '#FF5722',
            priority: 'high',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      try {
        const response = await admin.messaging().send(message);
        console.log('Bildirim başarıyla gönderildi:', response);
      } catch (error) {
        console.error('Bildirim gönderme hatası:', error);
      }
    }

    res.json({ 
      message: 'Post başarıyla oluşturuldu',
      post_id: postId 
    });
  } catch (error) {
    console.error('Post oluşturma hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Post Silme endpoint'i
app.delete('/api/clubs-posts/:id', async (req, res) => {
  const postId = req.params.id;
  console.log('Silinmek istenen post ID:', postId); // Debug log

  try {
    // Önce post'un var olup olmadığını kontrol et
    const [post] = await connection.promise().query(
      'SELECT * FROM clubs_posts WHERE id = ?',
      [postId]
    );

    if (post.length === 0) {
      console.log('Post bulunamadı:', postId);
      return res.status(404).json({ message: 'Post bulunamadı' });
    }

    // Önce medya dosyalarını sil
    await connection.promise().query(
      'DELETE FROM post_media WHERE post_id = ?',
      [postId]
    );

    // Sonra post'u sil
    const [result] = await connection.promise().query(
      'DELETE FROM clubs_posts WHERE id = ?',
      [postId]
    );

    console.log('Silme işlemi sonucu:', result); // Debug log

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Post bulunamadı' });
    }

    res.json({ 
      message: 'Post başarıyla silindi',
      deletedId: postId 
    });
  } catch (error) {
    console.error('Post silme hatası:', error);
    res.status(500).json({ 
      message: 'Sunucu hatası',
      error: error.message 
    });
  }
});

// Post düzenleme endpointi
app.put('/api/clubs-posts/:id', async (req, res) => {
  const postId = req.params.id;
  const { post_title, post_content } = req.body; // req.body'den değerleri al

  console.log('Düzenlenen post ID:', postId);
  console.log('Yeni başlık:', post_title);
  console.log('Yeni içerik:', post_content);

  try {
    const [result] = await connection.promise().query(
      'UPDATE clubs_posts SET post_title = ?, post_content = ? WHERE id = ?',
      [post_title, post_content, postId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Post bulunamadı' });
    }

    res.json({ 
      message: 'Post güncellendi',
      post_title: post_title,
      post_content: post_content 
    });
  } catch (error) {
    console.error('Post güncelleme hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});


// Kulüp logosu güncelleme endpoint'i
app.put('/api/clubs/:id/logo', async (req, res) => {
  const { logo_url } = req.body;
  const clubId = req.params.id;

  try {
    const [result] = await connection.promise().query(
      'UPDATE clubs SET logo_url = ? WHERE id = ?',
      [logo_url, clubId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Kulüp bulunamadı' });
    }

    res.json({ 
      message: 'Logo güncellendi',
      logo_url: logo_url 
    });
  } catch (error) {
    console.error('Logo güncelleme hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Test için örnek veriler ekleyelim
const addSamplePosts = async () => {
  try {
    // Önce mevcut kulüpleri al
    const [clubs] = await connection.promise().query('SELECT id FROM clubs LIMIT 3');
    
    const samplePosts = [
      {
        club_id: clubs[0].id,
        post_title: 'Yeni Dönem Kayıtları Başladı',
        post_content: 'Kulübümüzün 2024 dönemi kayıtları başlamıştır. Katılmak isteyen arkadaşlar kulüp odasına uğrayabilirler.',
      },
      {
        club_id: clubs[1].id,
        post_title: 'Workshop Duyurusu',
        post_content: 'Bu hafta Cumartesi günü yazılım geliştirme workshop\'u düzenlenecektir. Tüm üyelerimiz davetlidir.',
      },
      {
        club_id: clubs[2].id,
        post_title: 'Yeni Etkinlik',
        post_content: 'Önümüzdeki ay düzenleyeceğimiz müzik gecesi için hazırlıklar başlamıştır. Katılmak isteyenler iletişime geçebilir.',
      }
    ];

    for (const post of samplePosts) {
      await connection.promise().query(
        'INSERT INTO clubs_posts (club_id, post_title, post_content, post_date) VALUES (?, ?, ?, NOW())',
        [post.club_id, post.post_title, post.post_content]
      );
    }

    console.log('Örnek gönderiler eklendi');
  } catch (err) {
    console.error('Örnek gönderiler eklenirken hata:', err);
  }
};

// Uygulama ilk çalıştığında örnek verileri ekle
//addSamplePosts(); // Test için bu satırı açabilirsiniz

//fetch_meals dosyasını çalıştır
// Sunucu başlatıldığında yemek listesini kontrol et
updateIfChanged();

// Belirli bir aralıkla güncelleme için (örneğin her gün çalışması için)
const cron = require("node-cron");
cron.schedule("*/30 * * * *", () => { // Her 30 dakikada bir çalışacak
    console.log("Yemek listesi kontrol ediliyor...");
    updateIfChanged(); // Güncellemeyi kontrol et
});

// JSON dosyasını API olarak döndür

const JSON_FILE = "foods.json";

app.get("/api/yemekler", (req, res) => {
    fs.readFile(JSON_FILE, "utf-8", (err, data) => {
        if (err) return res.status(500).json({ error: "Dosya okunamadı." });
        res.json(JSON.parse(data));
    });
});
// api/yemekler/today endpointi
app.get("/api/yemekler/today", (req, res) => {
    fs.readFile(JSON_FILE, "utf-8", (err, data) => {
        if (err) return res.status(500).json({ error: "Dosya okunamadı." });
        res.json(JSON.parse(data));
    });
});
app.listen(3000, () => {
  console.log('Server running on port 3000');
}); 
