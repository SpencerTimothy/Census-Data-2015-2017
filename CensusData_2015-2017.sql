/*Sorce: https://www.kaggle.com/datasets/muonneutrino/us-census-demographic-data?select=acs2015_county_data.csv*/


/*Biggest population gains from 2015 to 2017*/

--The reason why I am using a temp table for this query is because I will be combining all queries into
--one table at the end of this project.
DROP TABLE IF EXISTS #temp_total_change_in_pop
CREATE TABLE #temp_total_change_in_pop (
[State] VARCHAR(20),
[Change in Population] int)

INSERT INTO #temp_total_change_in_pop 
SELECT acs2017_county_data.[State],
SUM(acs2017_county_data.TotalPop - acs2015_county_data.TotalPop) AS [Change in Population]
FROM acs2017_county_data
JOIN acs2015_county_data
ON acs2017_county_data.CensusId = acs2015_county_data.CensusId
GROUP BY acs2017_county_data.[State]

SELECT * FROM #temp_total_change_in_pop
ORDER BY [Change in Population] DESC
--We see that Texas, Florida, California, Nort Carolina and Georgia had the biggest population gains,
--while only Mississippi, Vermont, West Virginia, Illinois and Puerto Rico were the only states/territory
--were the only 5 to see losses in population

/*Now I'm curious who gained and lost the most according to thier total population*/

--Create temporary table to compile the population statistics for each county in 2015, 2017 and then create a column to 
--reflect the changes between the two years.
DROP TABLE IF EXISTS #temp_pop_stats
CREATE TABLE #temp_pop_stats (
State VARCHAR(50),
pop_2015 INT,
pop_2017 INT,
change_in_pop INT)

INSERT INTO #temp_pop_stats
SELECT acs2015_county_data.[State],
acs2015_county_data.TotalPop,
acs2017_county_data.TotalPop,
(acs2017_county_data.TotalPop - acs2015_county_data.TotalPop)
FROM acs2015_county_data
JOIN acs2017_county_data
ON acs2015_county_data.CensusId = acs2017_county_data.CensusId

SELECT * FROM #temp_pop_stats

--Create temporary table to group the sum of the change of the population by each state.
DROP TABLE IF EXISTS #temp_change_in_pop
CREATE TABLE #temp_change_in_pop (
[State] VARCHAR(50),
change_in_pop FLOAT)

INSERT INTO #temp_change_in_pop
SELECT [State], SUM(change_in_pop) 
FROM #temp_pop_stats
GROUP BY [State]

SELECT avg(change_in_pop) FROM #temp_change_in_pop

--Create temporary table to find the total population of 2015. This will serve as the initial population value.
DROP TABLE IF EXISTS #temp_total_pop
CREATE TABLE #temp_total_pop (
[State] VARCHAR(50),
TotalPop INT)

INSERT INTO #temp_total_pop
SELECT [State], SUM(TotalPop)  
FROM acs2015_county_data
GROUP BY [State]

SELECT * FROM #temp_total_pop

--Now query both temp tables to find the percent change in each state.
SELECT #temp_change_in_pop.[State], (#temp_change_in_pop.change_in_pop / #temp_total_pop.TotalPop) 
AS [Pct Change in Pop per State]
FROM #temp_change_in_pop
JOIN #temp_total_pop
ON #temp_change_in_pop.[State] = #temp_total_pop.[State]
ORDER BY [Pct Change in Pop per State] DESC
--We see the biggest growth for population growth per capita was District of Columbia, Texas, North Dakota,
--Florida, and Nevada.
--The biggest decrease in population per capita was Mississippi, Illinois, Vermont, West Verginia, and Puerto Rico


/*Lets look at the change in median household income for each state between 2015 and 2017*/

--Create temp table to reflect the average income for each state in 2015.
DROP TABLE IF EXISTS #temp_income_avg_2015
CREATE TABLE #temp_income_avg_2015 (
[State] VARCHAR(20),
[Average Income 2015] FLOAT)

INSERT INTO #temp_income_avg_2015
SELECT [State], AVG(Income) AS [Average Income 2015] 
FROM acs2015_county_data
GROUP BY [State]

SELECT * FROM #temp_income_avg_2015
ORDER BY [Average Income 2015] DESC

--Create temp table to reflect the average income for each state in 2017.
DROP TABLE IF EXISTS #temp_income_avg_2017
CREATE TABLE #temp_income_avg_2017 (
[State] VARCHAR(20),
[Average Income 2017] FLOAT)

INSERT INTO #temp_income_avg_2017
SELECT [State], AVG(CAST(Income  AS FLOAT)) AS [Average Income 2017] 
FROM acs2017_county_data
GROUP BY [State]

SELECT * FROM #temp_income_avg_2017
ORDER BY [Average Income 2017] DESC

--Query the two temp tables to find the biggest changes in median household income between 2015 and 2017.
SELECT TOP 5 #temp_income_avg_2015.[State], 
(#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) 
AS [Change in Income]
FROM #temp_income_avg_2015
JOIN #temp_income_avg_2017
ON #temp_income_avg_2015.[State] = #temp_income_avg_2017.[State]
ORDER BY [Change in Income] DESC

--We can see that the top 5 biggest changes in median household income were made by District of Columbia,
--Massachusetts, California, Utah, and New Hampshire.

--Query the two temp tables to find the smallest changes in median household income between 2015 and 2017.
SELECT TOP 5 #temp_income_avg_2015.[State], 
(#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) 
AS [Change in Income]
FROM #temp_income_avg_2015
JOIN #temp_income_avg_2017
ON #temp_income_avg_2015.[State] = #temp_income_avg_2017.[State]
ORDER BY [Change in Income] 

--We can also see the smallest changes in median household income were made by Puerto Rico, New Mexico,
--Louisiana, Wyoming, and Mississippi.

--One more table to see the entire list of changes of median household income for 2015 to 2017.
SELECT #temp_income_avg_2015.[State], 
(#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) 
AS [Change in Income]
FROM #temp_income_avg_2015
JOIN #temp_income_avg_2017
ON #temp_income_avg_2015.[State] = #temp_income_avg_2017.[State]
ORDER BY [Change in Income] DESC

/*Let's look at the percent change in income per state and territory*/

SELECT TOP 5 
#temp_income_avg_2015.[State], 
((#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) / #temp_income_avg_2015.[Average Income 2015]) 
AS [Pct Change in Income]
FROM #temp_income_avg_2015
JOIN #temp_income_avg_2017
ON #temp_income_avg_2015.[State] = #temp_income_avg_2017.[State]
ORDER BY [Pct Change in Income] DESC

SELECT TOP 5 
#temp_income_avg_2015.[State], 
((#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) / #temp_income_avg_2015.[Average Income 2015]) 
AS [Pct Change in Income]
FROM #temp_income_avg_2015
JOIN #temp_income_avg_2017
ON #temp_income_avg_2015.[State] = #temp_income_avg_2017.[State]
ORDER BY [Pct Change in Income] 

--The biggest relative changes in income in all 52 states and territories in this dataset of the United States are:
--District of Columbia, California, Utah, Washington, and Maine. 
--The smallest relative changes in income in all 52 states and territories in this dataset of the United States are: 
--New Mexico, Puerto Rico, Louisiana, Alaska, and Wyoming.

--And now we will look at all 52 states and territories included in this dataset.
SELECT #temp_income_avg_2015.[State],
((#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) / #temp_income_avg_2015.[Average Income 2015])
AS [Pct Change in Income]
FROM #temp_income_avg_2015
JOIN #temp_income_avg_2017
ON #temp_income_avg_2015.[State] = #temp_income_avg_2017.[State]
ORDER BY [Pct Change in Income] DESC

/*Let's combine all of these tables into one big table*/

SELECT #temp_total_change_in_pop.[State], 
#temp_total_change_in_pop.[Change in Population],
ROUND((#temp_change_in_pop.change_in_pop / #temp_total_pop.TotalPop), 6)
AS [Pct. Change in Population],
ROUND((#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]), 2) 
AS [Change in Income],
ROUND(((#temp_income_avg_2017.[Average Income 2017] - #temp_income_avg_2015.[Average Income 2015]) / #temp_income_avg_2015.[Average Income 2015]), 4) 
AS [Pct. Change in Income]
FROM #temp_total_change_in_pop
JOIN #temp_change_in_pop
ON #temp_total_change_in_pop.[State] = #temp_change_in_pop.[State] 
JOIN #temp_total_pop
ON #temp_total_change_in_pop.[State] = #temp_total_pop.[State]
JOIN #temp_income_avg_2015
ON #temp_change_in_pop.[State] = #temp_income_avg_2015.[State]
JOIN #temp_income_avg_2017
ON #temp_change_in_pop.[State] = #temp_income_avg_2017.[State]
ORDER BY [State]


