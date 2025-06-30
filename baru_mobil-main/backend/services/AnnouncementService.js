const axios = require('axios');
const cheerio = require('cheerio');
const { sleep } = require('../utils/helpers');

class AnnouncementService {
  constructor(db) {
    this.db = db;
  }

  // Yeni duyuruları kontrol et
  async checkNewAnnouncements(facultyId = 0) {
    try {
      const faculties = await this.getFaculties(facultyId);
      
      for (const faculty of faculties) {
        try {
          const announcements = await this.fetchFacultyAnnouncements(faculty);
          if (!announcements) continue;

          for (const announcement of announcements.slice(0, 5)) {
            await this.processAnnouncement(faculty, announcement);
          }
        } catch (error) {
          console.error(`${faculty.faculty_name} duyuru kontrolü başarısız:`, error.message);
        }
      }
    } catch (error) {
      console.error('Duyuru kontrolü sırasında hata:', error);
    }
  }

  // Fakülteleri getir
  async getFaculties(facultyId) {
    const query = facultyId === 0 
      ? 'SELECT id, url, faculty_name FROM faculties WHERE id != 0 AND url IS NOT NULL'
      : 'SELECT id, url, faculty_name FROM faculties WHERE id = ?';
    
    const [faculties] = await this.db.promise().query(query, facultyId === 0 ? [] : [facultyId]);
    return faculties;
  }

  // Fakülte sitesinden duyuruları çek
  async fetchFacultyAnnouncements(faculty) {
    console.log(`${faculty.faculty_name} duyuruları kontrol ediliyor...`);
    
    const response = await this.makeRequest(faculty.url);
    if (!response) return null;

    const $ = cheerio.load(response.data);
    const announcements = $('.duyuru');
    
    console.log(`${faculty.faculty_name} için ${announcements.length} duyuru bulundu`);
    return announcements;
  }

  // HTTP isteği at (retry mekanizmalı)
  async makeRequest(url, attempt = 1, maxAttempts = 3) {
    try {
      const response = await axios.get(url, {
        timeout: 5000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        maxRedirects: 5
      });
      return response;
    } catch (error) {
      if (attempt < maxAttempts) {
        await sleep(1000 * attempt);
        return this.makeRequest(url, attempt + 1, maxAttempts);
      }
      throw error;
    }
  }

  // Duyuruyu işle ve gerekirse bildirim gönder
  async processAnnouncement(faculty, announcementElement) {
    const $ = cheerio.load(announcementElement);
    
    const title = $('.duyuru-icerik').text().trim();
    const date = $('.duyuru-tarih').text().trim();
    const link = $('.duyuru a').attr('href') || faculty.url;

    // Benzersiz ID oluştur
    const announcement_id = Buffer.from(`${faculty.id}_${title}_${date}`).toString('base64');

    // Duyuru daha önce kaydedilmiş mi kontrol et
    const [existing] = await this.db.promise().query(
      'SELECT id FROM faculty_announcements WHERE announcement_id = ?',
      [announcement_id]
    );

    if (existing.length === 0) {
      await this.saveAndNotify(faculty, { title, date, link, announcement_id });
    }
  }

  // Duyuruyu kaydet
  async saveAndNotify(faculty, announcement) {
    await this.db.promise().query(
      'INSERT INTO faculty_announcements (faculty_id, announcement_id, title, date, url) VALUES (?, ?, ?, NOW(), ?)',
      [faculty.id, announcement.announcement_id, announcement.title, announcement.link]
    );

    console.log(`Yeni duyuru kaydedildi: ${faculty.faculty_name} - ${announcement.title}`);
  }


}

module.exports = AnnouncementService; 