import requests
from bs4 import BeautifulSoup
import re
import json
# Sayfanın URL'si
url = 'https://form.bartin.edu.tr/rapor/form/yemek-menu.html'

# Sayfayı çek
response = requests.get(url)
response.encoding = 'utf-8'  # Türkçe karakterler için

# İçeriği parse et
soup = BeautifulSoup(response.text, 'html.parser')

# JavaScript kodunu bul
scripts = soup.find_all('script')
js_code = None
for script in scripts:
    if 'tabloverileriEkle' in script.text:
        js_code = script.text
        break

if js_code:
    # Tarihleri ve yemekleri eşleştirerek doğru liste oluştur
    dates = re.findall(r"t='(\d{2}/\d{2}/\d{4})';", js_code)
    meals = re.findall(r"yemek\d='([^']+)';", js_code)

    # Tarihlere göre yemek listesi oluştur
    meal_dict = {}
    current_date = None
    meal_list = []

    for line in js_code.split("\n"):
        # Tarihi tespit et
        date_match = re.search(r"t='(\d{2}/\d{2}/\d{4})';", line)
        if date_match:
            # Önceki tarihi kaydet
            if current_date and meal_list:
                meal_dict[current_date] = meal_list
            # Yeni tarihi başlat
            current_date = date_match.group(1)
            meal_list = []  # Yeni tarih için listeyi sıfırla

        # Yemekleri tespit et
        meal_match = re.search(r"yemek\d='([^']+)';", line)
        if meal_match:
            meal_list.append(meal_match.group(1))

    # Son günün yemeklerini de ekle
    if current_date and meal_list:
        meal_dict[current_date] = meal_list

    # JSON dosyasına yazdır
    with open("foods.json", "w", encoding="utf-8") as json_file:
        json.dump(meal_dict, json_file, ensure_ascii=False, indent=4)

    print("Yemek listesi foods.json dosyasına kaydedildi!")

    # Sonuçları yazdır
    #for date, meals in meal_dict.items():
    #s    print(f"Tarih: {date}, Yemekler: {meals}")

else:
    print("JavaScript kodu bulunamadı.")
