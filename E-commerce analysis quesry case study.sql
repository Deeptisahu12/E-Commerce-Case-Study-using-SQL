select * from customers;
select * from orderdetails;
select * from orders;
select * from product;

/**You can analyze all the tables by describing their contents.**/

desc customers;
desc orderdetails;
desc orders;
desc product;

/**Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.**/

## for this anlysis i used customers

select location,count(*) as number_of_customers from customers
group by location
order by number_of_customers desc
limit 3;   ## in this analysis Delhi,Chennai,Jaipur has the highest number of customers

/**Determine the distribution of customers by the number of orders placed. 
This insight will help in segmenting customers into one-time buyers, 
occasional shoppers, and regular customers for tailored marketing strategies.**/

## for this i used ordes table

select * from orders;

with cte1 as(select customer_id,count(order_id) as numberoforders,case
           when count(order_id)=1 then "one-time buyer"
           when count(order_id) between 2 and 4 then "Occasional Shoppers"
           else "Regular Customers"
           end as segments
           from orders
		group by customer_id
	order by numberoforders asc
)
select numberoforders,count(segments) as numberofcustomers from cte1
group by numberoforders
order by numberoforders asc; ## in the ouput there is one trend that numberoforders is increases then count of customers is decreses,occasional customers experiance most


/** Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

for this i used orderdetails table **/

select * from orderdetails;

select product_id,avg(quantity) AvgQuantity,sum(Quantity*price_per_unit) as TotalRevenue from orderdetails
group by product_id
having  AvgQuantity=2
order by totalrevenue desc;		## product 1 has highest revenue with 2 avgquantity

/**For each product category,
 calculate the unique number of customers purchasing from it. 
 This will help understand which categories have wider appeal across the customer base. **/
 
 -- for this i used orders,product,orderdetails tables
 
 select * from orders;
 select * from product;
 select * from orderdetails;
 
 select p.category,count(distinct o.customer_id) as unique_customers from product as p
 join orderdetails as od on p.product_id=od.product_id
 join orders as o on od.order_id=o.order_id
 group by p.category
 order by unique_customers desc;  ## Electronics product category needs more focus as it is in high demand among the customers
 
 /** Analyze the month-on-month percentage change in total sales to identify growth trends.**/
 
 ## for this i wil use orders table
 
 select * from orders;
 
 with cte1 as(select date_format(order_date,'%Y-%m') as Month,sum(total_amount) as totalsales
 from orders
 group by Month
 ),
 cte2 as (
     select Month,totalsales,lag(totalsales,1,null)over(order by month) as previous_sale from cte1
     )
 select Month,totalsales,round((totalsales-previous_sale)/previous_sale*100,2) as PercentChange from cte2;
 
 ## As per Sales Trend Analysis question, During feb-2024 month did the sales experience the largest decline
 ## from march to august sales flactuated with no trend
 /**
 
 /** Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
 
  for this i will use order table
  
  **/
  
  select * from orders;
WITH MonthlyAverageOrderValue AS (
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
        AVG(Total_Amount) AS AvgOrderValue
    FROM Orders
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
    order by month
    )
select Month,AvgOrderValue,round(AvgOrderValue-lag(AvgOrderValue,1,null)over(),2)as ChangeInValue
from MonthlyAverageOrderValue
order by ChangeInValue desc;  ## decemeber has highest change in average order values

/**Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
## for this i will use orrderdetails table **/

select * from orderdetails;

select product_id,count(quantity) as salesFrequency from orderdetails
group by product_id
order by salesFrequency desc
limit 5;   ## product number 7 has the highest turnover rate and needs to be restocked frequently

/**List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

## for this i will use all the tables**/

select * from customers;
select * from orderdetails;
select * from orders;
select * from product;

select p.product_id,p.name ,count(distinct c.customer_id) as UniqueCustomercount from customers as c
join orders as o on c.customer_id=o.customer_id
join orderdetails as od on o.order_id=od.order_id
join product as p on od.product_id=p.product_id
group by p.product_id,p.name
having uniquecustomercount<40;  ## due to poor visibility on the plateform products have purchase rates below 40% of the total customer base
## implement targeted marketing campaigns to raise awarness and interest, so this the trategic action to improve the sales of these underperforming products

/**Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
 ## for this i will use orders table  **/
 
 select * from orders;
 
  with cte1 as
 (select customer_id,min(date_format(order_date,'%Y-%m')) as firstpurchasemonth from orders
 group by customer_id
 )
 select firstpurchasemonth,count(customer_id) as totalnewcustomers from cte1
 group by firstpurchasemonth
 order by firstpurchasemonth asc;   ## it is downward trend which implies the marketing campaign are not much effective
 
 /**Identify the months with the highest sales volume, aiding in planning for stock levels,
 marketing efforts, and staffing in anticipation of peak demand periods. **/
 
 ## for this i will use orders table
 
 select * from orders;
 
 select date_format(order_Date,'%Y-%m') as Month,sum(total_amount) as totalsales from orders
 group by month
 order by totalsales desc
 limit 3;  ##  sep,dec will require major restocking of product and increased staffs
 
 