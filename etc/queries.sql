-- _*_ sql-product: mysql _*_

-- average win price
SELECT AVG(price)/1000 FROM winnotices;
SELECT AVG(price)/1000 FROM winnotices GROUP BY sponsor_id;

-- average bid price
SELECT AVG(price)/1000 FROM bids;
SELECT AVG(price)/1000 FROM bids GROUP BY sponsor_id;

-- CTR
SELECT COUNT(*) / t.cnt FROM winnotices CLOSS
JOIN (SELECT COUNT(*) cnt from winnotices) t
WHERE is_click = TRUE;

SELECT COUNT(*) / t.cnt FROM winnotices w
LEFT JOIN (SELECT COUNT(*) cnt, sponsor_id FROM winnotices GROUP BY sponsor_id) t
       ON w.sponsor_id = t.sponsor_id
WHERE is_click = TRUE
GROUP BY w.sponsor_id;


-- win rate
SELECT COUNT(*) / t.cnt FROM winnotices
CLOSS JOIN (SELECT COUNT(*) cnt FROM bids) t;

SELECT COUNT(*) / t.cnt FROM winnotices w
LEFT JOIN (SELECT COUNT(*) cnt, sponsor_id FROM bids GROUP BY sponsor_id) t
       ON w.sponsor_id = t.sponsor_id
GROUP BY w.sponsor_id;

-- erning, profit, profit per imp
SELECT SUM(ering) erning, SUM(t.profit) profit, SUM(t.profit) / (SELECT COUNT(*) FROM winnotices) profit_per_imp FROM
(SELECT cpc * COUNT(*) ering, cpc * COUNT(*) - p.s profit FROM winnotices w
LEFT JOIN budgets b
       ON b.sponsor_id = w.sponsor_id
LEFT JOIN (SELECT SUM(price) / 1000 s, sponsor_id FROM winnotices GROUP BY sponsor_id) p
       ON p.sponsor_id = w.sponsor_id
WHERE is_click = TRUE
GROUP BY w.sponsor_id) t;


SELECT w.sponsor_id, cpc * COUNT(*) erning, cpc * COUNT(*) - p.s profit, (cpc * COUNT(*) - p.s)/ p.cnt profit_per_imp FROM winnotices w
LEFT JOIN budgets b
       ON b.sponsor_id = w.sponsor_id
LEFT JOIN (SELECT SUM(price) / 1000 s, sponsor_id, COUNT(*) cnt  FROM winnotices GROUP BY sponsor_id) p
       ON p.sponsor_id = w.sponsor_id
WHERE is_click = TRUE
GROUP BY w.sponsor_id;

-- click count, max click count
SELECT COUNT(*) , b.budget / b.cpc FROM winnotices w
LEFT JOIN budgets b
       ON b.sponsor_id = w.sponsor_id
WHERE is_click = TRUE
GROUP BY w.sponsor_id;
