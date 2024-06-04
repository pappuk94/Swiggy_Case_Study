use swiggy;
show tables;

-- Q.1 Find customers who have never ordered ?
select name from users where user_id not in (select user_id from orders); 

-- Q.2 Find average price of food/dish ?
select f_name, avg(price) "Average_Price" 
from menu m join food f on m.f_id = f.f_id 
group by f.f_id; 

-- Q.3 Find top restaurant in term of number of orders for a given month ?
-- Let say given month is May
select r_name as "Restaurant", count(*) as "Total-Orders"
from orders o join restaurants r on o.r_id = r.r_id
where monthname(date)="May" 
group by o.r_id order by count(*) desc limit 1;

-- Q.4 Find top restaurant in term of number of orders for each month ?
select Month, Restaurant_Name from
(select monthname(o.date) Month, r.r_name as "Restaurant_Name", count(*) "No_of_Orders",
first_value(count(*)) over(partition by monthname(o.date) order by count(*) desc) max_orders
from orders o join restaurants r on o.r_id = r.r_id
group by month(o.date), o.r_id order by month(o.date)) as t
where t.no_of_orders=t.max_orders; 


-- Q.5 Find restaurants with monthly sale greater than x ruppees ?
-- Let say given month is June
select * from 
(select r.r_name as "Restaurant", sum(amount) as "Revenue" 
from orders o join restaurants r on o.r_id = r.r_id
where monthname(date) = "June"
group by o.r_id) t 
where t.Revenue > 500;

-- Q.6 Show all orders with order details for a particular customer in a particular date range.
-- Let say given customer is "Ankit" and given date range is 10th June,2022 and 10th July,2022
select o.order_id as "Order-ID", r.r_name as "Restaurant", f.f_name as "Food"
from orders o join restaurants r on o.r_id=r.r_id
join order_details od on o.order_id=od.order_id
join food f on od.f_id=f.f_id
where o.user_id = (select user_id from users where name = "Ankit")
and o.date between "2022-06-10" and "2022-07-10" 
order by r.r_name;

-- Q.7 Find restaurant with maximum repeated customers or loyal customers ?
select r.r_name as "Restaurant", count(*) as "Loyal_Customers" 
from (
	select r_id, user_id, count(*) as "visits"
	from orders 
	group by r_id, user_id having visits>1 
	order by r_id
) t left join restaurants r on t.r_id = r.r_id
group by t.r_id
order by Loyal_Customers desc limit 1;

-- Q.8 Find loyal customers for all restaurants ?
select r_name as "Restaurant", name as "Loyal Customers" from
(select r_id, user_id, count(*) visits 
from orders
group by r_id, user_id having visits > 1
order by r_id) t
join restaurants r on t.r_id = r.r_id
join users u on t.user_id = u.user_id;

-- Q.9 Find Month over Month revenue growth of Swiggy ?
select Month, concat(((revenue-lagging)/lagging)*100,"%") as "YOY Growth Rate" from
(select monthname(date) Month, sum(amount) Revenue,
lag(sum(amount)) over(order by month(date)) Lagging
from orders
group by month(date)) t;

-- Q.10 Find favourite food/dish of each customer ?
select name as Name, f_name as "Food" from
(select user_id, f_id, count(*) "frequency1",
first_value(count(*)) over(partition by user_id order by count(*) desc) "frequency2"
from orders o
join order_details od on o.order_id = od.order_id
group by user_id, od.f_id
order by user_id, frequency1 desc) t 
join users u on t.user_id=u.user_id 
join food f on t.f_id=f.f_id
where t.frequency1=t.frequency2;