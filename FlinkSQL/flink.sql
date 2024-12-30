-- Create Purchases Table
CREATE TABLE
    purchases (
        id INT,
        item_type STRING,
        quantity INT,
        price_per_unit DOUBLE,
        ts TIMESTAMP_LTZ (3) METADATA
        FROM
            'timestamp'
    )
WITH
    (
        'connector' = 'kafka',
        'topic' = 'purchases',
        'scan.startup.mode' = 'earliest-offset',
        'properties.bootstrap.servers' = 'broker:29092',
        'format' = 'json'
    );

-- Create Transactions Table
CREATE TABLE
    transactions (
        transaction_id INT,
        card_id INT,
        user_id STRING,
        purchase_id INT,
        store_id INT,
        ts TIMESTAMP_LTZ (3) METADATA
        FROM
            'timestamp'
    )
WITH
    (
        'connector' = 'kafka',
        'topic' = 'transactions',
        'scan.startup.mode' = 'earliest-offset',
        'properties.bootstrap.servers' = 'broker:29092',
        'format' = 'json'
    );

-- Output to store data after joining the Purchases and Transactions tables
CREATE TABLE
    purchases_transactions (
        purchase_id INT,
        item_type STRING,
        quantity INT,
        price_per_unit DOUBLE,
        transaction_id INT,
        user_id STRING,
        card_id INT,
        store_id INT
    )
WITH
    (
        'connector' = 'kafka',
        'topic' = 'purchases-transactions-topic', -- Output Kafka topic
        'properties.bootstrap.servers' = 'broker:29092',
        'format' = 'json',
        'properties.group.id' = 'purchases_transactions_group', -- to track the offset
        'scan.startup.mode' = 'latest-offset'
    );

-- Create table to store total transaction amount for each transaction
CREATE TABLE
    total_transaction_amount (
        transaction_id INT,
        total_amount DOUBLE,
        PRIMARY KEY (transaction_id) NOT ENFORCED
    )
WITH
    (
        'connector' = 'upsert-kafka', -- Using upsert-kafka connector
        'topic' = 'total-transaction-amount', -- Output Kafka topic
        'properties.bootstrap.servers' = 'broker:29092',
        'key.format' = 'json',
        'value.format' = 'json'
    );

-- Execute the following SQL statement to calculate the total transaction amount 
-- for each transaction and insert the data into the total_transaction_amount table
INSERT INTO
    purchases_transactions
SELECT
    purchases.id AS purchase_id,
    purchases.item_type,
    purchases.quantity,
    purchases.price_per_unit,
    transactions.transaction_id,
    transactions.user_id,
    transactions.card_id,
    transactions.store_id
FROM
    purchases
    INNER JOIN transactions ON purchases.id = transactions.purchase_id;

-- Insert data into the total_transaction_amount table
INSERT INTO
    total_transaction_amount
SELECT
    transaction_id,
    SUM(quantity * price_per_unit) AS total_amount
FROM
    purchases_transactions
GROUP BY
    transaction_id;