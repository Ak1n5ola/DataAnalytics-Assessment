SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(ssa.id) AS total_transactions,
    (COUNT(ssa.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (0.001 * AVG(ssa.amount)) AS estimated_clv
FROM
    users_customuser u
LEFT JOIN
    savings_savingsaccount ssa ON u.id = ssa.owner_id
GROUP BY
    u.id, u.first_name, u.last_name, u.date_joined
ORDER BY
    estimated_clv DESC;
