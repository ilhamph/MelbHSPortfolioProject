/* when I run the query, I get some messages like this: 
conversion failed when converting the nvarchar value '79.0' to data type int
error converting data type nvarchar to float.
column, parameter, or variable #21: cannot specify a column width on data type int
operand data type varchar is invalid for avg operator.
operand data type nvarchar is invalid for avg operator.
So, I need to change the data type of some columns. there may be a better way but I don't know yet. */

ALTER TABLE melb_data
ALTER COLUMN Landsize float;

ALTER TABLE melb_data
ALTER COLUMN Price bigint;

ALTER TABLE melb_data
ALTER COLUMN Distance float;

ALTER TABLE melb_data
ALTER COLUMN Bedroom2 float;

ALTER TABLE melb_data
ALTER COLUMN Bathroom float;

ALTER TABLE melb_data
ALTER COLUMN Car float;


--General Statistics
SELECT COUNT(*) total_properties,
ROUND(AVG(price),0) average_price,
MAX(price) maximum_price,
MIN(price) minimum_price,
ROUND(AVG(bedroom2),2) average_bedroom,
ROUND(AVG(bathroom),2) average_bathroom,
ROUND(AVG(car),2) average_car
FROM melb_data;

--Real estate prices by region
Select Regionname, ROUND(AVG(Price),0) average_price from melb_data
WHERE Regionname Like 'Northern%'
OR Regionname Like 'Southern%'
OR Regionname Like 'Eastern%'
OR Regionname Like 'Western%'
Group by Regionname
ORDER BY average_price; 


-- Suburb that has the cheapest prices of real estate
select distinct TOP 10 Suburb, MIN(Price) as lowest_price from melb_data
group by Suburb
Order by lowest_price

-- Average price of distance of Properties to CBD (Central Business District)
SELECT distance_range, ROUND(AVG(Price),0) average_price from(
   SELECT CASE
    WHEN distance < 5 THEN '0-5 km'
    WHEN distance < 10 THEN '5-10 km'
    ELSE '10+ km'
  END AS distance_range, Price
FROM melb_data) melb_data
GROUP BY distance_range
ORDER BY average_price ASC;

-- Impact of distance on real estate prices
Select TOP 10 Suburb, ROUND(AVG(Distance),1) average_distance, ROUND(AVG(Price),0)average_price 
from melb_data
GROUP BY Suburb
ORDER BY average_distance ASC;


-- Relationship between real estate land size and price
select TOP 10 Suburb, ROUND(AVG(Price),0) average_price, ROUND(AVG(Landsize),2) average_landsize
from melb_data
group by Suburb
order by average_landsize DESC;

-- Annual price trends by real estate type
select Type, YEAR(Date) AS year_properties, ROUND(AVG(Price),0) average_price 
from melb_data
GROUP BY Type, YEAR(Date)
ORDER BY Type, YEAR(Date) ASC;


-- Real estate type with many amenities, affordable prices and close to CBD
Select Type, Suburb, Address, COUNT(*) total_properties from melb_data
where Bedroom2 > 1
AND Bathroom > 1
AND Car > 1
AND Landsize > 1000
AND Distance <= 4
AND Price < 700000
Group By Type, Suburb, Address
ORDER BY total_properties;


-- Real estate types with larger than average acreage at affordable prices.
SELECT Type, suburb, address, landsize 
FROM melb_data
WHERE landsize > (SELECT ROUND(AVG(landsize),1) FROM melb_data) 
AND Price <= 270000
ORDER BY landsize DESC;
