create database RetensiFrauddanProfitECommerce;

CREATE TABLE orders (
    order_id VARCHAR(20),
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    category VARCHAR(50),
    region VARCHAR(50),
    payment_method VARCHAR(50),
    quantity INT,
    price DECIMAL(15,2),
    discount_percent INT,
    shipping_cost DECIMAL(15,2),
    refund_status VARCHAR(10),
    fraud_flag VARCHAR(10),
    delivery_days INT,
    customer_rating INT
);

INSERT INTO orders (
    order_id,
    order_date,
    customer_id,
    product_id,
    category,
    region,
    payment_method,
    quantity,
    price,
    discount_percent,
    shipping_cost,
    refund_status,
    fraud_flag,
    delivery_days,
    customer_rating
)
VALUES
('ORD001','2025-01-01','C001','P001','Electronics','Jakarta','E-Wallet',1,8500000,10,25000,'No','Normal',2,5),

('ORD002','2025-01-01','C002','P004','Fashion','Surabaya','Credit Card',3,350000,20,18000,'No','Normal',4,4),

('ORD003','2025-01-02','C003','P002','Electronics','Bandung','Bank Transfer',1,12500000,5,30000,'Yes','Fraud',9,1),

('ORD004','2025-01-02','C004','P005','Beauty','Jakarta','E-Wallet',2,120000,15,12000,'No','Normal',2,5),

('ORD005','2025-01-03','C005','P006','Home','Medan','COD',1,750000,35,50000,'Yes','Normal',8,2),

('ORD006','2025-01-03','C001','P003','Electronics','Jakarta','E-Wallet',2,6500000,5,25000,'No','Normal',3,5),

('ORD007','2025-01-04','C006','P004','Fashion','Semarang','Credit Card',5,350000,50,25000,'Yes','Fraud',10,1),

('ORD008','2025-01-04','C007','P007','Grocery','Bali','E-Wallet',6,45000,0,10000,'No','Normal',1,5),

('ORD009','2025-01-05','C008','P008','Sports','Jakarta','Bank Transfer',1,1500000,25,22000,'No','Normal',5,3),

('ORD010','2025-01-05','C009','P009','Beauty','Surabaya','E-Wallet',4,90000,10,14000,'No','Normal',2,4);

select * from orders;

CREATE TABLE customers (
    customer_id VARCHAR(20),
    gender VARCHAR(10),
    age INT,
    membership VARCHAR(20),
    join_date DATE,
    city VARCHAR(50),
    monthly_income DECIMAL(15,2)
);

INSERT INTO customers (
    customer_id,
    gender,
    age,
    membership,
    join_date,
    city,
    monthly_income
)
VALUES
('C001','Male',24,'Gold','2023-02-12','Jakarta',12000000),

('C002','Female',29,'Silver','2023-08-15','Surabaya',8500000),

('C003','Male',31,'Bronze','2024-01-20','Bandung',6500000),

('C004','Female',22,'Gold','2023-06-11','Jakarta',14000000),

('C005','Male',35,'Bronze','2024-03-01','Medan',5500000),

('C006','Female',27,'Silver','2023-11-09','Semarang',7600000),

('C007','Male',20,'Gold','2024-02-22','Bali',15000000),

('C008','Female',33,'Silver','2023-05-19','Jakarta',9100000),

('C009','Male',25,'Bronze','2024-04-10','Surabaya',4800000);

select * from customers;

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    cost_price DECIMAL(15,2),
    selling_price DECIMAL(15,2),
    supplier VARCHAR(100)
);
INSERT INTO products (
    product_id,
    product_name,
    category,
    cost_price,
    selling_price,
    supplier
)
VALUES
('P001','Macbook Air M2','Electronics',7800000,8500000,'Techindo'),

('P002','Gaming Laptop','Electronics',11000000,12500000,'GigaTech'),

('P003','iPhone 15','Electronics',5900000,6500000,'AppleAsia'),

('P004','Hoodie Oversize','Fashion',150000,350000,'FashionHub'),

('P005','Skincare Set','Beauty',70000,120000,'GlowFactory'),

('P006','Air Fryer','Home',500000,750000,'HomeLiving'),

('P007','Instant Noodles','Grocery',25000,45000,'FoodMart'),

('P008','Treadmill','Sports',1200000,1500000,'FitnessPro'),

('P009','Face Wash','Beauty',50000,90000,'GlowFactory');

create table a as select * from products;

-- Sales Analysis
-- Total Revenue

select sum(price * quantity) as total_revenue
from orders;

-- total order
create table SalesAnalysistotalorder as
(
select count(order_id) AS total_orders
FROM orders);

-- Average Order Value (AOV)
create table AOV as (
select round(sum(price * quantity) / count(order_id),2) as average_order_value from orders);

-- revenue per region
Create table revenueperregion as (
SELECT
region,
SUM(price * quantity) AS revenue
FROM orders
GROUP BY region
ORDER BY revenue DESC);

-- Revenue Per Category
create table RevenuePerCategory as (
select category,
SUM(price * quantity) AS revenue
FROM orders
GROUP BY category
ORDER BY revenue DESC);

-- Monthly Sales Trend
create table MonthlySalesTrend as (
SELECT
date_format(order_date, '%Y-%m') AS month,
SUM(price * quantity) as monthly_revenue
from orders
group by month
order by month);

-- 2. Profit Analysis
-- Rumus:
-- profit = (price - cost_price) * quantity
-- Cari:
-- Produk Paling Profitable
create table ProdukPalingProfitable as (
select p.product_name, SUM((o.price - p.cost_price) * o.quantity) as total_profit
from orders o 
join products p
on o.product_id = p.product_id
group by p.product_name
order by total_profit desc);

-- region dengan profit tertinggi
create table regiondenganprofittertinggi as (
SELECT
o.region,
SUM((o.price - p.cost_price) * o.quantity) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY o.region
ORDER BY total_profit DESC);

-- Pengaruh Diskon terhadap Profit
-- apakah diskon besar menurunkan profit
create table apakahdiskonbesarmenurunkanprofit as (
select discount_percent, sum((o.price - p.cost_price) * o.quantity) as total_profit,
count(order_id) as total_orders
from orders o
join products p
on o.product_id = p.product_id
group by discount_percent
order by discount_percent);

-- low high medium
create table lowhighmedium as (
SELECT
CASE
    WHEN discount_percent BETWEEN 0 AND 10 THEN 'Low Discount'
    WHEN discount_percent BETWEEN 11 AND 30 THEN 'Medium Discount'
    ELSE 'High Discount'
END AS discount_category,

SUM((o.price - p.cost_price) * o.quantity) AS total_profit

FROM orders o
JOIN products p
ON o.product_id = p.product_id

GROUP BY discount_category
ORDER BY total_profit DESC);

-- Produk Rugi Karena Diskon Terlalu Besar
create table ProdukRugiKarenaDiskonTerlaluBesar as( 
SELECT
p.product_name,
o.discount_percent,

SUM(
(
o.price - (o.price * o.discount_percent / 100)
- p.cost_price
) * o.quantity
) AS profit_after_discount

FROM orders o
JOIN products p
ON o.product_id = p.product_id

GROUP BY p.product_name, o.discount_percent

ORDER BY profit_after_discount ASC);

-- Fraud Analysis
-- 1. Persentase Fraud
create table PersentaseFraud as(
select count(case when fraud_flag = 'Fraud' THEN 1 END) AS fraud_orders,
count(*) as total_orders,
round(count(case when fraud_flag = 'Fraud' THEN 1 END) * 100.0 / COUNT(*),2) AS fraud_percentage
from orders);

-- 2. Region Dengan Fraud Tertinggi

SELECT
region,

COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) AS fraud_cases,

COUNT(*) AS total_orders,

ROUND(
COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) * 100.0
/ COUNT(*),2
) AS fraud_rate

FROM orders

GROUP BY region
ORDER BY fraud_rate DESC;

-- 3. Payment Method Paling Berisiko
create table PaymentMethodPalingBerisiko as (
select payment_method, count(case when fraud_flag = 'Fraud' then 1 end ) 
as fraud_cases, count(*) as total_orders, ROUND(COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) * 100.0
/ COUNT(*),2) as fraud_rate

from orders
GROUP BY payment_method
ORDER BY fraud_rate DESC);

-- 4. Hubungan Delivery Lama Dengan Fraud

SELECT
delivery_days,

COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) AS fraud_cases,

COUNT(*) AS total_orders,

ROUND(
COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) * 100.0
/ COUNT(*),2
) AS fraud_rate

FROM orders

GROUP BY delivery_days
ORDER BY delivery_days;


-- Refund Analyst
create table RefundAnalyst as (
select discount_percent, delivery_days, 
customer_rating,
COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) AS total_refund

FROM orders

GROUP BY
discount_percent,
delivery_days,
customer_rating

ORDER BY total_refund DESC);

-- Apakah Rating Rendah Menyebabkan Refund?
create table ApakahRatingRendahMenyebabkanRefund
select customer_rating, COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) AS refund_cases,

COUNT(*) AS total_orders,

ROUND(
COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) * 100.0
/ COUNT(*),2
) AS refund_rate

FROM orders

GROUP BY customer_rating
ORDER BY customer_rating;

-- Kategori Dengan Refund Tertinggi
create table KategoriDenganRefundTertinggi as (
select category, count(case when refund_status = 'Yes' THEN 1 END) AS refund_cases,
count(*) as total_orders,
round(COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) * 100.0
/ COUNT(*),2
) AS refund_rate

from orders

group by category
order by refund_rate desc);

-- Pengaruh Delivery Days Terhadap Refund
create table PengaruhDeliveryDaysTerhadapRefund as(
select delivery_days, 
count(case when refund_status = 'Yes' THEN 1 END) AS refund_cases,
count(*) as total_orders,

round(COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) * 100.0 / COUNT(*),2) as refund_rate
from orders
GROUP BY delivery_days
ORDER BY delivery_days);

-- pengelompokan delivery menjadi kategori
create table pengelompokandeliverymenjadikategori as (
SELECT

CASE
    WHEN delivery_days <= 3 THEN 'Fast Delivery'
    WHEN delivery_days <= 7 THEN 'Medium Delivery'
    ELSE 'Slow Delivery'
END AS delivery_category,

COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) AS refund_cases,

COUNT(*) AS total_orders,

ROUND(
COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) * 100.0
/ COUNT(*),2
) AS refund_rate

FROM orders

GROUP BY delivery_category
ORDER BY refund_rate DESC);

-- Repeat Customer Rate
create table RepeatCustomerRate as (
SELECT

COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_customers,

COUNT(*) AS total_customers,

ROUND(
COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0
/ COUNT(*),2
) AS repeat_customer_rate

FROM
(
    SELECT
    customer_id,
    COUNT(order_id) AS total_orders

    FROM orders

    GROUP BY customer_id
) customer_orders);

-- Customer Paling Loyal
create table CustomerPalingLoyal as (
select customer_id, count(order_id) as total_orders, sum(price * quantity) as total_spending
from orders group by customer_id order by total_orders desc, total_spending desc);

-- Membership Paling Profitable berdasarkan revenue
create table MembershipPalingProfitableberdasarkanrevenue as (
select c.membership, SUM(o.price * o.quantity) AS total_revenue,
COUNT(o.order_id) AS total_orders
from customers c

join orders o on c.customer_id = o.customer_id
group by c.membership
order by total_revenue desc);

-- Membership Paling Profitable berdasarkan profit
create table MembershipPalingProfitableberdasarkanprofit as (
SELECT
c.membership,

SUM(
(o.price - p.cost_price) * o.quantity
) AS total_profit

FROM customers c

JOIN orders o
ON c.customer_id = o.customer_id

JOIN products p
ON o.product_id = p.product_id

GROUP BY c.membership

ORDER BY total_profit DESC);


-- Customer Lifetime Value (CLV) Sederhana
create table CLV as (
SELECT
customer_id,

COUNT(order_id) AS frequency,

ROUND(AVG(price * quantity),2) AS avg_order_value,

ROUND(
AVG(price * quantity) * COUNT(order_id),2
) AS estimated_clv

FROM orders

GROUP BY customer_id

ORDER BY estimated_clv DESC);

-- profit total
select * from orders;
select * from products;

create table hitungprofit as
SELECT
o.*,
p.product_name,
p.cost_price,

((o.price - p.cost_price) * o.quantity) AS profit

FROM orders o
JOIN products p
ON o.product_id = p.product_id;

CREATE TABLE TotalRefundRate AS
SELECT

COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) AS refund_orders,

COUNT(*) AS total_orders,

ROUND(
COUNT(CASE WHEN refund_status = 'Yes' THEN 1 END) * 100.0
/ COUNT(*),2
) AS refund_rate

FROM orders;


CREATE TABLE DiscountVsRevenue AS
SELECT
discount_percent,
SUM(price * quantity) AS total_revenue
FROM orders
GROUP BY discount_percent
ORDER BY discount_percent;

create table Fraudbyregion as
SELECT
region,

COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) AS fraud_cases,

COUNT(*) AS total_orders,

ROUND(
COUNT(CASE WHEN fraud_flag = 'Fraud' THEN 1 END) * 100.0
/ COUNT(*),2
) AS fraud_rate

FROM orders

GROUP BY region
ORDER BY fraud_rate DESC;

CREATE TABLE CustomerSpendingSegmentation AS

SELECT

customer_id,

SUM(price * quantity) AS total_spending,

CASE
    WHEN SUM(price * quantity) >= 10000000 THEN 'High Spender'
    WHEN SUM(price * quantity) >= 3000000 THEN 'Medium Spender'
    ELSE 'Low Spender'
END AS spending_segment

FROM orders

GROUP BY customer_id;
