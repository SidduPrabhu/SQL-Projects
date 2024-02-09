#Instagram user analytics
select username,created_at from users order by created_at limit 5;
#2
SELECT 
    u.id, u.username, COUNT(image_url) photos_posted
FROM
    users u
        LEFT OUTER JOIN
    photos p ON u.id = p.user_id
GROUP BY u.id
HAVING COUNT(image_url) = 0;

#3
select  p.user_id,u.username, photo_id,count(photo_id) total_likes
from photos p left outer join likes l on p.id = l.photo_id join users u on l.user_id = u.id group by p.user_id,p.id
order by total_likes desc limit 1;

#4
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

#5
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

#B1
select avg(cnt) avg from(select *,count(user_id) cnt
from photos group by user_id) a;
#B1.1
select cast(count(distinct photo_id)/count(distinct id) as float) cnt from
(select  u.id,p.id photo_id from users u  left outer join photos p on u.id = p.user_id) a;

#B2
select username,user_id,count(photo_id) total_liked_photos from likes l join users u on l.user_id=u.id group by user_id
having count(photo_id) in (select count(distinct id) cnt from photos p left join likes l  on  p.user_id = l.user_id) 
