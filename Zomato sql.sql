drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


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
