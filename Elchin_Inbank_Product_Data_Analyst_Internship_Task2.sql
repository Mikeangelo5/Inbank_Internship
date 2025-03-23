USE DATABASE INBANK_DB;

USE SCHEMA PUBLIC;

USE WAREHOUSE COMPUTE_WH;

--Snowflake SQL syntax

create or replace TABLE BLACKLIST (
	USER_ID NUMBER(38,0),
	BLACKLIST_CODE NUMBER(38,0),
	BLACKLIST_START_DATE DATE,
	BLACKLIST_END_DATE DATE
);

create or replace TABLE CURRENCIES (
	CURRENCY_ID NUMBER(38,0),
	CURRENCY_CODE VARCHAR(50),
	START_DATE DATE,
	END_DATE DATE
);

create or replace TABLE CURRENCY_RATES (
	CURRENCY_ID NUMBER(38,0),
	EXCHANGE_RATE_TO_EUR NUMBER(38,2),
	EXCHANGE_DATE DATE
);

create or replace TABLE PAYMENTS (
	USER_ID_SENDER NUMBER(38,0),
	CONTRACT_ID NUMBER(38,0),
	AMOUNT NUMBER(38,2),
	CURRENCY NUMBER(38,0),
	TRANSACTION_DATE DATE
);

INSERT INTO BLACKLIST (USER_ID,BLACKLIST_CODE,BLACKLIST_START_DATE,BLACKLIST_END_DATE) VALUES
	 (3837,101,'2022-01-01',NULL);
	
INSERT INTO CURRENCIES (CURRENCY_ID,CURRENCY_CODE,START_DATE,END_DATE) VALUES
	 (111,'EUR','1999-01-01',NULL),
	 (222,'PLN','1995-01-01',NULL),
	 (333,'CZK','1993-01-01',NULL),
	 (444,'HRK','1994-05-30','2022-12-31'),
	 (555,'YUM','1994-01-01','2003-01-01');
	
INSERT INTO CURRENCY_RATES (CURRENCY_ID,EXCHANGE_RATE_TO_EUR,EXCHANGE_DATE) VALUES
	 (222,0.19,'2023-01-05'),
	 (222,0.20,'2023-02-05'),
	 (222,0.21,'2023-03-05');

INSERT INTO PAYMENTS (USER_ID_SENDER,CONTRACT_ID,AMOUNT,CURRENCY,TRANSACTION_DATE) VALUES
	 (9863,786283,10,111,'2023-01-05'),
	 (7619,379828,34,111,'2023-01-05'),
	 (8472,367139,750,444,'2023-01-05'),
	 (9382,382033,378,222,'2023-01-05'),
	 (3837,789912,82,111,'2023-02-05'),
	 (9863,786283,19,111,'2023-02-05'),
	 (9382,382033,406,222,'2023-02-05'),
	 (9863,786283,53,111,'2023-03-05'),
	 (5673,372832,640,444,'2023-03-05'),
	 (7619,379828,34,111,'2023-03-05');
INSERT INTO PAYMENTS (USER_ID_SENDER,CONTRACT_ID,AMOUNT,CURRENCY,TRANSACTION_DATE) VALUES
	 (5321,466423,231,111,'2023-03-05');




WITH valid_currencies AS (
    SELECT currency_id, currency_code
    FROM currencies
    WHERE end_date IS NULL
),
payments_with_valid_currencies AS (
    SELECT 
        p.user_id_sender,
        p.contract_id,
        p.amount,
        p.currency AS currency_id,
        p.transaction_date,
        c.currency_code,
        b.user_id AS blacklist_user
    FROM payments p
    INNER JOIN valid_currencies c 
        ON p.currency = c.currency_id
    LEFT JOIN blacklist b 
        ON p.user_id_sender = b.user_id
        AND b.blacklist_end_date IS NULL
),
filtered_payments AS (
    SELECT *
    FROM payments_with_valid_currencies
    WHERE blacklist_user IS NULL
),
converted_payments AS (
    SELECT 
        fp.transaction_date,
        CASE 
            WHEN fp.currency_code = 'EUR' THEN fp.amount
            ELSE fp.amount * cr.exchange_rate_to_eur
        END AS amount_in_eur
    FROM filtered_payments fp
    LEFT JOIN currency_rates cr
        ON fp.currency_id = cr.currency_id
        AND fp.transaction_date = cr.exchange_date
)
SELECT 
    transaction_date,
    SUM(amount_in_eur) AS total_amount_eur
FROM converted_payments
GROUP BY transaction_date
ORDER BY transaction_date;
