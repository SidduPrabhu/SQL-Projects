#Question A1:
Rewarding Most Loyal Users: People who have been using the platform for the longest time.
Your Task: Find the 5 oldest users of the Instagram from the database provided
    
select username,created_at from users order by created_at limit 5;
#Question A2:
Remind Inactive Users to Start Posting: By sending them promotional emails to post their 1st
photo.
Your Task: Find the users who have never posted a single photo on Instagram
    
SELECT 
    u.id, u.username, COUNT(image_url) photos_posted
FROM
    users u
        LEFT OUTER JOIN
    photos p ON u.id = p.user_id
GROUP BY u.id
HAVING COUNT(image_url) = 0;

#Question A3:
Declaring Contest Winner: The team started a contest and the user who gets the most likes on a
single photo will win the contest now they wish to declare the winner.
Your Task: Identify the winner of the contest and provide their details to the team.
    
select  p.user_id,u.username, photo_id,count(photo_id) total_likes
from photos p left outer join likes l on p.id = l.photo_id join users u on l.user_id = u.id group by p.user_id,p.id
order by total_likes desc limit 1;

#Question A4:
Hashtag Researching: A partner brand wants to know, which hashtags to use in the post to
reach the most people on the platform.
Your Task: Identify and suggest the top 5 most commonly used hashtags on the platform
    
select t.tag_name,p.tag_id,count(tag_name) cnt
from photo_tags p join tags t on p.tag_id = t.id
group by tag_name order by cnt desc limit 5;

#Creating a day name
select *, case when weekday(created_at) = '0' then "Monday" 
 when weekday(created_at) = '1' then "Tuesday" 
when weekday(created_at) = '2' then "Wednesday" 
when weekday(created_at) = '3' then "Thursday" 
when weekday(created_at) = '4' then "Friday" 
when weekday(created_at) = '5' then "Saturday" 
when weekday(created_at) = '6' then "Sunday" end as day_name
from comments;

#Question A5:
Launch AD Campaign: The team wants to know, which day would be the best day to launch
ADs.
Your Task: What day of the week do most users register on? Provide insights on when to
schedule an ad campaign

select a.*,count(day_name) cnt from
(select *, case when weekday(created_at) = '0' then "Monday" 
 when weekday(created_at) = '1' then "Tuesday" 
when weekday(created_at) = '2' then "Wednesday" 
when weekday(created_at) = '3' then "Thursday" 
when weekday(created_at) = '4' then "Friday" 
when weekday(created_at) = '5' then "Saturday" 
when weekday(created_at) = '6' then "Sunday" end as day_name
from users) a
group by day_name order by cnt desc;

#Question B1:
User Engagement: Are users still as active and post on Instagram or they are making fewer
posts
Your Task: Provide how many times does average user posts on Instagram. Also, provide the
total number of photos on Instagram/total number of users
    
select avg(cnt) avg from(select *,count(user_id) cnt
from photos group by user_id) a;
#Question B1.1:
Also, provide the total number of photos on Instagram/total number of users
    
select cast(count(distinct photo_id)/count(distinct id) as float) cnt from
(select  u.id,p.id photo_id from users u  left outer join photos p on u.id = p.user_id) a;

#Question B2:
Bots & Fake Accounts: The investors want to know if the platform is crowded with fake and
dummy accounts
Your Task: Provide data on users (bots) who have liked every single photo on the site (since any
normal user would not be able to do this).
    
select username,user_id,count(photo_id) total_liked_photos from likes l join users u on l.user_id=u.id group by user_id
having count(photo_id) in (select count(distinct id) cnt from photos p left join likes l  on  p.user_id = l.user_id) 
