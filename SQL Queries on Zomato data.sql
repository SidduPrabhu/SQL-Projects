select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

# What is the total amount each customers spent on zomato?

select s.userid,sum(p.price) total_amt_spent
from 
sales s join product p on s.product_id = p.product_id
group by userid;

# How many days has each customer visited zomato?

select userid,count(distinct created_date) distinct_days from sales
group by userid;

#What was the first product purchased by each customer?

select * from
(select *, rank() over (partition by userid order by created_date) rnk from sales) a
where rnk = 1;

#What is the most purchased item on the menu and how many times was it purchased by all customers?

select userid,count(product_id) cnt from sales where product_id =
(select product_id from sales 
group by product_id 
order by count(product_id) desc limit 1)
group by userid;

#Which item was the most popular for each customer?

select userid,product_id,max(cnt) most_cnt from
(select userid,product_id,count(product_id) cnt
from sales
group by userid,product_id order by cnt desc) a
group by userid order by userid;

#Using Rank
select * from
(select*, rank() over (partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt
from sales
group by userid,product_id) a)b
where rnk = 1;

#Which item was first purchased by the customer after they became a member?

select * from
(select c.*,rank() over (partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a join goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date) c)d where rnk = 1;

#Which item was purchased just before the customer became a member?

select * from
(select c.*,rank() over (partition by userid order by created_date desc) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a join goldusers_signup b on a.userid = b.userid and created_date < gold_signup_date) c)d where rnk = 1;

#What is the total orders and amount spent for each member before they became a member?

select userid,count(created_date) order_purchased,sum(price) total_amt_spent from
(Select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a join goldusers_signup b on a.userid = b.userid and created_date < gold_signup_date) c 
join product d on c.product_id = d.product_id) s
group by userid;

# In th first one year after customer joins a gold program (including their date) irrespective of what the customer has purchased they earn 5 zomato points for every 10rs spent, what was the customers points earnings in their first year

select s.*,p.price,g.gold_signup_date from sales s join product p on s.product_id = p.product_id
join goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date and created_date <= dateadd(year,1,gold_signup_date)
