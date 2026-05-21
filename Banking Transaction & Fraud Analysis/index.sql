create database Banking_Transaction_dan_Fraud_Analysis;
use Banking_Transaction_dan_Fraud_Analysis;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    occupation VARCHAR(50),
    join_date DATE,
    membership_level VARCHAR(20),
    annual_income BIGINT
);

CREATE TABLE branches (
    branch_id VARCHAR(20) PRIMARY KEY,
    branch_name VARCHAR(100),
    region VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    branch_id VARCHAR(20),
    account_type VARCHAR(30),
    balance DECIMAL(18,2),
    account_status VARCHAR(20),
    open_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20),
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount DECIMAL(18,2),
    merchant_category VARCHAR(50),
    payment_method VARCHAR(50),
    transaction_status VARCHAR(20),
    device_type VARCHAR(50),
    fraud_flag VARCHAR(10),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    loan_type VARCHAR(50),
    loan_amount DECIMAL(18,2),
    interest_rate DECIMAL(5,2),
    loan_status VARCHAR(20),
    issue_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
('CUST00001','Budi Santoso','Male',29,'Jakarta','Employee','2023-01-15','Gold',120000000),
('CUST00002','Siti Rahma','Female',34,'Surabaya','Business Owner','2022-11-20','Platinum',350000000),
('CUST00003','Andi Wijaya','Male',24,'Bandung','Freelancer','2024-03-10','Silver',80000000);

INSERT INTO branches VALUES
('BR001','Jakarta Pusat Branch','West Indonesia','Jakarta'),
('BR002','Surabaya Branch','East Indonesia','Surabaya'),
('BR003','Bandung Branch','West Indonesia','Bandung');

INSERT INTO accounts VALUES
('ACC00001','CUST00001','BR001','Savings',15000000,'Active','2023-01-15'),
('ACC00002','CUST00002','BR002','Checking',85000000,'Active','2022-11-20'),
('ACC00003','CUST00003','BR003','Savings',7000000,'Active','2024-03-10');

INSERT INTO transactions VALUES
('TRX00001','ACC00001','2025-01-10','Transfer',2500000,'Shopping','Mobile Banking','Success','Mobile','No'),
('TRX00002','ACC00002','2025-01-11','Payment',7500000,'Electronics','Credit Card','Success','Desktop','No'),
('TRX00003','ACC00003','2025-01-12','Transfer',15000000,'Unknown','E-Wallet','Failed','Mobile','Yes');

INSERT INTO loans VALUES
('LN00001','CUST00001','Personal Loan',50000000,7.5,'Approved','2024-08-01'),
('LN00002','CUST00002','Home Loan',350000000,5.5,'Approved','2023-05-15'),
('LN00003','CUST00003','Vehicle Loan',120000000,8.2,'Default','2024-02-10');


select * from accounts;
select * from branches;
select * from customers;
select * from loans;
select * from transactions;

-- Total_Transaction_Volume
create table Total_Transaction_Volume as
SELECT
SUM(amount) AS total_transaction
FROM transactions;

-- Monthly_Transaction_Trend
create table Monthly_Transaction_Trend as
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY month
ORDER BY month;

-- Top_10_Loyal_Customers
create table Top_10_Loyal_Customers as
SELECT
    c.full_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_spending
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.full_name
ORDER BY total_spending DESC
LIMIT 10;

-- Fraud_by_Region
create table Fraud_by_Region as
SELECT
    b.region,
    COUNT(t.transaction_id) AS fraud_cases
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN branches b
    ON a.branch_id = b.branch_id
WHERE t.fraud_flag = 'Yes'
GROUP BY b.region
ORDER BY fraud_cases DESC;

-- Repeat_Customer_Analysis
create table Repeat_Customer_Analysis as
SELECT
    c.customer_id,
    c.full_name,
    COUNT(t.transaction_id) AS total_transactions
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(t.transaction_id) > 10;

-- Membership_Analysis
create table Membership_Analysis as
SELECT
    membership_level,
    COUNT(customer_id) AS total_customer,
    AVG(annual_income) AS avg_income
FROM customers
GROUP BY membership_level;

-- Customer_Spending_Segmentation
create table Customer_Spending_Segmentation as
SELECT
c.customer_id,
c.full_name,
SUM(t.amount) AS total_spending,
CASE
WHEN SUM(t.amount) > 100000000 THEN 'High Value'
WHEN SUM(t.amount) > 50000000 THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
   ON a.account_id = t.account_id
GROUP BY c.customer_id, c.full_name;

-- Loan_Default_Analysis
create table Loan_Default_Analysis as
SELECT
    loan_type,
    COUNT(*) AS total_default
FROM loans
WHERE loan_status = 'Default'
GROUP BY loan_type
ORDER BY total_default DESC;

-- SCORECARD
-- total_transaction
create table total_transaction_scorecard as
select sum(amount) as total_transaction from transactions;

-- Active Customer
create table Active_Customer as
SELECT COUNT(DISTINCT customer_id) as active_customer
FROM accounts;

-- Fraud Rate
Create Table Fraud_Rate as
SELECT
ROUND(
SUM(CASE WHEN fraud_flag='Yes' THEN 1 ELSE 0 END)*100.0
/ COUNT(*),2
) AS fraud_rate
FROM transactions;

-- loan approval revenue 
-- create table loan_approval_revenue as
SELECT
ROUND(
SUM(CASE WHEN loan_status='Approved' THEN 1 ELSE 0 END)*100.0
/ COUNT(*),2
) AS approval_rate
FROM loans;

-- revenue_by region
create table revenue_by_region as
SELECT
    b.region,
    SUM(t.amount) AS total_revenue
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN branches b
    ON a.branch_id = b.branch_id
GROUP BY b.region
ORDER BY total_revenue DESC;

-- Fraud by Region
create table Fraud_By_Region_1 as
SELECT
    b.region,
    COUNT(*) AS total_fraud
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN branches b
    ON a.branch_id = b.branch_id
WHERE t.fraud_flag = 'Yes'
GROUP BY b.region
ORDER BY total_fraud DESC;

-- Fraud by Device Type
create table Fraud_by_Device_Type as
SELECT
    device_type,
    COUNT(*) AS total_fraud
FROM transactions
WHERE fraud_flag = 'Yes'
GROUP BY device_type;

-- Fraud by Payment Method
create table Fraud_by_Payment_Method as
SELECT
    payment_method,
    COUNT(*) AS total_fraud
FROM transactions
WHERE fraud_flag = 'Yes'
GROUP BY payment_method
ORDER BY total_fraud DESC;

-- Fraud Trend Over Time
create table Fraud_Trend_Over_Time as
SELECT
    DATE_FORMAT(transaction_date,'%Y-%m') AS month,
    COUNT(*) AS total_fraud
FROM transactions
WHERE fraud_flag = 'Yes'
GROUP BY month
ORDER BY month;

-- Suspicious_Transaction_Heatmap
-- create table Suspicious_Transaction_Heatmap as
SELECT
    EXTRACT(HOUR FROM transaction_date) AS transaction_hour,
    COUNT(*) AS suspicious_transactions
FROM transactions
WHERE fraud_flag = 'Yes'
GROUP BY transaction_hour
ORDER BY transaction_hour;

-- Repeat Customer
create table repreat_customer as
SELECT
    customer_type,
    COUNT(*) AS total_customer
FROM (
    SELECT
        c.customer_id,
        CASE
            WHEN COUNT(t.transaction_id) > 10
                THEN 'Repeat Customer'
            ELSE 'Non Repeat Customer'
        END AS customer_type
    FROM customers c
    JOIN accounts a
        ON c.customer_id = a.customer_id
    JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY c.customer_id
) AS customer_summary
GROUP BY customer_type;
-- Membership Analysis
create table Membership_Analysis_1 as
SELECT
    membership_level,
    COUNT(*) AS total_customer,
    AVG(annual_income) AS avg_income
FROM customers
GROUP BY membership_level;

-- Customer Spending Segmentation
create table Customer_Spending_Segmentation_1 as
SELECT
    CASE
        WHEN SUM(t.amount) > 100000000
            THEN 'High Value'
        WHEN SUM(t.amount) > 50000000
            THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(DISTINCT c.customer_id) AS total_customer
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id;

-- Top Loyal Customers
create table Top Loyal Customers
SELECT
    c.full_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_spending
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.full_name
ORDER BY total_spending DESC;

-- Customer Growth Trend
-- create table Customer_Growth_Trend as
SELECT
    DATE_FORMAT(join_date,'%Y-%m') AS month,
    COUNT(customer_id) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;

-- Top Performing Branches
create table Top_Performing_Branches as
SELECT
    b.branch_name,
    SUM(t.amount) AS total_revenue
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN branches b
    ON a.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by Branch
create table Revenue_by_Branch as
SELECT
    b.branch_name,
    SUM(t.amount) AS revenue
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN branches b
    ON a.branch_id = b.branch_id
GROUP BY b.branch_name;

-- Branch Comparison
create table Branch_Comparison as
SELECT
    b.branch_name,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_revenue
FROM branches b
JOIN accounts a
    ON b.branch_id = a.branch_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY b.branch_name;

-- account opening trend
create table account_opening_trend as
SELECT
    DATE_FORMAT(open_date,'%Y-%m') AS month,
    COUNT(account_id) AS new_accounts
FROM accounts
GROUP BY month
ORDER BY month;

-- Balance Distribution by Branch
create table Balance_Distribution_by_Branch as
SELECT
    b.branch_name,
    AVG(a.balance) AS avg_balance
FROM accounts a
JOIN branches b
    ON a.branch_id = b.branch_id
GROUP BY b.branch_name;

create table Balance_Distribution_by_Branch_total as
SELECT
    b.branch_name,
    SUM(a.balance) AS total_balance
FROM accounts a
JOIN branches b
    ON a.branch_id = b.branch_id
GROUP BY b.branch_name;

-- Loan distributor
-- create table Loan_distributor as
SELECT
    loan_type,
    COUNT(*) AS total_loan
FROM loans
GROUP BY loan_type;

-- Loan Status Breakdown
create table Loan_Status_Breakdown as
SELECT
    loan_status,
    COUNT(*) AS total
FROM loans
GROUP BY loan_status;

-- Default Analyst
create table Default_Analyst as
SELECT
    loan_type,
    COUNT(*) AS total_default
FROM loans
WHERE loan_status = 'Default'
GROUP BY loan_type
ORDER BY total_default DESC;

-- Interest rate comparison
create table Interest_rate_comparison as
SELECT
    loan_type,
    AVG(interest_rate) AS avg_interest_rate
FROM loans
GROUP BY loan_type;

-- Loan Amount Trend
create table Loan_Amount_Trend as 
SELECT
    DATE_FORMAT(issue_date,'%Y-%m') AS month,
    SUM(loan_amount) AS total_loan_amount
FROM loans
GROUP BY month
ORDER BY month;