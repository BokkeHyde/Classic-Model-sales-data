use classicmodels;

select * from customers;
select * from orders;
select * from products;
# 1. Total customers count
select count(*) from customers;


# 2. top 5 Customers and their credit limit
select customerNumber,customerName,creditLimit
from customers
order by creditLimit desc
limit 5;

# 3. Customer count based on credit categories
with t1 as
	(select customerNumber,customerName,creditLimit,
	case when creditLimit < 25000 then "Low" 
		 when creditLimit >= 25000 and creditLimit < 60000 then "Medium"
		 when creditLimit >= 60000 then "High" 
		 else "Unknown" 
	end as creditCategory
	from customers)

select creditCategory, count(*) as customercount
from t1
group by creditCategory
order by customercount desc;

# 4. top 5 Customers and their credit limit under each credit category
with t1 as
    (select customerNumber,customerName,creditLimit,
	case when creditLimit < 25000 then "Low" 
		 when creditLimit >= 25000 and creditLimit < 60000 then "Medium"
		 when creditLimit >= 60000 then "High" 
		 else "Unknown" 
	end as creditCategory
	from customers),

t2 as
	(select customerNumber,customerName,creditLimit,creditCategory,
	row_number() over (partition by creditCategory order by creditLimit desc) as rn
	from t1)

select * from t2 where rn <=5;

# 5. Total orders count
select distinct(count(orderNumber)) from orders;

# 6. Orders placed by each customer
select customerName, count(distinct(orderNumber)) as ordercount
from customers c
join orders o 
on o.customerNumber = c.customerNumber
group by customerName
order by count(distinct(orderNumber)) desc;

# 7. Order count for each year
with t1 as
	(select orderNumber,
	 year(orderDate) as orderyear
	 from orders o
	 join customers c
	 on o.customerNumber = c.customerNumber)   

select orderyear,count(*) as ordercount
from t1
group by orderyear;

# 8. Monthly Order count for all three years
with t1 as
	(select orderNumber,
	 monthname(orderDate) as ordermonth
	 from orders)   

select ordermonth,count(*) as ordercount
from t1
group by ordermonth;

# 9. product count by productLine
select productLine, sum(quantityInStock) as stockquantity
from products
group by productLine
order by stockquantity desc;

# 10. Total sales by productLine
with t1 as
	(select *,
	quantityInStock * MSRP as Sales,
	quantityInStock * buyprice as Costprice,
	(quantityInStock * MSRP) - (quantityInStock * buyprice) as Profit
	from products)
    
select productLine, sum(Sales) as Totalsales, sum(Profit) as Totalprofit
from t1
group by productLine
order by Totalsales desc;


# 11. Top 5 sales by productLine with productname
with t1 as
	(select *,
	quantityInStock * MSRP as Sales,
	quantityInStock * buyprice as Costprice,
	(quantityInStock * MSRP) - (quantityInStock * buyprice) as Profit
	from products),
 
t2 as
	(select productLine, productName, Sales,
	row_number() over (partition by productLine order by Sales desc) as rn
	from t1 productLine) 
    
select * from t2
where rn <=5;

select * from payments;
# 12. Quarterly payments for all three years
select quarter(paymentDate) as quarter, sum(amount) as Total_payments
from payments
group by quarter
order by quarter asc;

# 13. Top 10 payments by customername
with t1 as
	(select concat(contactFirstName," ",contactLastName) as Customername, sum(amount) as payment
	from customers c
	join payments p
	on c.customerNumber = p.customerNumber
    group by concat(contactFirstName," ",contactLastName))

select *
from t1
order by payment desc limit 10;

# 14. Top 10 payments by country
select country, sum(amount) as payment
from customers c
join payments p
on c.customerNumber = p.customerNumber
group by country
order by sum(amount) desc
limit 10

