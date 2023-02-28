--CASE STUDY --OLYMPIC HISTORY

Select * from athletes

Select * from athlete_events

select * from athletes a inner join athlete_events ae on
a.id = ae.athlete_id

Select distinct team from athletes
--844 teams--
--42 Cities--
--2 seasons--
--65 sports--

--I have used these 2 tables athletes and athlete_events which we imported
--to answer various questions and derive insights from it

----------------------------------------------------------------------------
--1 which team has won the maximum gold medals over the years.
select TOP 1  team, Count(distinct event) as 'GoldMedals'  from athlete_events ae  inner join 
athletes a on
ae.athlete_id = a.id
where medal = 'Gold'
group by team
order by GoldMedals DESC


----------------------------------------------------------------------------
--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver



WITH CTE AS (
select team,year, count(distinct event) as 'SilverCount',
RANK() OVER(partition by team order by count(distinct event) desc) as 'rn'
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id
where medal = 'Silver'
group by team, year
)
select team,SUM(silvercount) as 'Total Silver Medals', 
MAX(case when rn = 1 then year end) as 'Max Silver year' from cte
group by team

----------------------------------------------------------------------------
--3-which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

select TOP 1 a.name, count(medal)
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id where 
a.id NOT IN (select athlete_id from athlete_events where medal IN ('silver','bronze'))
and medal = 'Gold'
group by a.name
order by count(medal) desc


----------------------------------------------------------------------------
--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

WITH CTE AS (
select year, a.name,   count(distinct event)as 'GoldMedalsCount' 
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id where medal = 'Gold'
group by year,a.name)
select year,goldmedalscount, STRING_AGG(name, ',') from (
select *, rank() OVER (partition by name order by goldmedalscount desc) as 'rn'
from cte)A
where rn = 1
group by YEAR,goldmedalscount

----------------------------------------------------------------------------
 --5--in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

with cte as (
select medal,year,sport,rank() OVER(partition by medal order by year ) As 'rn'
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id where team = 'India'
and medal <> 'NA')
select distinct * from cte where rn = 1


----------------------------------------------------------------------------
--6 find players who won gold medal in summer and winter olympics both.

with cte as (
select *
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id where medal = 'Gold'
and season = 'Summer'
)select * from cte where id IN (select athlete_id from athlete_events where season = 'Winter'
and medal = 'Gold')

--2nd Approach--
select a.name
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id
where medal = 'Gold'
group by a.name having count(distinct season) = 2

----------------------------------------------------------------------------
--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select year,a.name
from athlete_events ae inner join
athletes a on
ae.athlete_id = a.id where medal <> 'NA'
group by year, name HAVING  count(distinct medal) = 3

----------------------------------------------------------------------------
--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.


with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4

----------------------------------------------------------------------------
