Create database Zomato_Data;
use Zomato_Data;
Select * from main;

#KPIs
Select concat(Round(Sum(Indian_Price)/1000000,2), "M") as Total_Sales_in_Rupee from main;

Select count(distinct Restaurant_ID) as Total_Restaurants from main; 

Select sum(Votes) as Total_Votes from main;

Select count(distinct city) as Total_Cities from main;

Select count(distinct Country_Name) as Total_Country from country;
 
Select round(Avg(Rating),2) as Average_Rating from main;


-- TOTAL SALES BY MONTHS
Select Month_Name, Round(Sum(Indian_Price),0) as Total_Sales
from main
group by month_name, month_opening
order by Month_opening;


-- TOTAL SALES BY FINANCIAL QUARTER
Select Financial_Quarter, Round(Sum(Indian_Price),0) as Total_Sales
from main
group by financial_quarter
order by total_sales desc;


-- TOP 5 RESTAURANTS BY SALES
Select Restaurant_Name, Round(Sum(Indian_Price),0) as Total_Sales from main 
group by restaurant_name
order by Total_sales desc
limit 5;

SELECT restaurant_name, total_sales
FROM (
SELECT restaurant_name, ROUND(SUM(Indian_Price), 0) AS total_sales,
DENSE_RANK() OVER (
ORDER BY ROUND(SUM(Indian_Price), 0) DESC) AS sales_rank
FROM main
GROUP BY restaurant_name
) t
WHERE sales_rank <= 5
ORDER BY total_sales DESC;


-- TOP 500 CUISINES BY AVERAGE RATING
Select Cuisines, round(Avg(Rating),2) as Average_Rating
from main 
group by Cuisines
order by Average_rating desc
limit 500;


-- AVERAGE RATING PER CITY
Select City, round(Avg(rating),2) as Average_Rating from main
group by city
order by average_rating desc;


-- PERCENTAGE OF RESTAURANTS HAVING TABLE BOOKING
Select Has_table_booking,
concat(Round(Count(*) * 100.0 / SUM(COUNT(*)) OVER (), 2), "%") AS Percentage
from main
group By Has_table_booking
order BY Percentage desc;


-- PERCENTAGE OF RESTAURANTS HAVING ONLINE DELIVERY
Select Has_online_delivery,
concat(Round(Count(*) * 100.0 / SUM(COUNT(*)) OVER (), 2), "%") AS Percentage
from main
group By Has_online_delivery
order BY Percentage desc;


-- PRICE RANGE BY COUNT OF RESTAURANTS 
Select Price_Range,COUNT(*) AS Total_Count
From (Select
CASE
When Indian_Price <= 300 then '0-300'
When Indian_Price <= 600 then '301-600'
When Indian_Price <= 1000 then '601-1000'
else '1001 and above'
end as Price_Range
from main
) t 
group by Price_Range
order by
CASE
When Price_Range = '0-300' then 1
When Price_Range = '301-600' then 2
When Price_Range = '601-1000' then 3
else 4
END;


-- SALES BY WEEKTYPE
Select 
case
when week_name in ("Saturday","Sunday") then "WeekEnds"
else "WeekDays"
end as Weektype,
concat(ROUND(SUM(Indian_Price) * 100.0 / SUM(SUM(Indian_Price)) OVER (), 2), "%") AS Percentage_Of_Sales
from main
group by Weektype
order by Percentage_Of_Sales desc;


-- COUNTRY BY SALES
Select a.Country_name  as Country_Name, Round(Sum(b.Indian_Price),0) as Total_Sales
from main as b
join country as a
on a.country_id = b.country_code
group by a.Country_name
order by total_sales desc;


-- YEAR WISE DATA
call zomato_data.YEAR_WISE_DATA(2015);


-- FULL RESTAURANT WISE DATA
Create View Restaurant_Data as
Select a.Restaurant_id as Restaurant_ID,
a.Restaurant_name as Restaurant_Name,
b.country_name as Country_Name, a.City City, 
a.Locality Locality, a.Cuisines as Cuisines, 
a.Currency as Currency,
c.USD_Rate In_USD_Rate,
round(sum(a.Usd_price),2) Total_Sales_in_Dollars,
Round(Sum(a.Indian_Price),2) as Total_Sales_in_Rupee,
Sum(a.votes) Total_Votes, Avg(a.rating) as Average_Rating
from main as a
left join country as b
on a.Country_Code = b.Country_id
left join currency as c
on a.currency = c.Currency
group by a.Restaurant_id, a.Restaurant_name, b.country_name, a.City, a.Locality, c.usd_rate, a.Cuisines, a.Currency
order by a.City;

Select * from Restaurant_Data;

##drop view Restaurant_Data;
