
--Analyzing the dataset


sp_help credit_card_transcations

Select * from credit_card_transcations

select distinct exp_type from credit_card_transcations

--Entertainment
--Food
--Bills
--Fuel
--Travel
--Grocery

select distinct card_type from credit_card_transcations

--Silver
--Signature
--Gold
--Platinum


select distinct count (*) from credit_card_transcations
select count(*) from credit_card_transcations

--CASE STUDY CREDIT CARD USAGE--

--1- Query to print top 5 cities with highest spends and their percentage contribution of total credit card spends


with cte1 as (
select city, SUM(amount) as 'CreditAmountSpend' from credit_card_transcations
group by city)
,total_spent as (select SUM(amount) as 'Total_amount' from credit_card_transcations)
select TOP 5 cte1.*, ROUND(CreditAmountSpend/total_amount * 100 *1.0,2) as 'Percentage_contribution' from cte1  inner join total_spent on 1=1
order by CreditAmountSpend desc

------------------------------------------------------------------------------------------------------------------------------
--2- Query to print highest spend month and amount spent in that month for each card type

WITH CTE AS(
select month(transaction_date) as 'Month', card_type ,sum(amount) as 'Total_spend'
from credit_card_transcations
group by month(transaction_date), card_type
)
,RNK AS(
Select *, rank() OVER(partition by card_type order by total_spend DESC) as 'rn' from cte)
Select month,total_spend from rnk where rn = 1

--2nd Approach--

WITH CTE AS(
select card_type , Year(transaction_date) as 'Year',month(transaction_date) as 'Month', sum(amount) as 'Total_spend'
from credit_card_transcations
group by card_type,Year(transaction_date),month(transaction_date)
)
,RNK AS(
Select *, rank() OVER(partition by card_type order by total_spend DESC) as 'rn' from cte)
Select Card_type ,year, month,total_spend from rnk where rn = 1


------------------------------------------------------------------------------------------------------------------------------
--3- Query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

WITH CTE AS (
select *, sum(amount) OVER (partition by card_type order by transaction_date,transaction_id) as 'total_spend' from credit_card_transcations
)
select * from (select *, rank() OVER(partition by card_type order by total_spend) as rn from cte where 
total_spend >= 1000000)A
 where rn = 1


------------------------------------------------------------------------------------------------------------------------------
--4- Query to find city which had lowest percentage spend for gold card type

WITH CTE AS (
select city,SUM(amount) as 'Total_spend' from credit_card_transcations where card_type = 'Gold'
group by city)
,c2 as (
select SUM(total_spend) as 'GOLD_TOTAL' from cte )
select TOP 1 cte.*,ROUND(total_spend/Gold_total * 100 *0.1,2) as 'Percentage_spend' 
from cte inner join c2 on 1=1
ORDER BY Percentage_spend asc

------------------------------------------------------------------------------------------------------------------------------
--5- Query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

WITH CTE AS (
select city,exp_type, SUM(amount) as 'Amount_spend' from credit_card_transcations
group by city,exp_type)
,c1 AS(
Select *, RANK() OVER (partition by city order by amount_spend DESC) as 'rndesc',
RANK() OVER (partition by city order by amount_spend) as 'rnasc' 
from CTE)
select city, 
MAX(CASE WHEN rndesc = 1 THEN exp_type END) AS 'Highest_expense_type',
MAX(CASE WHEN rnasc = 1 THEN exp_type END) AS 'lowest_expense_type'
from c1
GROUP BY city

------------------------------------------------------------------------------------------------------------------------------
--6- Query to find percentage contribution of spends by females for each expense type
select * from credit_card_transcations

select exp_type, 
SUM( case when gender = 'F' then amount else 0 end) *1.0/sum(amount) as 'Percentage_contribution' from
credit_card_transcations
group by EXP_type
order by Percentage_contribution desc;

------------------------------------------------------------------------------------------------------------------------------
--7- which card and expense type combination saw highest month over month growth in Jan-2014

WITH CTE AS (
select year(transaction_date) as 'yy',month(transaction_date) as 'mm', card_type, exp_type,SUM(AMOUNT) as 'Total_spend' from
credit_card_transcations
group by  year(transaction_date),month(transaction_date), card_type, exp_type),
c1 as (
Select *, lag(total_spend,1,total_spend) OVER (partition by card_type, exp_type order by yy,mm)
as 'Previous_Spend' from cte)
select TOP 1*, (total_spend -Previous_spend) as 'mom growth'
from c1 where yy = 2014 and mm = 01
order by [mom growth] DESC

------------------------------------------------------------------------------------------------------------------------------

--9- during weekends which city has highest total spend to total no of transcations ratio

--CONSIDERING WEEKENDS AS SAT,SUN

WITH CTE AS(
Select *,DATEPART(weekday,transaction_date) as 'DayNumber' from credit_card_transcations
where DATEPART(weekday,transaction_date) IN (1,7)
)
select city,SUM(amount) *1.0/count(1) as ratio from cte group by city
order by ratio desc

------------------------------------------------------------------------------------------------------------------------------

--10- which city took least number of days to reach its 500th transaction after the first transaction in that city

WITH CTE AS(
select *, row_number() OVER (partition by city order by transaction_date, transaction_id) as rn from credit_card_transcations
)
Select TOP 1 city, DATEDIFF(DAY, MIN(transaction_date),MAX(transaction_date)) as 'Datedifference'
from CTE where rn = 1 or rn = 500
GROUP BY City
HAVING COUNT(1) = 2
order by DATEDIfference asc

------------------------------------------------------------------------------------------------------------------------------
--END--