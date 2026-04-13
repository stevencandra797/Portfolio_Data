create database Projek_3_E_Commerce_Sales_Analysis;
use Projek_3_E_Commerce_Sales_Analysis;

SELECT *
FROM ecommerce_sales
;

-- buat kolom revenue
select order_id, order_date, product, category, quantity, price , quantity * price as Revenue from ecommerce_sales;

-- total revenue
select sum(Revenue) from add_revenue;

-- Top 5 produk
select product, sum(Revenue) as Total from add_revenue group by product order by Total desc limit 5;

-- Revenue per kategori
select category, sum(Revenue) as total from add_revenue group by category;

-- Penjualan per bulan
create table Penjualan_per_bulan as
select MONTH(order_date) as month_, SUM(revenue) AS total
FROM add_revenue
GROUP BY month_
ORDER BY month_;

-- produk terlaris

select product, sum(quantity) as total_terjual from ecommerce_sales group by product order by total_terjual desc limit 1;