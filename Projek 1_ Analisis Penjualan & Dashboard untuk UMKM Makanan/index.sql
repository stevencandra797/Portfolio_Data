create database katering_penjualan;
use katering_penjualan;
select * from Penjualan; # OrderID, Tanggal date, Nama Produk name product, Jumlah Quatitiy, Harga price, Harga Unit unit price, Sumber Order Order Source, Nama Pelanggan Customer Name (Customer), Nomor WA Phone Whattsapp Call(Customer), Keterangan Notes
select * from Customer; # # Nama Pelanggan Customer Name (Penjualan), Nomor WA Phone Whattsapp (Penjualan), Kota city



SET SQL_SAFE_UPDATES = 1;
-- Table with dirty data / messy data / unclean data
-- first change Tanggal = Date change to type table date
UPDATE Penjualan
SET Nama_Produk = 'Soup Sayur'
WHERE Nama_Produk = 'SoupSayur';

ALTER TABLE Penjualan
MODIFY Tanggal DATE;

SELECT * FROM Penjualan WHERE Tanggal IS NULL;
DELETE FROM Penjualan
WHERE Tanggal IS NULL;

-- Delete Keterangan Notes
alter table Penjualan drop column Keterangan;

-- 1. Best selling products every month v
select distinct Nama_Produk, sum(Jumlah) as Jumlah from Penjualan group by Nama_Produk order by Nama_Produk asc;
-- (Limit 1)
select distinct Nama_Produk, sum(Jumlah) from Penjualan group by Nama_Produk order by Nama_Produk asc limit 1;

# 2. Daily/weekly sales trends. v
with Namaproduktanggaljumlah as (
select Nama_Produk, Tanggal ,Jumlah  from Penjualan
)
select * from Namaproduktanggaljumlah 
order by Tanggal asc
;

-- 3. Source much ordered (Instagram/WhatsApp). v
select Sumber_Order, count(distinct OrderID) AS Jumlah_Orang FROM Penjualan
GROUP BY Sumber_Order;

-- 4. The largest number of city customers v
select Kota, count(distinct Nama_Pelanggan) as Jumlah_Orang from Customer group by Kota order by Jumlah_Orang desc
;

# 5. Daily/weekly revenue trends.
with Namaprodukrevenuetanggaljumlah as (
select Nama_Produk,  (Jumlah * Harga_Unit) AS Revenue ,Tanggal from Penjualan
)
select * from Namaprodukrevenuetanggaljumlah 
order by Tanggal asc
;

-- 6. count city for order v
-- Most All Product
select Customer.Kota, count(Customer.Kota) as Jumlah_Kota from Customer left join Penjualan on Customer.Nama_Pelanggan = Penjualan.Nama_Pelanggan group by Customer.Kota order by Jumlah_Kota desc;
-- Least all Product
select Customer.Kota, count(Customer.Kota) as Jumlah_Kota from Customer left join Penjualan on Customer.Nama_Pelanggan = Penjualan.Nama_Pelanggan group by Customer.Kota order by Jumlah_Kota asc;

-- 7. Revenue per Product v
WITH tabel_revenue AS (
  SELECT 
    Nama_Produk, 
    Jumlah, 
    Harga_Unit, 
    (Jumlah * Harga_Unit) AS Revenue 
  FROM Penjualan
)
SELECT 
  Nama_Produk,
  SUM(Jumlah) AS Total_Jumlah,
  SUM(Revenue) AS Total_Revenue
FROM tabel_revenue
GROUP BY Nama_Produk;

-- 8 total revenue v
SELECT 
  SUM(Jumlah * Harga) AS Total_Revenue
FROM Penjualan;

-- 9. This Product Selling v
select distinct Nama_Produk from Penjualan; 

-- 10 averange Revenue Product v

SELECT 
  SUM(Jumlah * Harga) / sum(Jumlah) AS Total_Revenue
FROM Penjualan;


