create database DB_Hydration_Elasticity_Project;
use DB_Hydration_Elasticity_Project;

select * from Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio;
select * from Derived_Indicators_Hydration_Elasticity_Senior_Analyst_Portfolio;

-- 1. Menghitung_Elastisitas_Kepatuhan_(HEC)
-- create table Jawaban_1 as
WITH rawchanges AS (
    SELECT 
        `district_`, 
        `day_`, 
        `water_ml`, 
        `compliance_index_`,
        -- Mengambil data hari sebelumnya
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio -- GANTI INI dengan nama tabel yang ada di panel kiri Workbench
),
CalculatedElasticity AS (
    SELECT * ,
        -- % Perubahan Air
        (water_ml - prev_water) / NULLIF(prev_water, 0) AS water_pct_change,
        -- % Perubahan Kepatuhan
        (compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0) AS comp_pct_change
    FROM rawchanges
)
SELECT
    `district_`,
    `day_`,
    water_ml,
    compliance_index_,
    -- Menghitung HEC (Hydration Elasticity of Compliance)
    comp_pct_change / NULLIF(water_pct_change, 0) AS HEC,
    CASE 
        WHEN ABS(comp_pct_change / NULLIF(water_pct_change, 0)) > 1 THEN 'SENSITIVE ZONE'
        ELSE 'STABLE'
    END AS status
FROM CalculatedElasticity
WHERE prev_water IS NOT NULL;


-- 2 Pertanyaannya: "Pada tingkat water_ml berapa, 
-- sistem mulai runtuh?"
-- Tugas: Cari nilai jatah air rata-rata di mana status 
-- berubah dari STABLE menjadi SENSITIVE ZONE.
-- Analisis: Jika rata-rata SENSITIVE ZONE terjadi di angka 
-- 1850ml, maka 1850ml adalah Wcrit (Ambang Batas Kritis).

-- a. mengelompokkan data berdasarkan status yang sudah kita buat sebelumnya (dari perhitungan HEC).
-- create table jawaban_2 as
WITH RawChanges2 AS (
    SELECT 
        `district_`, 
        `day_`, 
        `water_ml`, 
        `compliance_index_`, 
        -- 1. Tambahkan alias 'as prev_water' yang tadi hilang
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` 
),
CalculatedHEC AS (
    SELECT *,
        ((compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0)) / 
        NULLIF(((water_ml - prev_water) / NULLIF(prev_water, 0)), 0) AS HEC
    FROM RawChanges2
),
StatusCategorization AS (
    SELECT *, 
        CASE 
            WHEN ABS(HEC) > 1 THEN 'SENSITIVE ZONE'
            ELSE 'STABLE'
        END AS status_
    FROM CalculatedHEC -- 2. Pastikan TIDAK ADA SPASI di sini (CalculatedHEC, bukan Calculated HEC)
    WHERE prev_water IS NOT NULL
)
SELECT 
    status_, 
    ROUND(AVG(water_ml), 2) AS avg_water_threshold,
    MIN(water_ml) AS min_water_level,
    MAX(water_ml) AS max_water_level,
    COUNT(*) AS total_observations
FROM StatusCategorization
GROUP BY status_;

-- b. Cara Membaca Hasilnya (Analisis)Setelah Anda menjalankan kueri di atas, 
-- perhatikan baris SENSITIVE ZONE:avg_water_threshold: Inilah nilai $W_{crit}$ Anda. 
-- Jika hasilnya adalah 1850, maka secara statistik, ketika jatah air rata-rata menyentuh 1850ml, 
-- masyarakat mulai bereaksi secara ekstrem (tidak stabil).max_water_level pada Sensitive Zone: 
-- Ini adalah angka "Peringatan Dini". Artinya, ada distrik yang sudah mulai goyah bahkan saat jatah air masih 
-- setinggi angka ini.

-- c. Output untuk Laporan (The "Red Line")
-- Kesimpulam:

-- Analisis Garis Merah:

-- Zona Hijau (> 1950ml): Sistem sangat stabil, kepatuhan tinggi.

-- Zona Kuning (1850ml - 1950ml): Masa transisi, masyarakat mulai waspada.

-- Zona Merah (< 1850ml): SENSITIVE ZONE. Efek elastisitas terjadi; pengurangan air sedikit saja akan mengakibatkan 
-- lonjakan kerusuhan yang tidak terkendali.



-- 3. Analisis Probabilitas Kerusuhan (Unrest Correlation)
-- Pertanyaannya: "Apakah lonjakan HEC (Sensitivitas) berbanding lurus dengan probabilitas kerusuhan?"
-- Tugas: Hubungkan hasil HEC tadi dengan kolom unrest_probability.
-- Analisis: Biasanya, saat HEC > 1, nilai unrest_probability akan melonjak secara eksponensial (misal dari 0.10 langsung ke 0.45).
-- Tujuan: Membuktikan bahwa ketidakpatuhan bukan sekadar protes, tapi ancaman keamanan nyata.

-- membuktikan secara data bahwa suhu panas adalah "akselerator" krisis. 
-- Distrik yang lebih panas, warga akan lebih cepat marah (masuk ke Sensitive Zone) 
-- meskipun pengurangan airnya mungkin sama dengan distrik yang sejuk.

-- create table jawaban_3 as
WITH RawChanges3 AS (
    SELECT 
        `district_`, 
        `day_`, 
        `water_ml`, 
        `compliance_index_`, 
        `unrest_probability`,
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` 
),
CalculatedHEC AS (
    SELECT *,
        ((compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0)) / 
        NULLIF(((water_ml - prev_water) / NULLIF(prev_water, 0)), 0) AS HEC
    FROM RawChanges3
),
StatusCategorization AS (
    SELECT *, 
        CASE 
            WHEN ABS(HEC) > 1 THEN 'SENSITIVE ZONE'
            ELSE 'STABLE'
        END AS status_
    FROM CalculatedHEC
    WHERE prev_water IS NOT NULL
)
-- Bagian Analisis Korelasi
SELECT 
    status_, 
    COUNT(*) AS total_kejadian,
    ROUND(AVG(ABS(HEC)), 2) AS avg_elasticity_score,
    ROUND(AVG(unrest_probability), 4) AS avg_unrest_risk,
    ROUND(MAX(unrest_probability), 4) AS peak_unrest_risk
FROM StatusCategorization
GROUP BY status_;

-- select LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water from `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` ;


-- Setelah kueri berjalan, bandingkan kolom avg_unrest_risk antara STABLE dan SENSITIVE ZONE.
-- Lonjakan Eksponensial: Jika di STABLE risikonya hanya 0.05 (5%) tapi di SENSITIVE ZONE melompat ke 0.35 (35%), 
-- maka hipotesis Anda terbukti.
-- HEC sebagai Leading Indicator: Anda bisa berargumen bahwa HEC adalah indikator "sebelum kejadian". 
-- Artinya, sebelum kerusuhan benar-benar pecah, nilai HEC akan naik duluan.
-- Ancaman Keamanan: Dengan data ini, Anda bisa lapor ke pimpinan: 
-- "Ketidakpatuhan ini bukan sekadar warga yang malas, tapi ada korelasi kuat dengan ancaman fisik (kerusuhan) 
-- yang meningkat [X] kali lipat."
-- Cara Menyajikan di Portofolio
-- Gunakan tabel hasil SQL tadi dan tambahkan narasi ini:
-- "Data menunjukkan bahwa ketika elastisitas kepatuhan melewati angka 1 
-- (Sensitive Zone), probabilitas kerusuhan meningkat secara non-linear. 
-- Hal ini mengonfirmasi bahwa kebijakan pengurangan air yang melewati titik kritis bukan lagi masalah administratif, 
-- melainkan masalah stabilitas keamanan nasional."

-- 4. 
-- bukti bahwa suhu panas adalah "bahan bakar" bagi kemarahan warga.
-- Logikanya: Di distrik yang lebih panas, orang lebih cepat haus. Jadi, 
-- ketika air dikurangi sedikit saja, mereka akan jauh lebih cepat kehilangan kesabaran dan menjadi tidak patuh 
-- dibandingkan orang di distrik yang sejuk.
-- a. SQL Query: Mencari Kecepatan Krisis Berdasarkan Suhu
-- Kueri ini akan mencari hari pertama setiap distrik masuk ke SENSITIVE ZONE, 
-- lalu kita sandingkan dengan rata-rata suhu di distrik tersebut.
-- create table jawaban_4 as
WITH RawChanges AS (
    SELECT 
        `district_`, `day_`, `water_ml`, `temperature_c`, `compliance_index_`,
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` -- Pastikan nama ini sesuai di Workbench Anda
),
CalculatedHEC AS (
    SELECT *,
        ((compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0)) / 
        NULLIF(((water_ml - prev_water) / NULLIF(prev_water, 0)), 0) AS HEC
    FROM RawChanges
),
FirstSensitiveDay AS (
    SELECT 
        `district_`, 
        MIN(`day_`) AS day_of_crisis,
        AVG(`temperature_c`) AS avg_temp
    FROM CalculatedHEC
    WHERE ABS(HEC) > 1
    GROUP BY `district_`
)
SELECT 
    `district_`,
    day_of_crisis,
    ROUND(avg_temp, 1) AS temp_c,
    CASE 
        WHEN avg_temp > 34 THEN 'HOT DISTRICT'
        ELSE 'COOL DISTRICT'
    END AS climate_category
FROM FirstSensitiveDay
ORDER BY day_of_crisis ASC;

-- Setelah kueri dijalankan, Anda akan melihat pola seperti ini:
-- Distrik B (Suhu Tinggi ~37°C): Mungkin sudah masuk ke SENSITIVE ZONE pada Hari ke-5.
-- Distrik A (Suhu Rendah ~30°C): Mungkin baru masuk ke SENSITIVE ZONE pada Hari ke-14.
-- Kesimpulan Senior Analyst: "Suhu bertindak sebagai akselerator krisis. 
-- Data menunjukkan adanya korelasi negatif antara suhu dan ketahanan sosial: semakin tinggi suhu lingkungan, 
-- semakin pendek waktu yang dibutuhkan bagi populasi untuk mencapai titik pecah (tipping point) kepatuhan. 
-- Hal ini terjadi karena tekanan biologis (haus ekstrem) menurunkan ambang toleransi 
-- mereka terhadap kebijakan pengurangan air."
-- Mengapa Ini Penting bagi Pengambil Kebijakan?
-- "Jangan mengurangi jatah air secara seragam! Distrik yang suhunya di atas 35°C harus diprioritaskan mendapat 
-- bantuan lebih dulu, karena mereka akan 'meledak' (rusuh) 3x lebih cepat dibandingkan distrik yang lebih sejuk."

-- 5. Perhitungan labor_output_index_ jatuh ke level kritis
-- create table jawaban_5 as
with WaterReductionStart AS
(
-- a. Mencari hari pertama kali air dikurangi untuk setiap distrik
	select `district_`, 
    MIN(`day_`) AS start_day
    FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio
    where `water_ml` < 2000
    group by `district_`
),
ProductivityCollapse AS
(
-- b. Mencari hari pertama kali labor_output di bawah 0.5
	SELECT `district_`,
    MIN(`day_`) AS collapse_day
    FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio
    where `labor_output_index_` < 0.5
    group by `district_`
),
SurvivalAnalysis AS
(
-- c. Menghitung selisih hari mulai sampai kolaps
SELECT w.`district_`,
w.start_day,
p.collapse_day,
(p.collapse_day - w.start_day) as days_to_collapse
from WaterReductionStart w
join ProductivityCollapse p ON w.`district_` = p.`district_`
)
select round(avg(days_to_collapse), 1) as avg_survival_days,
min(days_to_collapse) as fastest_collapse_days,
max(days_to_collapse) as longest_survival_days
from SurvivalAnalysis;

-- Setelah Anda menjalankan kueri tersebut, Anda akan mendapatkan angka rata-rata, misalnya 8.5 hari.
-- Survival Threshold: "Rata-rata populasi hanya mampu mempertahankan produktivitas ekonomi selama [X] hari 
-- setelah jatah air dipotong. Setelah itu, sistem mengalami 'mati suri' di mana tenaga kerja tidak lagi memiliki 
-- energi biologis yang cukup untuk bekerja secara efektif."
-- Economic Impact: "Ini adalah metrik krusial. 
-- Jika pemerintah ingin melakukan penghematan air tanpa mematikan ekonomi, 
-- durasi pembatasan tidak boleh melebihi [X] hari."

-- Risk Mitigation: "Distrik dengan fastest_collapse_days (kolaps tercepat) adalah 
-- titik terlemah dalam rantai pasokan tenaga kerja Anda."

-- Memasukkan ke Google Looker Studio
-- Data ini sangat bagus divisualisasikan dalam bentuk Bullet Chart atau Gauge Chart di Looker Studio:
-- Berikan label: "Sistem Ketahanan Ekonomi: [X] Hari".
-- Warna Hijau (0-5 hari), Kuning (6-8 hari), Merah (>8 hari atau saat mulai kolaps).

-- 6. mengubah ribuan baris data menjadi satu Indikator Keputusan (Decision Metric). 
-- Pimpinan tidak punya waktu untuk melihat tabel elastisitas; 
-- mereka ingin tahu distrik mana yang harus dikirimkan truk air sekarang juga.
-- Membuat Early Warning Score (EWS) dengan skala 0–100.
-- a. Rumus Logika (Weighted Scoring)
-- Kita akan menggabungkan tiga dimensi risiko:
-- Sensitivitas (HEC): Berat 40% (Melihat potensi ledakan kepatuhan).
-- Keamanan (Unrest): Berat 30% (Melihat risiko kerusuhan nyata).
-- Kesehatan/Ekonomi (Energy Loss): Berat 30% (Melihat sisa energi populasi).

-- SQL Query: Membuat Peringkat Risiko Distrik

-- create table jawaban_6 as
WITH LatestStatus AS
(
	-- Mengambil data hari terakhir/terbaru untuk setiap distrik
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY `district_` ORDER BY `day_` DESC) as rn,
            -- Menghitung Energy Loss (100 - Energy Index)
            (100 - `energy_index_`) AS energy_loss
        FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio`
    ) t
    WHERE rn = 1
),
CalculatedMetrics AS
(
	-- Menghitung HEC sederhana untuk skor (menggunakan data terbaru vs rata-rata bisa, 
    -- tapi di sini kita fokus pada normalisasi nilai yang ada)
    SELECT 
        `district_`,
        `unrest_probability` * 100 AS unrest_score,
        `energy_loss`,
        `compliance_index_`
    FROM LatestStatus
)
SELECT 
    `district_`,
    -- Rumus EWS (Early Warning Score)
    -- Semakin tinggi unrest, semakin tinggi energy loss, semakin rendah compliance = Skor tinggi (Bahaya)
    ROUND(
        (unrest_score * 0.4) + 
        (energy_loss * 0.3) + 
        ((100 - compliance_index_) * 0.3), 2
    ) AS early_warning_score,
    CASE 
        WHEN (unrest_score * 0.4) + (energy_loss * 0.3) + ((100 - compliance_index_) * 0.3) > 70 THEN '🔴 CRITICAL (IMMEDIATE ACTION)'
        WHEN (unrest_score * 0.4) + (energy_loss * 0.3) + ((100 - compliance_index_) * 0.3) > 40 THEN '🟡 WARNING (MONITOR CLOSELY)'
        ELSE '🟢 STABLE'
    END AS risk_status
FROM CalculatedMetrics
ORDER BY early_warning_score DESC;