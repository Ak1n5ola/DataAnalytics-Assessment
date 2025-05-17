SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(SUM(DISTINCT s.confirmed_amount), 0) AS savings_count,
    COALESCE(SUM(DISTINCT p.amount), 0) AS investments_count,
    COALESCE(SUM(DISTINCT s.confirmed_amount), 0) + COALESCE(SUM(DISTINCT p.amount), 0) AS total_deposits
FROM users_customuser AS u
JOIN savings_savingsaccount AS s ON s.owner_id = u.id
JOIN plans_plan p ON p.owner_id = u.id
WHERE s.transaction_status = 'success'
  AND p.status_id = 1
GROUP BY owner_id, name
ORDER BY total_deposits DESC;

-- The above query didn't run, the error most likey from the "sum(distinct...)" and join functions.
-- In light of this, I used "exists" to generate a new query.


SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    (   SELECT SUM(s.confirmed_amount)
        FROM savings_savingsaccount s
        WHERE s.owner_id = u.id AND s.transaction_status = 'success'
    )   AS savings_count,
    (   SELECT SUM(p.amount)
        FROM plans_plan p
        WHERE p.owner_id = u.id AND p.status_id = 1
    )   AS investments_count,
    (
    COALESCE(
            (
                SELECT SUM(s.confirmed_amount)
                FROM savings_savingsaccount s
                WHERE s.owner_id = u.id AND s.transaction_status = 'success'
            ), 0
        ) + 
        COALESCE(
            (
                SELECT SUM(p.amount)
                FROM plans_plan p
                WHERE p.owner_id = u.id AND p.status_id = 1
            ), 0
        )
    ) AS total_deposits
FROM users_customuser u
WHERE 
    EXISTS (
        SELECT 1 FROM savings_savingsaccount s 
        WHERE s.owner_id = u.id AND s.transaction_status = 'success'
    )
  AND EXISTS (
        SELECT 1 FROM plans_plan p 
        WHERE p.owner_id = u.id AND p.status_id = 1
    )
ORDER BY total_deposits DESC;
/*
After using both "joins" and "exists", both queries run but return no rows.
I changed the transaction status to "success". I ran the query and it returned rows. 
*\
