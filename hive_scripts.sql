CREATE DATABASE IF NOT EXISTS stock_database;

SHOW DATABASES;

USE stock_database;

CREATE TABLE IF NOT EXISTS stocks (
    Symbol STRING,
    Date STRING,
    Open FLOAT,
    High FLOAT,
    Low FLOAT,
    Close FLOAT,
    Volume INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Insert default values into the new table
INSERT INTO TABLE stocks 
SELECT 
    COALESCE(Symbol, 'NA') as Symbol,
    COALESCE(Date, '1970-01-01 00:00:00') as Date,
    COALESCE(Open, 0.0) as Open,
    COALESCE(High, 0.0) as High,
    COALESCE(Low, 0.0) as Low,
    COALESCE(Close, 0.0) as Close,
    COALESCE(Volume, 0) as Volume
FROM stocks;


SHOW TABLES;

hdfs dfs -mkdir /project_execute/flume/hive

hdfs dfs -chmod 777 /project_execute/flume/hive

hdfs dfs -put /home/training/project/flume/hive/output_data.csv /project_execute/flume/hive

hdfs dfs -ls /project_execute/flume/hive

LOAD DATA INPATH '/project_execute/flume/hive/output_data.csv' OVERWRITE INTO TABLE stocks;

--analytics

--a
SELECT COUNT(*) AS record_count FROM stocks;

--b
SELECT COUNT(DISTINCT Date) AS unique_days_count FROM stocks;

--c
SELECT `date`, COUNT(*) AS record_count_per_day FROM stocks GROUP BY `date`;

--d
SELECT DISTINCT Symbol FROM stocks;

--e
SELECT Symbol, MAX(High) AS highest_price FROM stocks GROUP BY Symbol;

--f
SELECT Symbol, MIN(Low) AS lowest_price FROM stocks GROUP BY Symbol;

--g
SELECT Symbol, AVG((High + Low) / 2) AS average_price FROM stocks GROUP BY Symbol;

--h
SELECT Symbol, MAX(High),MIN(Low), MAX(High)- MIN(Low) FROM stocks GROUP BY Symbol;

--i
SELECT Symbol, Date, High
FROM (
    SELECT Symbol, Date, High,
           ROW_NUMBER() OVER (PARTITION BY Symbol ORDER BY High DESC) AS rank
    FROM stocks
) ranked
WHERE rank = 1;