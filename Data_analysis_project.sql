Create database if not exists supply_chain_analytics;

-- total records
select count(*) as total_records 
from supply_chain_data;

-- Unique orders and order items
select 
count(distinct order_id) as total_orders,
count(distinct order_item_id) as total_order_items
from supply_chain_data;

-- date range
select min(order_date_dateorders) as first_order_date,
max(order_date_dateorders) as last_order_date
from supply_chain_data;

-- Unique Customers and Products
select
count(distinct customer_id) as total_customers,
count(distinct product_card_id) as total_products,
count(distinct category_id) as total_categories
from supply_chain_data;

-- Overall KPIs

select count(distinct order_id) as total_orders,
count(*) as total_order_items,
round(sum(sales),2) as total_sales,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(order_profit_per_order)*100 / sum(sales),2) as profit_margin_percentage,
round(avg(days_for_shipping_real),2) as avg_actual_shipping_days,
round(avg(days_for_shipment_scheduled),2) as avg_scheduled_shipping_days
from supply_chain_data;

-- Business Insights
-- 1. The Compnay received 65,752 orders with total of 1,80,519 items
-- 2. The company made $36.78 million in sales and earned $3.97 million in profit
-- 3. The overall profit margin was 10.78% which means company earned $10.78 profit for every $100 in sales 
-- 4. Shipping took 3.50 days on average while the planned time was 2.93 days. This shows that shipping was taking longer than planned.

-- Recommendation
-- 1. The company should focus on reducing shipping delays and finding ways to improve the profit margin.

-- Delivery status distribution
select delivery_status, count(distinct order_id) as total_orders
from supply_chain_data
group by delivery_status
order by total_orders desc;

-- Late delivery Rate
select count(distinct case when delivery_status = 'Late delivery' then order_id end) as late_orders,
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end) as non_cancelled_orders,
round(count(distinct case when delivery_status = 'Late delivery' then order_id end)*100/
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end),2) as_late_delivery_rate
from supply_chain_data;

-- Business Insight
-- 1. Out of 62,897 orders 36,048 orders were delivered late.
-- 2. The late delivery rate was 57.31% which means more than half of the orders were delivered late.

-- Recommnedation
-- 1. The company should check why orders are getting delayed and focus on improving on time deilveries

-- Average Shipping Delay
select round(avg(shipping_delay_days),2) as avg_shipping_delay_days,
max(shipping_delay_days) as maximum_delay_days,
min(shipping_delay_days) as miniumn_delay_days
from
(select order_id, max(shipping_delay_days) as shipping_delay_days
from supply_chain_data
where delivery_status <> 'shipping canceled'
group by order_id
) as order_shipping;

-- Shipping Mode performance
select shipping_mode, count(distinct order_id) as total_orders,
count(distinct case when delivery_status = 'Late delivery' then order_id end ) as late_orders,
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end ) as non_cancelled_orders,
round(count(distinct case when delivery_status = 'Late delivery' then order_id end)*100/
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end),2) as late_delivery_rate,
round(avg(days_for_shipping_real),2) as avg_actual_shipping_days,
round(avg(days_for_shipment_scheduled),2) as avg_scheduled_shipping_days
from supply_chain_data
group by shipping_mode
order by late_delivery_rate desc;

-- Business Insight
-- 1. First class had the highest late delivery rate of 100%. second class at 79.99%
-- 2. Standard class performed better than other shipping modes, with the lowest late delivery rate at 39.85%
-- 3. First class shipping took 2 days on average while planned time was only 1 day
-- 4. Standard class shipping took 4 days on average which matched its planned shipping time

-- Recommendation
-- 1. The company should review the shipping time promised for first class and second class orders and find ways to reduce the late deliveries

-- Regional late delivery analysis
select order_region, count(distinct order_id) as total_orders,
count(distinct case when delivery_status = 'Late delivery' then order_id end ) as late_orders,
round(count(distinct case when delivery_status = 'Late delivery' then order_id end)*100/
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end),2) as late_delivery_rate
from supply_chain_data
group by order_region
order by late_delivery_rate desc;

-- Business Insights
-- 1. Central Africa had the highest late delivery rate at 60.04% followed by East Africa at 59.08%
-- 2. Canada Had the lowest late delivery rate at 52.58% but more than half of its orders were still late.
-- 3. Western Europe had 5,585 late orders, while Central America had 5,156 late orders. These region had a large number of delayed orders

-- Recommendation
-- 1. The company should focus on region with high late delivery ratea and large number of delayed orders.
-- 2. It should check the reasons for delay and improve shipping in those regions

-- Delivery risk by Product Category
select category_name, count(distinct order_id) as total_orders,
count(distinct case when delivery_status = 'Late delivery' then order_id end ) as late_orders,
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end ) as non_cancelled_orders,
round(count(distinct case when delivery_status = 'Late delivery' then order_id end)*100/
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end),2) as late_delivery_rate
from supply_chain_data
group by category_name
order by late_delivery_rate desc;

-- Business Insights
-- 1. Golf bags and carts had the highest late delivery rate of 68.85% followed by lacrosse at 62.69%
-- 2. Mens golf clubs had the lowest late delivery rate at 49.63%
-- 3. Cleats had 11,228 late ordersm while mens footwear had the 10,247 late orders. These Categories had the large 
-- number of delayed orders 
-- 4. Most product categories had late delivery rates above 50% showing that delays are common across different categories

-- Recommendation
-- 1. The company should focus on categories with high late delivery rates and large number of late orders. 
-- 2. It should check the reason for delays and improve shipping plans for these products.

-- Financial Impact of late Deliveries
select delivery_status, count(distinct order_id) as total_orders, 
round(sum(sales),2) as total_sales,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(order_profit_per_order)*100/sum(sales),2) as profit_margin_percentage,
round(sum(sales)/count(distinct order_id),2) as avg_order_value
from supply_chain_data
group by delivery_status
order by total_sales desc;

-- Business Insights
-- 1. late deliveries had the highest sales of $20.13 Million with 36,048 orders.
-- 2. Orders shipped on time had the highest profit margin (11.13%) while late deliveries had lower profit margin (10.63%)
-- 3. The AOV was almost the same across all delivery statuses ($550-$563)
-- 4. Late deliveries had a slightly lower profit margin than on-time deliveries which may be worth investigating further.

-- Recommendation
-- 1. The company should focus on reducing late deliveries and check whether shipping delays are affecting profits.

-- Sales and Profit Peformace by Market
select market, count(distinct order_id) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(order_profit_per_order)*100/sum(sales),2) as profit_margin_percentage
from supply_chain_data
group by market
order by total_sales desc;

-- Business Insights
-- 1. Europe had the highest sales of $10.87 million and earned $1.17 million in profit
-- 2. LATAM was the second largest market with $10.28 million in sales
-- 3. USCA had the highest profit margin of 11.14% while pacific asia had the lowest at 10.37%
-- 4. Africa had the lowest sales of $2.29 million but its profit margin was (10.99%)

-- Recommendation
-- 1. The company should focus on improving profit margins in Pacific Asia and continue growing sales in Markets that are performing well.

-- Loss Making Orders Anlysis
with order_profitability as(
select order_id, sum(sales) as order_sales, sum(order_profit_per_order) as order_profit
from supply_chain_data
group by order_id)
select count(*) as total_orders,
sum(case when order_profit <0 then 1 else 0 end ) as loss_making_orders,
round(sum(case when order_profit<0 then 1 else 0 end)*100/count(*),2) as loss_making_order_percentage,
round(sum(case when order_profit <0 then order_profit else 0 end),2) as total_loss_amount,
round(sum(case when order_profit <0 then order_sales else 0 end),2) as sales_from_loss_making_orders
from order_profitability;

-- Business Insights
-- 1. Out of 65,752 orders, 13,909 orders are in loss
-- 2. 21.15% of total orders were loss making which means 1 out of 5 orders resulted in a loss
-- 3. The loss making orders generated $8.09 million in sales but resulted in total loss of $2.62 million

-- Recommendation
-- 1. The company should check why these orders are making losses are review product pricing, discounts, and costs to improve profitability.

-- Impact of Discounts on Profits
with discount_analysis as (
select order_item_id, order_id, sales, order_profit_per_order, order_item_discount_rate,
case when order_item_discount_rate = 0 then 'No Discount'
when order_item_discount_rate <= 0.10 then '1-10%'
when order_item_discount_rate <=0.20 then '11-20%'
when order_item_discount_rate <=0.30 then '21-30%'
else 'Above 30%'
end as discount_category
from supply_chain_data)
select discount_category, count(*) as total_order_items, 
count(distinct order_id) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(order_profit_per_order)*100/sum(sales),2) as profit_margin_percentage,
sum(case when order_profit_per_order <0 then 1 else 0 end) as loss_making_items
from discount_analysis
group by discount_category
order by case discount_category
when 'No Discount' then 1
when '1-10%' then 2
when'11-20%' then 3
when '21-30%' then 4
else 5 end;

-- Business Insights
-- 1. Product sold without discounts had the highest profit margin (13.09%)
-- 2. As discounts increased, profit margin decreased. Products with 21-30% discounts had the lowest profit margin(9.03%)
-- 3. The 1-10% discount group had the highest sales of $16.35 million and earned $1.88 million in profit
-- 4. The 1-10% dicsount group also had the highest number of loss making items at 14,891

-- Recommendation
-- 1. The company should review its dicount strategy and avoid giving high discouns on products where profit margins are already low.

-- Product Category Profitability Analysis
select category_name, count(distinct order_id) as total_orders,
count(*) as total_order_items,
round(sum(sales),2) as total_sales,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(order_profit_per_order)*100/sum(sales),2) as profit_margin_percentage,
sum(case when order_profit_per_order <0 then 1  else 0 end) loss_making_items
from supply_chain_data
group by category_name
order by total_profit desc;

-- Business Insights
-- 1. Fishing had the highest sales ($6.93 million) and earned ($7,56,221) in profit
-- 2. Cleats was the second most profitable category earning $4,94,637 in profit.
-- 3. Golf Bags are Carts had the highest profit margin of 17.46% but its total sales were only $10,369
-- 4. Strength Traning had the lowest profit margin of just 0.61%.
-- 5. Cleats had the highest number of loss making items at 4,590 followed by mens footwear at 4,169

-- Recommendation
-- 1. The company should review pricing and costs for categories with low profit margins, especially Stregth Training.
-- 2. It should also why some items in high selling categories are making losses.

-- YOY Sales and Profit Growth Analysis
with yearly_performance as (
select year(order_date_dateorders) as order_year, 
count(distinct order_id) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(order_profit_per_order),2) as total_profit
from supply_chain_data
where order_date_dateorders < '2018-01-01'
group by year(order_date_dateorders)),
yearly_growth as (
select order_year, total_orders, total_sales, total_profit,
lag(total_orders) over (order by order_year) as previous_year_orders,
lag(total_sales) over (order by order_year) as previous_year_sales,
lag(total_profit) over (order by order_year) as previous_year_profit
from yearly_performance)
select order_year, total_orders, total_sales, total_profit,
round(total_profit*100/total_sales,2) as profit_margin_percentage,
round((total_orders - previous_year_orders)*100 / previous_year_orders,2) as order_growth_percentage,
round((total_sales - previous_year_sales)*100 / previous_year_sales,2) as sales_growth_percentage,
round((total_profit - previous_year_profit)*100 / previous_year_profit,2) as profit_growth_percentage
from yearly_growth
order by order_year;

-- Business Insights
-- 1. Sales were highest in 2015 at $12.34 million followed by $12.30 million in 2016
-- 2. In 2017, number of orders increased by 4.83% but total sales decreased by 4.03%
-- 3. Profit decreased slightly each year from 2015 to 2017 but profit margin improved to 11.04% in 2017
-- 4. The increase in orders and decrease in sales in 2017 suggests that customers were spending less per order on average

-- Recommendation
-- 1. The company should check why sales are decreased despite receiving more orders in 2017.
-- 2. It should also look for ways to increase the average order value.

-- Customer Segmentation & Profitability Analysis
select customer_id, count(distinct order_id) as total_orders, round(sum(sales),2) as total_spending,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(sales)/count(distinct order_id),2) as average_order_value,
round(sum(order_profit_per_order)*100/sum(sales),2) as profit_margin_percentage
from supply_chain_data
group by customer_id
order by sum(sales) desc
limit 20;

-- Business Insights
-- 1. Customer 791 spent the most at $10,524.17 but the comapny made the loss of $866.38 from this customer
-- 2. Customer 2641 had the highest profit margin (26.47%) among the top 20 customers
-- 3. Three customers(791, 5715, 664) had the negative profits despite making larger purchases
-- 4. Customer 10351 had the highest AOV ($1,191.32) among top 20 customers

-- Recommendations
-- 1. Company should check why some high spending customers are making losses and review the discounts and cost linked to their orders

-- Regional sales, profitability and delivery risk analysis.
with regional_financials as(
select order_region, count(distinct order_id) as total_orders,
round(sum(sales),2) as total_sales, round(sum(order_profit_per_order),2) as total_profit
from supply_chain_data
group by order_region),

order_delivery as (
select order_id, max(order_region) as order_region,
max(delivery_status) as delivery_status,
max(shipping_delay_days) as shipping_delay_days
from supply_chain_data
group by order_id),

regional_delivery as (
select order_region, 
sum(case when delivery_status = 'Late delivery' then 1 else 0 end) as late_orders,
sum(case when delivery_status <> 'Shipping canceled' then 1 else 0 end) as non_cancelled_orders,
round(avg(case when delivery_status <> 'Shipping canceled' then shipping_delay_days end),2) as avg_shipping_delay_days
from order_delivery
group by order_region)

select f.order_region, f.total_orders, f.total_sales, f.total_profit,
round(f.total_profit *100/f.total_sales,2) as profit_margin_percentage,
d.late_orders,
round(d.late_orders *100/ d.non_cancelled_orders,2) as late_delivery_rate,
d.avg_shipping_delay_days
from regional_financials f
join regional_delivery d
on f.order_region = d.order_region
order by f.total_sales desc;

-- Business Insights
-- 1. Western Europe had the highest sales ($5.89 million) and earned ($6,25,446) in profit
-- 2. Central America was the second largest region with ($5.67 million) in sales and ($6,16,342) in profit
-- 3. Southern Africa had the highest profit margin of 13.51% while Eastern Asia had the lowest profit margin (9.91%)
-- 4. Central Africa had the highest late delivery rate of 60.04% followed by East Africa at 59.08%
-- 5. Western Europe had 5585 late orders, the highest number among all regions.

-- Recommendation
-- 1. Comapny should focus on reducing late deliveries in Western Europe and Central America as these regions
-- have high sales and many delayed orders
-- 2. It should review costs in region with low profit margin.

-- High risk product category analysis
with category_performance as(
select category_name, count(distinct order_id) as total_orders, count(*) as total_order_items,
round(sum(sales),2) as total_sales, round(sum(order_profit_per_order),2) as total_profit,
sum(case when order_profit_per_order <0 then 1 else 0 end) as loss_making_items,
round(sum(case when order_profit_per_order < 0 then order_profit_per_order else 0 end),2) as total_loss_amount
from supply_chain_data
group by category_name),

category_delivery as (
select category_name, 
count(distinct case when delivery_status = 'Late delivery' then order_id end) as late_orders,
count(distinct case when delivery_status <> 'Shipping canceled' then order_id end) as non_cancelled_orders
from supply_chain_data
group by category_name)

select c.category_name, c.total_orders, c.total_sales, c.total_profit,
round(c.total_profit*100/c.total_sales, 2) as profit_margin_percentage,
round(d.late_orders*100/d.non_cancelled_orders,2) as late_delivery_rate,
round(c.loss_making_items*100/c.total_order_items,2) as loss_making_item_percentage,
c.total_loss_amount
from category_performance c join category_delivery d
on c.category_name = d.category_name
order by late_delivery_rate desc;

-- Business Insights
-- 1. Golf Bags & Carts had the highest late delivery rate(68.85%) followed by lacrosse (62.69%)
-- 2. Fishing had the highest total loss amount of $7,28,571 followed by cleats ($4,52,594)
-- 3. Mens clothing had the highest percentage of loss making items at 24.04% followed by health and beauty (23.48%)
-- 4. Strength Training had the lowest profit margin of 0.61% even though its total profit was positive.
-- 5. Fishing and cleats generated high sales and profits but they also had large losses from some items.

-- Recommnedation
-- 1. The company should check pricing, discounts and costs in categories with high losses. 
-- 2. It should also focus on reducing late deliveries in categories where delays are common.

-- shipping delay analysis
with order_shipping as (
select order_id, max(delivery_status) as delivery_status,
max(shipping_delay_days) as shipping_delay_days
from supply_chain_data
group by order_id),

delay_categories as (
select order_id, shipping_delay_days, 
case when shipping_delay_days <0 then 'Early Shipping'
when shipping_delay_days = 0 then 'On Schedule'
when shipping_delay_days = 1 then '1 Day Late'
when shipping_delay_days = 2 then '2 Days Late'
when shipping_delay_days = 3 then '3 Days Late'
else '4+ days Late' 
end as delay_category
from order_shipping
where delivery_status <> 'Shipping canceled')

select delay_category, count(*) as total_orders,
round(count(*) *100 / sum(count(*))over(),2) as order_percentage,
round(avg(shipping_delay_days),2) as avg_shipping_delay_days
from delay_categories
group by delay_category
order by case delay_category
when 'Early Shipping' then 1
when 'On Schedule' then 2
when '1 Day Late' then 3
when '2 Days Late' then 4
when '3 Days Late' then 5
else 6
end;

-- Business Insights
-- 1. 33.59% of orders were shipped 1 day late
-- 2. 24.05% of orders were shipped earlier than planned
-- 3. Only 18.64% of orders were shipped exactly on schedule
-- 4. 7.80% of orders were delayed by 3 or more days

-- Recommendation
-- 1. The company should focus on reducing 1 day and 2 day delays because these affects many orders.
-- 2. It should also check the reason of longer delays

-- Shipping mode vs delay analysis
with order_shipping as (
select order_id,
max(shipping_mode) as shipping_mode, 
max(delivery_status) as delivery_status,
max(shipping_delay_days) as shipping_delay_days
from supply_chain_data
group by order_id),

shipping_analysis as(
select order_id, shipping_mode, shipping_delay_days,
case when shipping_delay_days <0 then 'Early Shipping'
when shipping_delay_days = 0 then 'On Schedule'
when shipping_delay_days between 1 and 2 then '1-2 Days Delay'
when shipping_delay_days >=3 then '3+ Days Delay'
end as delay_category
from order_shipping
where delivery_status <>'Shipping canceled')

select shipping_mode, count(*) as total_orders,
sum(case when delay_category = 'Early Shipping' then 1 else 0 end) as early_orders,
sum(case when delay_category = 'On Schedule' then 1 else 0 end) as on_scheduled_orders,
sum(case when delay_category = '1-2 Days Delay' then 1 else 0 end) as minor_delay_orders,
sum(case when delay_category = '3+ Days Delay' then 1 else 0 end) as severe_delay_orders,
round(sum(case when delay_category = '3+ Days Delay' then 1 else 0 end)*100/count(*),2) as severe_delay_percentage,
round(avg(shipping_delay_days),2) as avg_shipping_delay_days
from shipping_analysis
group by shipping_mode
order by severe_delay_percentage desc;

-- Business Insights
-- 1. Second class had the highest severe delay rate of 40.05% with 4908 orders delayed by 3 or more days
-- 2. First class had an average shipping delay of 1 day, while second class had an average delay of 2 days.
-- 3. Standard class had 15,127 orders shipped earlier than planned no orders with severe delay
-- 4. Same day shipping had 1648 orders delayed by 1-2 days while 1759 orders were on schedule.

-- Recommendation
-- 1. The company should review second class shipping because it has the highest number of severe delays.
-- 2. It should also check whether the planned shipping times for first class and second class are realistic


-- Final KPI summary
with order_summary as (
select order_id, sum(sales) as order_sales, sum(order_profit_per_order) as order_profit,
max(delivery_status) as delivery_status,
max(shipping_delay_days) as shipping_delay_days
from supply_chain_data
group by order_id),

overall_kpi as (
select count(*) as total_orders,
round(sum(order_sales),2) as total_sales,
round(sum(order_profit),2) as total_profit,
round(sum(order_profit)*100/sum(order_sales),2) as profit_margin_percentage,
round(avg(order_sales),2) as average_order_value,
sum(case when delivery_status = 'Late delivery' then 1 else 0 end) as late_orders,
sum(case when delivery_status <> 'Shipping canceled' then 1 else 0 end) as non_cancelled_orders,
sum(case when order_profit<0 then 1 else 0 end) as loss_making_orders,
round(avg(case when delivery_status <> 'Shipping canceled' then shipping_delay_days end),2) as avg_shipping_delay_days
from order_summary)

select total_orders, total_sales, total_profit, profit_margin_percentage, average_order_value,
round(late_orders*100/non_cancelled_orders,2) as late_delivery_rate,
round(loss_making_orders*100/total_orders,2) as loss_making_order_percentage,
avg_shipping_delay_days
from overall_kpi;