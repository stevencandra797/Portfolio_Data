create database techcorp;
use techcorp;

TRUNCATE TABLE Customers;
DELETE FROM Customers;
DELETE FROM Customers WHERE customer_id > 0;

CREATE TABLE Products
(
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  price DECIMAL(10,2),
  stock_quality INT,
  discount DECIMAL(5,2) DEFAULT 0
);

select * from Products;

create table Customers
(
	customer_id int auto_increment primary key,
	first_name varchar(50) not null ,
	last_name varchar(50) not null ,
    email varchar(50) unique,
    phone varchar(20),
    address varchar(200)
);
select * from Customers;

create table Orders
(
order_id int auto_increment primary key,
customer_id int,
order_date date,
total_amount decimal(10,2),
foreign key (customer_id) REFERENCES Customers(customer_id)
);
select * from Orders;

CREATE TABLE Orderdetails
(
  order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
select * from Orderdetails;

create table Employees
(
employee_id int auto_increment primary key,
first_name varchar(20),
last_name varchar(20),
email varchar(20),
phone varchar(20),
hire_date date,
department varchar(50)
);

create table SupportTickets
(
ticket_id int auto_increment primary key,
customer_id int,
employee_id int,
issue text,
status varchar(20),
create_at datetime,
resolved_at datetime,
foreign key (customer_id) references Customers(customer_id),
foreign key (employee_id) references Employees(employee_id)
);

select * from SupportTickets;
select * from Products;
select * from SupportTickets;
-- menambal kolom yang tadinya kurang
-- (
alter table Products 
add column discount decimal(5,2) 
DEFAULT 0;
-- )

ALTER TABLE Products
MODIFY category VARCHAR(50);



-- tambahan insert

-- ✅ Insert ke tabel Products
INSERT INTO Products (product_name, category, price, stock_quality, discount)
VALUES
('Laptop Pro 15', 'Laptop', 1500.00, 100, 0),
('Smartphone X', 'Smartphone', 800.00, 200, 0),
('Wireless Mouse', 'Accessories', 25.00, 500, 0),
('USB-C Charger', 'Accessories', 20.00, 300, 0),
('Gaming Laptop', 'Laptop', 2000.00, 50, 10),
('Budget Smartphone', 'Smartphone', 300.00, 150, 5),
('Noise Cancelling Headphones', 'Accessories', 150.00, 120, 15),
('Wireless Earphones', 'Accessories', 100.00, 100, 10);


-- ✅ Insert ke tabel Customers
INSERT INTO Customers (first_name, last_name, email, phone, address)
VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', '123 Elm Street'),
('Jane', 'Smith', 'jane.smith@example.com', '1234567891', '456 Oak Street'),
('Emily', 'Johnson', 'emily.johnson@example.com', '1234567892', '789 Pine Street'),
('Michael', 'Brown', 'michael.brown@example.com', '1234567893', '101 Maple Street'),
('Sarah', 'Davis', 'sarah.davis@example.com', '1234567894', '202 Birch Street');
SELECT * FROM Customers;
ALTER TABLE Customers
    MODIFY COLUMN email varchar(150);

-- ✅ Insert ke tabel Orders
INSERT INTO Orders (customer_id, order_date, total_amount)
VALUES
(1, '2023-07-01', 1525.00),
(2, '2023-07-02', 820.00),
(3, '2023-07-03', 25.00),
(1, '2023-07-04', 2010.00),
(4, '2023-07-05', 300.00),
(2, '2023-07-06', 315.00),
(5, '2023-07-07', 165.00);


-- ✅ Insert ke tabel Orderdetails
INSERT INTO Orderdetails (order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 1500.00),
(1, 3, 1, 25.00),
(2, 2, 1, 800.00),
(2, 4, 1, 20.00),
(3, 3, 1, 25.00),
(4, 5, 1, 2000.00),
(4, 6, 1, 300.00),
(5, 6, 1, 300.00),
(6, 6, 1, 300.00),
(7, 7, 1, 150.00),
(7, 4, 1, 20.00);


-- ✅ Insert ke tabel Employees
INSERT INTO Employees (first_name, last_name, email, phone, hire_date, department)
VALUES
('Alice', 'Williams', 'alice.williams@example.com', '123-456-7895', '2022-01-15', 'Support'),
('Bob', 'Miller', 'bob.miller@example.com', '123-456-7896', '2022-02-20', 'Sales'),
('Charlie', 'Wilson', 'charlie.wilson@example.com', '123-456-7897', '2022-03-25', 'Development'),
('David', 'Moore', 'david.moore@example.com', '123-456-7898', '2022-04-30', 'Support'),
('Eve', 'Taylor', 'eve.taylor@example.com', '123-456-7899', '2022-05-10', 'Sales');

ALTER TABLE Employees
    MODIFY COLUMN email varchar(150);
-- ✅ Insert ke tabel SupportTickets (perbaikan: kolom = created_at, bukan create_at)
INSERT INTO SupportTickets (customer_id, employee_id, issue, status_, create_at, resolved_at)
VALUES
(1, 1, 'Cannot connect to Wi-Fi', 'resolved', '2023-07-01 10:00:00', '2023-07-01 11:00:00'),
(2, 1, 'Screen flickering', 'resolved', '2023-07-02 12:00:00', '2023-07-02 13:00:00'),
(3, 1, 'Battery drains quickly', 'open', '2023-07-03 14:00:00', NULL),
(4, 2, 'Late delivery', 'resolved', '2023-07-04 15:00:00', '2023-07-04 16:00:00'),
(5, 2, 'Damaged product', 'open', '2023-07-05 17:00:00', NULL),
(1, 3, 'Software issue', 'resolved', '2023-07-06 18:00:00', '2023-07-06 19:00:00'),
(2, 3, 'Bluetooth connectivity issue', 'resolved', '2023-07-07 20:00:00', '2023-07-07 21:00:00'),
(5, 4, 'Account issue', 'open', '2023-07-08 22:00:00', NULL),
(3, 4, 'Payment issue', 'resolved', '2023-07-09 23:00:00', '2023-07-09 23:30:00'),
(4, 5, 'Physical damage', 'open', '2023-07-10 08:00:00', NULL),
(4, 1, 'Laptop blue screen', 'resolved', '2024-01-05 10:00:00', '2024-02-05 12:00:00'),
(5, 1, 'Laptop lagging', 'resolved', '2024-01-06 10:00:00', '2024-01-25 12:00:00'),
(3, 1, 'Some part of laptop broken', 'resolved', '2024-02-05 10:00:00', '2024-03-05 12:00:00');
ALTER TABLE SupportTickets
CHANGE status status_ varchar(20);


select * from Customers;
select * from Employees;
select * from Orderdetails;
select * from Orders;
select * from Products;
select * from SupportTickets;

-- 1. Identifikasi 3 pelanggan teratas berdasarkan total nominal pesanan!
SELECT c.first_name, c.last_name,
       SUM(o.total_amount) AS total_order_amount
FROM Customers AS c
JOIN Orders o 
  ON o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_order_amount DESC
LIMIT 3;

-- 2. Temukan rata-rata nominal pesanan untuk setiap pelanggan!
select 
c.first_name,
c.last_name,
avg(total_amount)
from Customers c 
join Orders o on c.customer_id = o.customer_id
group by c.customer_id
;

-- 3. Temukan semua karyawan yang telah menyelesaikan lebih dari 4 tiket support!
SELECT e.first_name,
       e.last_name,
       COUNT(s.ticket_id) AS resolved_tickets
FROM Employees e
JOIN SupportTickets s ON e.employee_id = s.employee_id
WHERE s.status_ = 'resolved'
GROUP BY e.employee_id
HAVING COUNT(s.ticket_id) > 4
;

-- 4.Temukan semua produk yang belum pernah dipesan!
select Products.product_name from Products 
left join Orderdetails  on Orderdetails.product_id = Products.product_id
where Orderdetails.order_id is null
;

-- 5. Hitung total pendapatan yang dihasilkan dari penjualan produk!
SELECT SUM(quantity * unit_price) AS total_revenue
FROM Orderdetails;

-- 6. Temukan harga rata-rata produk untuk setiap kategori dan temukan kategori dengan 
-- harga rata-rata lebih dari $500!
with cte_avg_price as (
select category, avg(price) rerata from Products group by category
)
select * from cte_avg_price where rerata > 500
;

-- 7. Temukan pelanggan yang telah membuat setidaknya satu pesanan dengan total jumlah lebih dari $1000!
select * from Customers where customer_id in 
(select customer_id from Orders where total_amount > 1000);