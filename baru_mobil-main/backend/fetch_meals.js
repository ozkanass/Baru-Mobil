const axios = require("axios");
const cheerio = require("cheerio");
const fs = require("fs");
const cron = require("node-cron");
const express = require("express");
const app = express();

// JSON dosya yolu
const JSON_FILE = "foods.json";

// JSON verisini oku
function loadExistingData() {
    try {
        return JSON.parse(fs.readFileSync(JSON_FILE, "utf-8"));
    } catch (error) {
        return {}; // Dosya yoksa boş nesne dön
    }
}

// Son X günü al
function getLastDaysMeals(data, lastDays = 5) {
    const dates = Object.keys(data).slice(-lastDays); // Son X günü al
    return dates.map(date => data[date]); // O günlere ait yemekleri liste olarak döndür
}

// Yemek listesini çeken fonksiyon
async function fetchMeals() {
    try {
        const url = "https://form.bartin.edu.tr/rapor/form/yemek-menu.html";
        const response = await axios.get(url);
        const $ = cheerio.load(response.data);

        const scripts = $("script").filter((i, el) => $(el).html().includes("tabloverileriEkle"));
        const jsCode = scripts.html();

        let meals = {};
        let currentDate = "";
        let mealList = [];

        jsCode.split("\n").forEach(line => {
            const dateMatch = line.match(/t='(\d{2}\/\d{2}\/\d{4})';/);
            if (dateMatch) {
                if (currentDate && mealList.length > 0) {
                    meals[currentDate] = mealList;
                }
                currentDate = dateMatch[1];
                mealList = [];
            }

            const mealMatch = line.match(/yemek\d='([^']+)';/);
            if (mealMatch) {
                mealList.push(mealMatch[1]);
            }
        });

        if (currentDate && mealList.length > 0) {
            meals[currentDate] = mealList;
        }

        return meals;
    } catch (error) {
        console.error("Yemekleri çekerken hata oluştu:", error);
        return null;
    }
}

// Güncellemeyi kontrol eden fonksiyon
async function updateIfChanged() {
    console.log("Yemek listesi kontrol ediliyor...");

    const existingData = loadExistingData();
    const newData = await fetchMeals();

    if (!newData) return; // Yeni veriyi çekemediysek çık

    // Eğer elimizde eski veri yoksa doğrudan kaydet
    if (Object.keys(existingData).length === 0) {
        console.log("İlk kez veri ekleniyor...");
        fs.writeFileSync(JSON_FILE, JSON.stringify(newData, null, 4), "utf-8");
        return;
    }

    // Önceki ayın son 5 gününü al
    const last5Old = getLastDaysMeals(existingData);
    // Yeni çekilen verinin son 5 gününü al
    const last5New = getLastDaysMeals(newData);

    if (JSON.stringify(last5Old) === JSON.stringify(last5New)) {
        console.log("Yemek listesi değişmemiş, güncellenmiyor.");
    } else {
        console.log("Yeni yemek listesi geldi, güncelleniyor...");
        fs.writeFileSync(JSON_FILE, JSON.stringify(newData, null, 4), "utf-8");
    }
}
module.exports = {
    updateIfChanged
};
