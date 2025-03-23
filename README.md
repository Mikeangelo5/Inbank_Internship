# Task 2 – Data Analyst Intern Assignment (Inbank)

## 📌 Task Objective

Write a SQL query that calculates the **sum of payment amounts (converted to EUR)** for each transaction date. The goal is to:

- Exclude blacklisted users
- Ignore discontinued currencies
- Convert amounts using the correct exchange rates

---

## 🧠 Query Logic Summary

1. **Filter out discontinued currencies**  
   - Currencies where `end_date IS NOT NULL` are excluded.

2. **Exclude blacklisted users**  
   - If a user is on the blacklist and their `blacklist_end_date` is `NULL` or in the future, their payments are ignored.

3. **Convert non-EUR currencies to EUR**  
   - Payments in currencies other than 'EUR' are multiplied by the appropriate exchange rate from the `currency_rates` table, based on the matching `exchange_date`.

4. **Group the total EUR value by transaction date**

---

## 🧱 Tables Used

- `payments`: Contains individual payment transactions.
- `currencies`: Maps currency IDs to codes and lifecycle periods.
- `currency_rates`: Holds daily exchange rates to EUR.
- `blacklist`: Contains blacklisted users with time periods.

---

## ✅ Output Columns

| Column             | Description                                      |
|--------------------|--------------------------------------------------|
| `transaction_date` | The date of the transaction                     |
| `total_amount_eur` | The sum of all valid payments converted to EUR  |

---

## 🛠️ Tools Used

- **SQL** (compatible with **Snowflake**)
- Tested inside the Snowflake UI
- Uses **CTEs** to separate filtering logic for better readability

---

## 📂 Files

- `task_2_solution.sql` – final SQL query with full logic
- `README.md` – this file

---

## 📈 Example Use Case

This logic could be used by Inbank's data analysts or risk/fraud teams to:

- Analyze volume of valid transactions in EUR
- Detect gaps or anomalies in exchange rate application
- Prepare finance-level reporting of cross-border payment flows

---

## 📣 Note

If you're using **Snowflake**, make sure your table names and casing match exactly (e.g., `currency_rates` vs `CURRENCY_RATES`).

