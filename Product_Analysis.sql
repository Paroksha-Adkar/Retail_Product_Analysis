-- First we will create Database
Create Database AP;
Use AP;

-- now will create table
Create table Retail
(Product_ID varchar(max), Product_Name varchar(max), Category varchar(max), Stock_Quantity varchar(max), Supplier varchar(max), Discount varchar(max),
Rating varchar(max), Reviews varchar(max), SKU varchar(max), Warehouse varchar(max), Return_Policy varchar(max), Brand varchar(max),
Supplier_Contact varchar(max), Placeholder varchar(max), Price varchar(max))

select * from Retail;
select column_name, data_type from INFORMATION_SCHEMA.COLUMNS

-- Now will apply bulk insert to add all data
Bulk Insert Retail from 'D:\transfer\Work\LB\Projects\LB Project\Data_Retail.csv'
with
(fieldterminator = ',', rowterminator = '\n', firstrow = 2, maxerrors = 20)

-- Now will change the datatypes
Alter table Retail
Alter Column Product_ID Int

Alter table Retail
Alter column Stock_Quantity Int

Alter table Retail
Alter column Discount float

Alter table Retail
Alter column Reviews Int

Alter table Retail
Alter column Placeholder int

Alter table Retail
Alter column Price money

Alter table Retail
Alter column Rating float

Select column_name, data_type from INFORMATION_SCHEMA.COLUMNS
select * from Retail

-- Now we need to check if there is any duplicate values.
With dup as
(select *, dense_rank() over(partition by Product_ID order by Product_ID) as RK from Retail)
select * from dup
where RK > 1

Select Product_ID, count(Product_ID) as CN from Retail
group by Product_ID
Having count(Product_ID) >1

select count(Product_ID), count(distinct Product_ID) from Retail

/* Q.1) Identifies products with prices higher than the average price within their category. */
Select p.Category, p.Product_Name, p.Price from Retail p
JOIN
    (Select Category, Product_Name, avg(price) as AvgPrice from Retail
	 Group by Category, Product_Name) av ON p.Category = av.Category and p.Product_Name = av.Product_Name
where  p.Price > av.AvgPrice
order by p.Category, p.Product_Name, p.Price
/* Here we want to find out those products whose price is greater than the average price of that product within their category. We have used here inner query 
which computes AvgPrice for each combination of Category and Product Name, then outer query joins the result of inner query with original Retail table to get 
required result. */

/* Q. 2) Finding Categories with Highest Average Rating Across Products. */
select * from Retail
select distinct product_name from Retail

with HAR as
(Select Product_Name, Category, Avg(rating) as Avg_rating, DENSE_RANK() Over (partition by Product_Name order by Avg(rating) desc) as RK from Retail
group by Product_Name, Category)
Select Product_Name, Category, Avg_rating from HAR
where RK = 1

/* Here we have used Common Table Expression CTE using WITH clause, we have used Dense rank function to Rank the products and filters to return Categories with 
Highest Average Rating Across Products. */

/* Q. 3) Find the most reviewed product in each warehouse */
Select distinct warehouse from Retail

With MRP as
(Select Warehouse, Product_Name, Sum(Reviews) as Total_Reviews, DENSE_RANK() over (partition by Warehouse order by Sum(Reviews) desc) as RK from Retail
Group by Warehouse, Product_Name)
Select Warehouse, Product_Name, Total_Reviews from MRP
where RK = 1
/* We have used CTE and then Dense rank function to get rank based on total reviews, after that filters the 1st rank to get most reviewed product in each warehouse.*/

/* Q. 4) Find products that have higher-than-average prices within their category, along with their discount and supplier. */
Select p.Category, p.Product_Name, p.Price, p.Discount, p.Supplier from Retail p
JOIN
    (Select Category, Product_Name, avg(price) as AvgPrice from Retail
	 Group by Category, Product_Name) av ON p.Category = av.Category and p.Product_Name = av.Product_Name
where  p.Price > av.AvgPrice
order by p.Category, p.Product_Name, p.Price
/* Again we want to find products which cost more than average cost of those products in their category with discount and supplier. */

/* Q. 5) Query to find the top 2 products with the highest average rating in each category */
With AR as
(Select Category, Product_Name, avg(rating) as AvgRating, DENSE_RANK() Over (Partition by Category Order by avg(rating) desc) as RK from Retail
group by Category, Product_Name)
Select Category, Product_Name, AvgRating from AR
Where RK IN (1,2)
/* Here we have used CTE and Dense rank. In where clause we used IN operator to get 1 and 2 rank as we need top 2 products with the highest average rating in 
each category. We can observed Product C has highest rating in all categories. */

/* Q. 6) Analysis Across All Return Policy Categories(Count, Avgstock, total stock, weighted_avg_rating, etc) */
Select * from Retail
Select Product_ID, Brand, Category, Product_Name, Supplier,  Warehouse, Return_Policy, Stock_Quantity, Discount, Rating, Reviews, Price from Retail
Order By Brand, Category, Product_Name, Supplier,  Warehouse

Select Distinct Return_Policy from Retail

Select Return_Policy, Count(Product_ID) as TotalProducts, Avg(Stock_Quantity) as AvgStock, Sum(Stock_Quantity) as TotalStock, avg(discount) as AvgDiscount,
avg(rating) as AvgRating, avg(reviews) as AvgReviews, avg(Price) as AvgPrice, sum(rating * reviews)/sum(reviews) as weighted_avg_rating
from Retail
Group by Return_Policy
/* In 7days - most products applicable for 7 days return policy, highest discount, more stock, most expensive than others. 
In 30 days - less than 7 days and more than 15 days products applicable for 30 days return policy, moderate discount, moderate stock, moderate cost
In 15 days - less products applicable for 15 days return policy, lowest discount, least stock, cheap than others. */


Select Category, Product_Name, Return_Policy, Count(Product_ID) as TotalProducts, Avg(Stock_Quantity) as AvgStock, Sum(Stock_Quantity) as TotalStock, 
avg(discount) as AvgDiscount, avg(rating) as AvgRating, avg(reviews) as AvgReviews, avg(Price) as AvgPrice, 
sum(rating * reviews)/sum(reviews) as weighted_avg_rating
from Retail
Group by Category, Product_Name, Return_Policy
Order by Category, Product_Name
/* Clothing-Product A-30 days highest total number of products, highest stock, highest rating   
Clothing-Product C- 7 days lowest total number of products, lowest stock, comparitevely high discount given, lowest rating, highest avg price */


Select Brand, Return_Policy, Count(Product_ID) as TotalProducts, Avg(Stock_Quantity) as AvgStock, Sum(Stock_Quantity) as TotalStock, avg(discount) as AvgDiscount,
avg(rating) as AvgRating, avg(reviews) as AvgReviews, avg(Price) as AvgPrice, sum(rating * reviews)/sum(reviews) as weighted_avg_rating
from Retail
Group by Brand, Return_Policy
Order by Brand
/* Brand Y - 15 days policy receives highest avg rating and weighted avg rating
Brand X - 15 days policy receives lowest avg rating and weighted avg rating
In all brand 7 day policy has more products and more stock
In all brand 15 day policy has less products*/

Select Supplier, Return_Policy, Count(Product_ID) as TotalProducts, Avg(Stock_Quantity) as AvgStock, Sum(Stock_Quantity) as TotalStock, avg(discount) 
as AvgDiscount, avg(rating) as AvgRating, avg(reviews) as AvgReviews, avg(Price) as AvgPrice, sum(rating * reviews)/sum(reviews) as weighted_avg_rating
from Retail
Group by Supplier, Return_Policy
Order by Supplier
/* Supplier Z 15 days policy has lowest total product, total stock
Supplier Y 7 days policy has highest total product, total stock*/

Select Warehouse, Return_Policy, Count(Product_ID) as TotalProducts, Avg(Stock_Quantity) as AvgStock, Sum(Stock_Quantity) as TotalStock, avg(discount) 
as AvgDiscount, avg(rating) as AvgRating, avg(reviews) as AvgReviews, avg(Price) as AvgPrice, sum(rating * reviews)/sum(reviews) as weighted_avg_rating
from Retail
Group by Warehouse, Return_Policy
Order by Warehouse
/* Warehouse C 15 days policy has lowest total product
Warehouse B 15 days policy has highest total product */