# HW1 - Load NY Taxi data to Postgres

### Connect to database (psql)
    psql -h localhost -p 5432 -U postgres -d de_zoomcamp  

### Create tables

    CREATE TABLE ny_taxi.nyc_green_taxi_trips (
        VendorID INT,
        lpep_pickup_datetime TIMESTAMP,
        lpep_dropoff_datetime TIMESTAMP,
        store_and_fwd_flag CHAR(1),
        RatecodeID INT,
        PULocationID INT,
        DOLocationID INT,
        passenger_count INT,
        trip_distance DECIMAL,
        fare_amount DECIMAL,
        extra DECIMAL,
        mta_tax DECIMAL,
        tip_amount DECIMAL,
        tolls_amount DECIMAL,
        ehail_fee DECIMAL,
        improvement_surcharge DECIMAL,
        total_amount DECIMAL,
        payment_type INT,
        trip_type INT,
        congestion_surcharge DECIMAL
    );

    CREATE TABLE ny_taxi.nyc_taxi_zones (
        LocationID INT PRIMARY KEY,
        Borough VARCHAR(100),
        Zone VARCHAR(100),
        service_zone VARCHAR(100)
);

### Load data from csv (using psql)
    \COPY ny_taxi.nyc_green_taxi_trips FROM '/Users/olegd/Documents/Learning/DE Zoomcamp/week1_postgres/green_tripdata_2019-09.csv' DELIMITER ',' CSV HEADER;

    \COPY ny_taxi.nyc_taxi_zones FROM '/Users/olegd/Documents/Learning/DE Zoomcamp/week1_postgres/taxi+_zone_lookup.csv' DELIMITER ',' CSV HEADER;

### Execute SQL
    /* 	Question 3. Question 3. Count records
        How many taxi trips were totally made on September 18th 2019? */

    select count(*)
    from ny_taxi.nyc_green_taxi_trips ngtt 
    where ngtt.lpep_pickup_datetime::date  = '2019-09-18'
    and ngtt.lpep_dropoff_datetime::date = '2019-09-18';

    /* Question 4. Longest trip for each day
    * Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.
    */

    with dist as (
    select 
        lpep_pickup_datetime::date as dt,
        max(trip_distance) as max_dist
    from ny_taxi.nyc_green_taxi_trips ngtt 
    group by 1
    )
    select *
    from dist
    order by max_dist desc 
    limit 1;

    /* Question 5. Three biggest pick up Boroughs
    Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

    Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
    */

    select 
        ntz.borough ,
        sum(total_amount)
    from ny_taxi.nyc_green_taxi_trips ngtt 
    join ny_taxi.nyc_taxi_zones ntz  on (ngtt.pulocationid = ntz.locationid)
    where lpep_pickup_datetime ::date = '2019-09-18'
    and ntz.borough  != 'Unknown'
    group by 1
    having sum(total_amount) > 50000;

    /*
    * Question 6. Largest tip
    For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip? 
    We want the name of the zone, not the id.
    */

    select 
        ntz.zone,
        ntz2."zone",
        tip_amount 
    from ny_taxi.nyc_green_taxi_trips ngtt 
    join ny_taxi.nyc_taxi_zones ntz  on (ngtt.pulocationid = ntz.locationid)
    join ny_taxi.nyc_taxi_zones ntz2 on (ngtt.dolocationid = ntz2.locationid)
    where lpep_pickup_datetime ::date between '2019-09-01' and '2019-09-30'
    and  ntz."zone"  = 'Astoria'
    order by tip_amount  desc 
    limit 5;
