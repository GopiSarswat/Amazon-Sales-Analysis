-- Amazon Sales Analysis

-- Use the database in which you perform the task
use Projects;

-- Now import the CSV file in which data are stored through data import wizard
-- Select the table in which data are imported 
Select * from AMAZON;
-- Count the rows of Dataset
Select count(*) from AMAZON;

-- 15 Business Problems for Amazon Sales Analysis

-- A. Customer and Review Insights 

--1. Identify the top rated products
Select product_name, category, rating from AMAZON
where rating = (Select max(rating) from AMAZON where AMAZON.category = category)
order by rating, category desc;

--2. Find the customer who wrote the most reviews
Select Trim(Value) as user_names, count(*) as Review_count from AMAZON
cross apply string_split(user_name, ',') as Users
group by Trim(value)
order by Review_count desc;

--3. Analyze the distribution of product ratings and identify products with consistently poor ratings 
Select rating, count(*) as product_count from AMAZON
where rating is not null
Group by rating 
order by product_count desc;

--4. Determine the most common keywords in review titles for each product category 
Select category, Value as word, count(*) as word_frequency from AMAZON 
cross apply string_split(review_title, ',') as words
group by category , Value
order by word_frequency desc;

--5. Identify customers who purchased multiple products from same category
Select Trim(Value) as user_name , category, Count(distinct product_id) as product_count from AMAZON
cross apply string_split(user_name, ',') as Splitnames
group by Trim(Value), category
having count(distinct product_id) > 1
order by product_count desc;

-- B. Product performance 

--6. Compare the average discounted price to actual prices across categories to understand discount trends
Select category, Avg(discounted_price) as Average_discounted_price, 
Avg(actual_price) as Average_Actual_price from AMAZON
group by category
order by category;

--7. List the products with a discount percentage is higher than 50% and their sales ranking 
Select product_id, product_name, actual_price, discounted_price, discount_percentage*100 as discount_percentage from AMAZON
where discount_percentage > 0.5
order by discount_percentage desc;

--8. Rank product categories based on the number of products
Select category, count(*) as Product_count from AMAZON
group by category
order by Product_count desc;

--9. Identify the products with the highest difference between their ratings and their rating counts (e.g., highly rated but low reviews)
Select product_id, product_name, rating, rating_count from AMAZON
where rating >= 4.5 and rating_count <= 1000
order by rating desc, rating_count;

--10. Find which products have been reviewed by the same customers multiple times.
Select product_name, Trim(Value) as user_name, count(*) as review_count from AMAZON
cross apply string_split(user_name, ',') as Users
group by product_name, Trim(value)
having count(*) > 1
order by review_count desc;

-- C. Pricing and Sales Insights

--11. Calculate the average discount percentage across all products and identify outliers.
Select product_name, discount_percentage*100 as discouny_percentage from AMAZON ,
(Select Avg(discount_percentage) as Average, STDEV(discount_percentage) as std_dev from AMAZON) as DiscountStats
where discount_percentage < Average - 2 * std_dev or discount_percentage > Average + 2 * std_dev;

--12. Identify categories with the lowest-priced products
Select category, Min(discounted_price) as Lowest_price from AMAZON
group by category
order by Lowest_price ;

--13. Determine the average discounted price of the most frequently reviewed products in each category.
with Most_reviewed as(
	Select category, Max(Rating_count) as Max_review from AMAZON
	group by category)
Select a.category, Avg(discounted_price) as Avg_price from AMAZON as a Inner join Most_reviewed as m
on a.category = m.category and a.rating_count = m.Max_review 
group by a.category
order by a.category;

--14. List products that are priced below their category average.
with Category_Avg_price as(
	Select category, Avg(discounted_price) as Avg_price from AMAZON
	group by category)
Select a.product_name, a.category, a.discounted_price from AMAZON as a Inner join Category_Avg_price as c
on a.category = c.category 
where a.discounted_price < c.Avg_price
order by a.discounted_price;

-- D. Image and Marketing Analysis

--15. Determine products with missing or incomplete image links to improve listings
Select product_name, img_link from AMAZON
where img_link is null or img_link not like 'https://%';
