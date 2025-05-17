    SELECT
    sub.plan_id, 
    sub.owner_id,
    sub.account_type,
    sub.last_transaction,
    DATEDIFF(CURDATE(), sub.last_transaction) AS inactivity_days
FROM (
    SELECT
        pp.id AS plan_id,  
        pp.owner_id,
        'investment' AS account_type,
        MAX(pp.last_charge_date) AS last_transaction
    FROM
        plans_plan pp
    WHERE
        pp.status_id = 1
        AND pp.last_charge_date IS NOT NULL
    GROUP BY
        pp.id, pp.owner_id

    UNION ALL

    SELECT
        ssa.plan_id,  
        ssa.owner_id,
        'savings' AS account_type,
        MAX(ssa.transaction_date) AS last_transaction
    FROM
        savings_savingsaccount ssa
    WHERE
        ssa.transaction_status != 'closed'
        AND ssa.transaction_date IS NOT NULL
    GROUP BY
        ssa.plan_id, ssa.owner_id
) AS sub
WHERE
    sub.last_transaction < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY
    sub.last_transaction;
