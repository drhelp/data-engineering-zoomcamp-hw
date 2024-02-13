
-- Create tables
CREATE OR REPLACE EXTERNAL TABLE `dtc-de-course-412918.ny_taxi.external_green_tripdata_2022`
OPTIONS (
  format = 'parquet',
  uris = ['gs://de-zoomcamp-green-taxi-olegd/ny_green_taxi_2022/d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-*.parquet']
);

CREATE OR REPLACE TABLE `dtc-de-course-412918.ny_taxi.green_tripdata_non_partitoned` AS
SELECT * FROM `dtc-de-course-412918.ny_taxi.external_green_tripdata_2022`;

--Question 1: What is count of records for the 2022 Green Taxi Data??
select count(*)
from `dtc-de-course-412918.ny_taxi.external_green_tripdata_2022`;

-- Question 2:
-- Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
-- What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

select count(distinct PULocationID)
from `dtc-de-course-412918.ny_taxi.external_green_tripdata_2022`;

select count(distinct PULocationID)
from `dtc-de-course-412918.ny_taxi.green_tripdata_non_partitoned`;

-- Question 3:
-- How many records have a fare_amount of 0?
select count(*)
from `dtc-de-course-412918.ny_taxi.green_tripdata_non_partitoned`
where fare_amount = 0;

-- Question 4:
-- What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)

CREATE OR REPLACE TABLE dtc-de-course-412918.ny_taxi.green_tripdata_partitoned_clustered
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT * FROM dtc-de-course-412918.ny_taxi.external_green_tripdata_2022;

select count(*)
from dtc-de-course-412918.ny_taxi.green_tripdata_partitoned_clustered;

SELECT table_name, partition_id, total_rows
FROM dtc-de-course-412918.ny_taxi.INFORMATION_SCHEMA.PARTITIONS
WHERE table_name = 'green_tripdata_partitoned_clustered'
ORDER BY total_rows DESC;

-- Question 5:
-- Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)
-- Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values?

select distinct PULocationID
from `dtc-de-course-412918.ny_taxi.green_tripdata_non_partitoned`
where DATE(lpep_pickup_datetime) between '2022-06-01' and '2022-06-30';

select distinct PULocationID
from `dtc-de-course-412918.ny_taxi.green_tripdata_partitoned_clustered`
where DATE(lpep_pickup_datetime) between '2022-06-01' and '2022-06-30';


-- (Bonus: Not worth points) Question 8:
-- No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

select count(*)
from `dtc-de-course-412918.ny_taxi.green_tripdata_non_partitoned`;

