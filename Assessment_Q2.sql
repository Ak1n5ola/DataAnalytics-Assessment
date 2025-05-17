WITH txn_summary AS (
    SELECT 
        u.id AS user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        COUNT(s.id) AS total_transactions,
        ROUND(
            COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1, 1),
            2
        ) AS avg_txn_per_month
    FROM users_customuser u
    JOIN savings_savingsaccount s ON s.owner_id = u.id
    WHERE s.transaction_status = 'success'
      AND s.transaction_date IS NOT NULL
    GROUP BY u.id, name
)

SELECT 
    CASE
        WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
        WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transaction_per_month
FROM txn_summary
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
