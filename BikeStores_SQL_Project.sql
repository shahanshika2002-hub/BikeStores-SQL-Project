use bike_store;

/*What is the total number of customers in the database?*/
select count(customer_id) as Total_Customer from customers;

/*List all products along with their categories and brands.*/
select 
	p.product_name,
    c.category_name,
    b.brand_name
from products p
join categories c
using (category_id)
join brands b
using (brand_id);

/*Find the total number of orders placed in the last month.*/
select COUNT(order_id) as total_orders
from orders
where order_date between
      date_sub((select MAX(order_date) from orders), interval 1 month)
      and
      (select MAX(order_date) from orders);
      
/*Determine the total sales revenue by product category.*/
select
	c.category_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue
from order_items oi
left join products p
using (product_id)
left join categories c
using (category_id)
group by c.category_name;

/*Identify top 10 customers by total order value.*/
select 
	order_id,
    SUM(quantity * list_price * (1 - discount)) as total_order
from order_items 
group by order_id 
order by total_order desc
limit 10;

/*What are the average prices of products by brand?*/
select 
    avg(p.list_price) as avg_price,
    b.brand_name
from products p
join brands b
using (brand_id)
group by b.brand_name;

/*List staff members and the number of orders each has handled.*/
select 
	s.first_name,
    count(o.order_id) as total_orders
from staffs s
join orders o
using (staff_id)
group by s.first_name
order by total_orders desc;

/*Show the inventory stock levels for each product by store.*/
select
	sk.quantity,
    p.product_name,
    s.store_name
from stocks sk
left join products p
using (product_id)
left join stores s
using (store_id)
order by sk.quantity desc;

/*Find orders that contain more than 5 items.*/
select
	order_id,
    count(product_id) as items
from order_items
group by order_id
having count(product_id)>5
order by items desc;

/*What is the average order size (number of items per order)?*/
select avg(item_count) as average_order_size
from (
    select order_id, COUNT(product_id) as item_count
    from order_items
    group by order_id
) as order_summary;

/*Identify which stores have the highest and lowest total sales.*/
(
Select 
	s.store_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
from order_items oi
join orders o
using(order_id)
join stores s
using(store_id)
group by s.store_name
order by total_sales desc
limit 1
)
UNION
(
Select 
	s.store_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
from order_items oi
join orders o
using(order_id)
join stores s
using(store_id)
group by s.store_name
order by total_sales asc
limit 1
);

/*List customers who have not placed any orders.*/
select
	c.customer_id,
	c.first_name,
    c.last_name
from customers c
join orders o
using(customer_id)
where order_id is null;

/*Find the most popular product by quantity sold.*/
Select 
	p.product_name,
    sum(oi.quantity) as total_quantity_sold
from order_items oi 
join products p
using(product_id)
group by p.product_name
order by total_quantity_sold desc limit 1;

/*Show all orders that were placed by a specific customer (e.g., customer ID).*/
select 
	c.first_name,
    c.last_name,
    o.order_id,
    o.order_status,
    o.order_date
from customers c
join orders o
using(customer_id)
where c.customer_id = 5;

/*Calculate total sales by store location.*/
select
	s.store_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
from order_items oi
join orders o
using(order_id)
join stores s
using(store_id)
group by s.store_name
order by total_sales desc;

/*What is the percentage of orders that include a discount?*/
select
    (COUNT(distinct case when discount > 0 then order_id end) * 100.0)
    / COUNT(distinct order_id) as discount_percentage
from order_items;

/*Find the earliest and latest order dates.*/
select 
	min(order_date) as earliest_order,
    max(order_date) as latest_order
from orders;

/*List all products that are out of stock in any store.*/
select 
	p.product_name,
    s.store_name,
    sk.quantity
from stocks sk
join products p
using(product_id)
join stores s
using(store_id)
where sk.quantity=0;

/*Aggregate total sales by staff member.*/
select
	s.first_name,
    s.last_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
from order_items oi
join orders o
using(order_id)
join staffs s
using(staff_id)
group by s.staff_id, s.first_name, s.last_name
order by total_sales desc;

/* Show products whose price is above the overall average product price */
select
	product_name,
    list_price
from products 
where list_price > 
	(
		select avg(list_price)
        from products
	);