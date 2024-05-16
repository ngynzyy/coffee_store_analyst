WITH rfm_cal AS (SELECT 
  customer_id
  ,DATE_DIFF((SELECT MAX(transaction_date) FROM `valued-plane-361602.study.sales`), MAX(transaction_date), DAY)  AS Recency
  ,COUNT(DISTINCT transaction_id) Frequency
  ,ROUND(SUM(quantity_sold*unit_price),2) Monetary
FROM sales
GROUP BY 1
)

,rfm_score AS(SELECT * 
  ,NTILE(4) OVER(ORDER BY Recency DESC) R_Score
  ,NTILE(4) OVER(ORDER BY Frequency ASC) F_Score
  ,NTILE(4) OVER(ORDER BY Monetary ASC) M_Score
FROM rfm_cal)

,rfm_table AS (
SELECT *, CONCAT(R_Score, F_Score, M_Score) RFM_Score
FROM rfm_score)

SELECT 
    *
    ,CASE 
        WHEN REGEXP_CONTAINS(RFM_Score, r'^[3-4][3-4][3-4]$') THEN 'Loyal'
        WHEN REGEXP_CONTAINS(RFM_Score, r'^[3-4][3-4][1-2]$') THEN 'Promising'
        WHEN REGEXP_CONTAINS(RFM_Score, r'^[3-4][1-2]4$') THEN 'Big Spenders'
        WHEN REGEXP_CONTAINS(RFM_Score, r'^[3-4][1-2].$') THEN 'New Customers'
        WHEN REGEXP_CONTAINS(RFM_Score, r'^2..$') THEN 'Potential Churn'
        WHEN REGEXP_CONTAINS(RFM_Score, r'^1..$') THEN 'Lost'
    END AS Segmentation
FROM rfm_table;