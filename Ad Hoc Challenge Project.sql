#Question 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region
select distinct market from dim_customer
where region = "apac";

#Question 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields,
#unique_products_2020
#unique_products_2021
#percentage_chg

with cte as (
select count(distinct case when fiscal_year=2020 then p.product_code else null end )as unique_products_20220,
count(distinct case when fiscal_year=2021 then p.product_code else null end )as unique_products_2021 
from fact_sales_monthly f cross join dim_product p on f.product_code=p.product_code)
select *,((unique_products_2021-unique_products_20220)/unique_products_20220)*100 pct_change from cte;

#Question 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains
2 fields,segment and product_count

select segment,count(distinct product_code) cnt
from dim_product
group by segment order by cnt desc;

#Question 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference

with cte as (
select p.segment,count(distinct case when fiscal_year=2020 then p.product_code else null end )as unique_products_20220,
count(distinct case when fiscal_year=2021 then p.product_code else null end )as unique_products_2021 
from fact_sales_monthly f cross join dim_product p on f.product_code=p.product_code
group by p.segment)
select *,unique_products_2021-unique_products_20220 difference from cte
order by difference desc;

#Question 5. Get the products that have the highest and lowest manufacturing costs.The final output should contain these fields,
product_code
product
manufacturing_cost

with cte as(
select m.product_code,p.product,m.manufacturing_cost
from fact_manufacturing_cost m join dim_product p on m.product_code =p.product_code)
select * from cte where manufacturing_cost=(select max(manufacturing_cost) from cte) or 
manufacturing_cost=(select min(manufacturing_cost) from cte);

#Question 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage

select c.customer_code,c.customer,
c1.pre_invoice_discount_pct
from dim_customer c join fact_pre_invoice_deductions c1 on c.customer_code=c1.customer_code
where c1.fiscal_year=2021 and c.market="india"
order by pre_invoice_discount_pct desc limit 5;

#Question 7. Get the complete report of the Gross sales amount for the customer “AtliqExclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount

select year(s.date) year,monthname(s.date) month,sum(s.sold_quantity*g.gross_price) gross_sales
from fact_sales_monthly s join dim_customer c on s.customer_code=c.customer_code 
join fact_gross_price g on s.product_code=g.product_code
where c.customer="Atliq Exclusive"
group by year(s.date),monthname(s.date);

#Question 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity


with cte as(
select *,case when month(date) in (9,10,11) then 1
when month(date) in (12,1,2) then 2
when month(date) in (3,4,5) then 3
when month(date) in (6,7,8) then 4 end as quarter
from fact_sales_monthly where fiscal_year = 2020)
select quarter,sum(sold_quantity) total_quantity_sold
from cte
group by quarter order by total_quantity_sold desc;

#Question 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage

with cte as(
select c.channel,sum(s.sold_quantity*g.gross_price) gross_sales
from fact_sales_monthly s join dim_customer c on s.customer_code=c.customer_code 
join fact_gross_price g on s.product_code=g.product_code
where s.fiscal_year=2021
group by c.channel)
select *,concat(round(gross_sales/(select sum(gross_sales) from cte)*100,2),"%") pct_contribution
from cte order by pct_contribution desc;

#Question 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
product
total_sold_quantity
rank_order


with cte as(
select p.division,p.product_code,p.product, sum(s.sold_quantity) gross_sales,
rank() over (partition by division order by sum(s.sold_quantity) desc) rnk
from fact_sales_monthly s join dim_product p on s.product_code=p.product_code
where s.fiscal_year=2021
group by p.division,p.product_code,p.product order by gross_sales desc)
select * from cte where rnk <=3
order by gross_sales desc,rnk asc;







