CREATE TABLE tx_info_2023_Sep_10_to_15 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tx_hash VARCHAR(100),
    block_hash VARCHAR(100),
    ver INT,
    vin_sz INT,
    vout_sz INT,
    size INT,
    weight INT,
    fee FLOAT,
    relayed_by VARCHAR(20),
    lock_time INT,
    tx_index VARCHAR(20),
    double_spend VARCHAR(5),
    time BIGINT,
    block_index INT,
    block_height INT
);

LOAD DATA LOCAL INFILE '/home/training/Desktop/tx_info_2023_Sep_10_to_15.csv'
INTO TABLE tx_info_2023_Sep_10_to_15
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 

SELECT COUNT(*) FROM tx_info_2023_Sep_10_to_15;
SELECT * FROM tx_info_2023_Sep_10_to_15 LIMIT 10;

-- ==================================================================================================

CREATE TABLE blocks_info_2023_Sep_10_to_15(
    id INT AUTO_INCREMENT PRIMARY KEY,
    hash VARCHAR(64),
    ver INT,
    bits INT,
    fee INT,
    nonce INT,
    size INT,
    block_index INT,
    main_chain VARCHAR(5),
    height INT,
    weight INT
);

LOAD DATA LOCAL INFILE '/home/training/Desktop/blocks_info_2023_Sep_10_to_15.csv'
INTO TABLE blocks_info_2023_Sep_10_to_15
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 

SELECT COUNT(*) FROM blocks_info_2023_Sep_10_to_15;
SELECT * FROM blocks_info_2023_Sep_10_to_15 LIMIT 10;

-- ==================================================================================================
CREATE TABLE blocks_2023_Sep_10_to_15 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hash VARCHAR(64),
    time DATETIME,
    block_index INT
);

LOAD DATA LOCAL INFILE '/home/training/Desktop/blocks_2023_Sep_10_to_15.csv'
INTO TABLE blocks_2023_Sep_10_to_15
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 

SELECT COUNT(*) FROM blocks_2023_Sep_10_to_15;
SELECT * FROM blocks_2023_Sep_10_to_15 LIMIT 10;
-- ==================================================================================================

sqoop import \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--table tx_info_2023_Sep_10_to_15 \
--hive-import \
--hive-overwrite \
--hive-database hive_project \
--create-hive-table \
--hive-table tx_info_2023_Sep_10_to_15 \
--target-dir /user/training/tx_info_2023_Sep_10_to_15 \
-m 1

-- ==================================================================================================

sqoop import \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--table blocks_info_2023_Sep_10_to_15 \
--hive-import \
--hive-overwrite \
--hive-database hive_project \
--create-hive-table \
--hive-table blocks_info_2023_Sep_10_to_15 \
--target-dir /user/training/blocks_info_2023_Sep_10_to_15 \
-m 1
-- ==================================================================================================

sqoop import \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--table blocks_2023_Sep_10_to_15 \
--hive-import \
--hive-overwrite \
--hive-database hive_project \
--create-hive-table \
--hive-table blocks_2023_Sep_10_to_15 \
--target-dir /user/training/blocks_2023_Sep_10_to_15_new \
-m 1

-- ==================================================================================================
SELECT COUNT(*) FROM tx_info_2023_Sep_10_to_15;
SELECT * FROM tx_info_2023_Sep_10_to_15 LIMIT 10;

SELECT COUNT(*) FROM blocks_info_2023_Sep_10_to_15;
SELECT * FROM blocks_info_2023_Sep_10_to_15 LIMIT 10;

SELECT COUNT(*) FROM blocks_2023_Sep_10_to_15;
SELECT * FROM blocks_2023_Sep_10_to_15 LIMIT 10;

-- ==================================================================================================
sqoop eval \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--query "SELECT * FROM tx_info_2023_Sep_10_to_15 LIMIT 10"

sqoop eval \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--query "SELECT * FROM blocks_info_2023_Sep_10_to_15 LIMIT 10"

sqoop eval \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--query "SELECT * FROM blocks_2023_Sep_10_to_15 LIMIT 10"

-- ==================================================================================================

sqoop eval \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--query "SELECT COUNT(*) FROM tx_info_2023_Sep_10_to_15"

sqoop eval \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--query "SELECT COUNT(*) FROM blocks_info_2023_Sep_10_to_15"

sqoop eval \
--connect jdbc:mysql://localhost:3306/project \
--username training \
--password training \
--query "SELECT COUNT(*) FROM blocks_2023_Sep_10_to_15"



-- ==================================================================================================

SELECT COUNT(DISTINCT(block_index)) FROM blocks_2023_Sep_10_to_15;

SELECT MAX(block_height) FROM blocks_2023_Sep_10_to_15;

SELECT blocks_info_2023_Sep_10_to_15.hash, MAX(height) 
FROM blocks_info_2023_Sep_10_to_15
INNER JOIN blocks_2023_Sep_10_to_15 ON blocks_info_2023_Sep_10_to_15.hash = blocks_2023_Sep_10_to_15.hash
GROUP BY blocks_info_2023_Sep_10_to_15.hash;

SELECT bi.hash, MAX(bi.height) AS max_height
FROM blocks_info_2023_Sep_10_to_15 bi
INNER JOIN blocks_2023_Sep_10_to_15 b ON bi.hash = b.hash
GROUP BY bi.hash
ORDER BY max_height DESC
LIMIT 1;


WITH t1 AS (
    SELECT bi.hash AS max_hash, MAX(bi.height) AS max_height
    FROM blocks_info_2023_Sep_10_to_15 bi
    INNER JOIN blocks_2023_Sep_10_to_15 b ON bi.hash = b.hash
    GROUP BY bi.hash
    ORDER BY max_height DESC
    LIMIT 1
)
SELECT b.hash, CAST(b.time AS TIMESTAMP)
FROM blocks_2023_Sep_10_to_15 b
JOIN t1
ON b.hash = t1.max_hash;




SELECT DISTINCT(tx_info_2023_Sep_10_to_15.block_hash), CAST(blocks_2023_Sep_10_to_15.time AS TIMESTAMP)
FROM blocks_2023_Sep_10_to_15 
LEFT JOIN tx_info_2023_Sep_10_to_15 
ON blocks_2023_Sep_10_to_15.hash = tx_info_2023_Sep_10_to_15.block_hash
WHERE tx_info_2023_Sep_10_to_15.block_height IN 
    (SELECT MAX(block_height) FROM tx_info_2023_Sep_10_to_15);



