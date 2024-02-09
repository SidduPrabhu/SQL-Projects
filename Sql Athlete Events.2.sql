#Write a query to fetch unique games played in the event
select count(distinct games) from athlete_events;

select year,season,city from athlete_events;

#Write a query to fetch highest games played by a country and lowest games played by a country
with countries as
(select games,count(distinct noc) tot_countries
from athlete_events
group by games)
select distinct concat(first_value(games) over (order by tot_countries),"-",first_value(tot_countries) over (order by tot_countries)) lowest,
concat(first_value(games) over (order by tot_countries desc),"-",first_value(tot_countries) over (order by tot_countries desc)) highest
from countries;

select n.region,count(distinct games) total_games
    from athlete_events a join noc_regions n on a.noc = n.noc
    group by n.region
    having count(distinct games) = (select count(distinct games) from athlete_events);
    
    with all_games as
    (select count(distinct games) tot_games from athlete_events where season = "summer"),
games as
    (select sport,count(distinct games) tot
    from athlete_events group by sport)
    select g.sport,g.tot no_of_games,a.tot_games
    from games g join all_games a on g.tot = a.tot_games;
    
    #Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics
    with games as
    (select distinct sport, games from athlete_events),
    sport as
   (select sport,count(distinct games) cnt
    from athlete_events
    group by sport
    having count(distinct games) = 1)
    select c.*,g.games
    from sport c join games g on c.Sport = g.sport
    order by c.sport asc;
    
    #Write SQL query to fetch the total no of sports played in each olympics.
    select games,count(distinct sport) cnt
    from athlete_events
    group by games;
    
    #SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.
    select * from athlete_events
    where age = (select max(age) from athlete_events where medal="gold") and medal = "gold";
    
    select count(distinct name) from athlete_events where sex = "M";
    
    #SQL query to fetch the top 5 athletes who have won the most gold medals.
    select a.* from
    (select name,team,count(medal) cnt,dense_rank() over (order by count(medal) desc) rnk
    from athlete_events 
    where medal = "gold"
    group by name,team order by cnt desc) a
where rnk <=5;

#SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).
    select a.* from
    (select name,team,count(medal) cnt,dense_rank() over (order by count(medal) desc) rnk
    from athlete_events 
    where medal in ("gold","silver","bronze")
    group by name,team order by cnt desc) a
where rnk <=5;

#Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).
select a.* from
(select n.region country,count(medal) total_medals,rank() over (order by count(medal) desc) rnk
from athlete_events a join noc_regions n on a.NOC = n.noc
group by n.region) a
where rnk <= 5;

 #Write a SQL query to list down the  total gold, silver and bronze medals won by each country.

 select n.region country,sum(case when medal = "gold" then 1 else 0 end) as gold,
 sum(case when medal = "silver" then 1 else 0 end) as silver,
 sum(case when medal = "bronze" then 1 else 0 end) as bronze
 from athlete_events a join noc_regions n on a.NOC = n.NOC
 group by n.region order by gold desc,silver desc,bronze desc;
 
 #Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.
  select games, n.region country,sum(case when medal = "gold" then 1 else 0 end) as gold,
 sum(case when medal = "silver" then 1 else 0 end) as silver,
 sum(case when medal = "bronze" then 1 else 0 end) as bronze
 from athlete_events a join noc_regions n on a.NOC = n.NOC
 group by a.Games, n.region order by a.games;
 
 
 #Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.
 with medals as
  (select a.games, n.region country,sum(case when medal = "gold" then 1 else 0 end) as gold,
 sum(case when medal = "silver" then 1 else 0 end) as silver,
 sum(case when medal = "bronze" then 1 else 0 end) as bronze
 from athlete_events a join noc_regions n on a.NOC = n.NOC
 group by a.games,n.region order by games, gold desc,silver desc,bronze desc)
 select distinct games,concat(first_value(country) over (partition by games order by gold desc),"-",first_value(gold) over (partition by games order by gold desc)) as MAx_Gold,
 concat(first_value(country) over (partition by games order by silver desc),"-",first_value(silver) over (partition by games order by silver desc)) as MAx_Silver,
 concat(first_value(country) over (partition by games order by bronze desc),"-",first_value(bronze) over (partition by games order by bronze desc)) as MAx_bronze 
 from medals
 order by games;
 
 #Similar to the previous query, identify during each Olympic Games, which country won the highest gold, silver and bronze medals. Along with this, identify also the country with the most medals in each olympic games.
  with medals as
  (select a.games, n.region country,sum(case when medal = "gold" then 1 else 0 end) as gold,
 sum(case when medal = "silver" then 1 else 0 end) as silver,
 sum(case when medal = "bronze" then 1 else 0 end) as bronze,
 count(medal) total
 from athlete_events a join noc_regions n on a.NOC = n.NOC
 group by a.games,n.region order by games, gold desc,silver desc,bronze desc)
 select distinct games,concat(first_value(country) over (partition by games order by gold desc),"-",first_value(gold) over (partition by games order by gold desc)) as MAx_Gold,
 concat(first_value(country) over (partition by games order by silver desc),"-",first_value(silver) over (partition by games order by silver desc)) as MAx_Silver,
 concat(first_value(country) over (partition by games order by bronze desc),"-",first_value(bronze) over (partition by games order by bronze desc)) as MAx_bronze,
 concat(first_value(country) over (partition by games order by total desc),"-",first_value(total) over (partition by games order by total desc)) as Max_Medals
 from medals
 order by games;
 
 #Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal.
 select a.* from
 (select n.region as country,sum(case when medal = "gold" then 1 else 0 end) as gold,
 sum(case when medal = "silver" then 1 else 0 end)as silver,sum(case when medal = "bronze" then 1 else 0 end) as bronze
 from athlete_events a join noc_regions n on a.NOC = n.NOC
 group by n.region) a
 where gold = 0 and silver <> 0 and bronze <> 0;
 
#Write SQL Query to return the sport which has won India the highest no of medals. 
select a.sport,count(medal) total_medals
from athlete_events a join noc_regions n on a.NOC = n.NOC
where n.region = "india"
group by sport
order by total_medals desc
limit 1;

#Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 
select n.region team,a.sport,a.games,count(medal) medales_won
from athlete_events a join noc_regions n on a.noc = n.noc
where n.region = "india" and a.Sport = "hockey"
group by a.games;


 



