CREATE DATABASE baru_mobil_data;

USE baru_mobil_data;

DROP TABLE IF EXISTS announces;
CREATE TABLE announces (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL,
    UNIQUE KEY unique_title (title)
);

CREATE TABLE news (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    content TEXT,
    date DATETIME,
    image_url VARCHAR(255)
);

CREATE TABLE cafeteria_menu (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE,
    menu_items TEXT,
    price DECIMAL(10,2)
);

DROP TABLE IF EXISTS clubs;
CREATE TABLE clubs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(255),
    website_url VARCHAR(255),
    instagram_url VARCHAR(255),
    twitter_url VARCHAR(255)
);

CREATE TABLE dorms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    location TEXT,
    url VARCHAR(255),
    telNo VARCHAR(20)
);

-- Örnek verileri ekleyelim
INSERT INTO clubs (name, location, logo_url, website_url, instagram_url, twitter_url) VALUES 
('Müzik Kulübü', 'Müzik etkinlikleri düzenleyen ve konserler veren öğrenci topluluğu', 'assets/logos/mug.png', 'https://muzik.bartin.edu.tr', 'https://instagram.com/muzik_klubu', 'https://twitter.com/muzik_klubu'),
('Spor Kulübü', 'Spor etkinlikleri ve turnuvalar düzenleyen kulüp', 'assets/logos/mug.png', 'https://spor.bartin.edu.tr', 'https://instagram.com/spor_klubu', NULL),
('Yazılım Kulübü', 'Yazılım geliştirme ve teknoloji üzerine çalışmalar yapan öğrenci topluluğu', 'assets/logos/mug.png', 'https://yazilim.bartin.edu.tr', 'https://instagram.com/yazilim_klubu', 'https://twitter.com/yazilim_klubu'),
('Tiyatro Kulübü', 'Tiyatro sanatı üzerine çalışmalar yapan ve gösteriler düzenleyen kulüp', 'assets/logos/mug.png', 'https://tiyatro.bartin.edu.tr', 'https://instagram.com/tiyatro_klubu', NULL);

-- Örnek yurt verileri
INSERT INTO dorms (name, location, url, telNo) VALUES 
('KYK Yurdu', 'Bartın Üniversitesi Kampüsü içerisinde yer alan KYK yurdu', 'https://kyk.gov.tr/bartin', '0378 123 4567'),
('Özel Yurt 1', 'Şehir merkezinde konumlu özel yurt', 'https://ozelyurt1.com', '0378 234 5678'),
('Özel Yurt 2', 'Kampüse yakın konumda özel yurt', 'https://ozelyurt2.com', '0378 345 6789'); 


CREATE TABLE `faculties` (
	`id` INT(11) NULL DEFAULT NULL,
	`faculty_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`url` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
-- Örnek yurt verileri
INSERT INTO faculties (faculty_name, url) VALUES 
('Bartın Orman Fakültesi', 'https://orman.bartin.edu.tr'),
('Edebiyat Fakültesi', 'https://edebiyat.bartin.edu.tr'),
('Eğitim Fakültesi', 'https://egitim.bartin.edu.tr'),

CREATE TABLE `vocation_colleges` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`vocation_colleges_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`url` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;

-- Örnek yurt verileri
INSERT INTO vocation_colleges (vocation_colleges_name, url) VALUES 
('Bartın Meslek Yüksekokulu', 'myo.bartin.edu.tr'),
('Bartın Sağlık Hizmetleri Meslek Yüksekokulu', 'shmyo.bartin.edu.tr'),
('Ulus Meslek Yüksekokulu', 'ulusmyo.bartin.edu.tr'),


CREATE TABLE `faculties2` (
	`id` INT(11) NULL DEFAULT NULL,
	`colleges_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`url` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
-- Örnek yurt verileri
INSERT INTO faculties2 (colleges_name, url) VALUES 
('Yabancı Diller Yüksekokulu', 'ydyo.bartin.edu.tr'),

-- Bölümler tablosu
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    faculty_id INT,
    department_name TEXT NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculties(id)
);

-- Örnek veriler
INSERT INTO faculties (faculty_name) VALUES 
    ('Orman Fakültesi'),
    ('Edebiyat Fakültesi'),
    ('Eğitim Fakültesi'),
    ('Fen Fakültesi'),
    ('İktisadi ve İdari Bilimler Fakültesi'),
    ('İslami İlimler Fakültesi'),
    ('Mühendislik Fakültesi'),
    ('Sağlık Bilimleri Fakültesi'),
    ('Spor Bilimleri Fakültesi');


#Orman Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (1, 'Orman Mühendisliği'),
    (1, 'Orman Endüstri Mühendisliği');


#Edebiyat Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (2, 'Bilgi ve Belge Yönetimi'),
    (2, 'Çağdaş Türk Lehçeleri ve Edebiyatları'),
    (2, 'Felsefe'),
    (2, 'Mütercim ve Tercümanlık'),
    (2, 'Psikoloji'),
    (2, 'Sanat Tarihi'),
    (2, 'Sosyoloji'),
    (2, 'Tarih'),
    (2, 'Türk Dili ve Edebiyatı');


#Fen Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (4, 'Bilgisayar Teknolojisi ve Bilişim Sistemleri'),
    (4, 'Biyoteknoloji'),
    (4, 'Kimya'),
    (4, 'Matematik'),
    (4, 'Moleküler Biyoloji ve Genetik');

#İktisadi ve İdari Bilimler Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (5, 'İktisat Bölümü'),
    (5, 'İşletme Bölümü'),
    (5, 'Siyaset Bilimi ve Kamu Yönetimi Bölümü'),
    (5, 'Uluslararası Ticaret ve Lojistik Bölümü'),
    (5, 'Turizm İşletmeciliği Bölümü'),
    (5, 'Yönetim Bilişim Sistemleri Bölümü');

#İslami İlimler Fakültesi
 INSERT INTO departments (faculty_id, department_name) VALUES 
    (6, 'Temel İslam Bilimleri Bölümü'),
    (6, 'Felsefe ve Din Bilimleri Bölümü'),
    (6, 'İslam Tarihi ve Sanatları Bölümü');

#Mühendislik Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (7, 'Bilgisayar Mühendisliği'),
    (7, 'Çevre Mühendisliği'),
    (7, 'Elektrik - Elektronik Mühendisliği'),
    (7, 'Endüstri Mühendisliği'),
    (7, 'İnşaat Mühendisliği'),
    (7, 'Makine Mühendisliği'),
    (7, 'Mekatronik Mühendisliği'),
    (7, 'Metalurji ve Malzeme Mühendisliği'),
    (7, 'Peyzaj Mimarlığı'),
    (7, 'Tekstil Mühendisliği'),
    (7, 'Temel Bilimler Bölümü');

#Sağlık Bilimleri Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (8, 'Hemşirelik Bölümü'),
    (8, 'Ebelik Bölümü'),
    (8, 'Sosyal Hizmet Bölümü'),
    (8, 'Beslenme ve Diyetetik Bölümü'),
    (8, 'Fizyoterapi ve Rehabilitasyon Bölümü'),
    (8, 'Sağlık Yönetimi Bölümü'),
    (8, 'Çocuk Gelişimi Bölümü'),
    (8, 'Odyoloji Bölümü'),
    (8, 'Acil Yardım ve Afet Yönetimi Bölümü'),
    (8, 'Gerontoloji Bölümü');

#Spor Bilimleri Fakültesi
INSERT INTO departments (faculty_id, department_name) VALUES 
    (9, 'Beden Eğitimi ve Spor Bölümü'),
    (9, 'Antrenörlük Eğitimi Bölümü'),
    (9, 'Rekreasyon Bölümü'),
    (9, 'Spor Yöneticiliği Bölümü');

#Kulüplerin yönetimine verilecek hesap bilgileri
#Kulüp yönetimi giriş yaptıktan sonra post paylaşınca o id li kulübün postlarına eklenir.(clubs_posts sql tablosuna)
CREATE TABLE `accounts` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255),
    password VARCHAR(255),
    FOREIGN KEY (club_id) REFERENCES clubs(id)
);


#Kulüplerin paylaştığı postlar
CREATE TABLE `clubs_posts` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    club_id INT,
    post_title VARCHAR(255),
    post_content TEXT,
    post_date DATETIME,
    has_media BOOLEAN DEFAULT FALSE,
    media_count INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (club_id) REFERENCES clubs(id)
);

# Medya tablosunu güncelle - sadece resimler için
CREATE TABLE `post_media` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES clubs_posts(id) ON DELETE CASCADE
);

# Kulüp postları için view oluşturalım (basitleştirilmiş versiyon)
DROP VIEW IF EXISTS club_posts_with_media;
CREATE VIEW club_posts_with_media AS
SELECT 
    cp.id,
    cp.club_id,
    cp.post_title,
    cp.post_content,
    cp.post_date,
    cp.has_media,
    c.name as club_name,
    c.logo_url as club_logo,
    GROUP_CONCAT(pm.image_url) as media_urls
FROM clubs_posts cp
JOIN clubs c ON cp.club_id = c.id
LEFT JOIN post_media pm ON cp.id = pm.post_id
GROUP BY cp.id
ORDER BY cp.post_date DESC;

-- Kulüp yöneticileri için users tablosu
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Şifrelenmiş şifre
    club_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (club_id) REFERENCES clubs(id)
);

-- Örnek kullanıcılar (şifreler: Club123!)
INSERT INTO users (username, password_hash, club_id) VALUES 
('muzik_bsk', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN.B3UNi3R2GGyw9Y6DG.', 1),
('spor_bsk', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN.B3UNi3R2GGyw9Y6DG.', 2),
('yazilim_bsk', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN.B3UNi3R2GGyw9Y6DG.', 3),
('tiyatro_bsk', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN.B3UNi3R2GGyw9Y6DG.', 4);
