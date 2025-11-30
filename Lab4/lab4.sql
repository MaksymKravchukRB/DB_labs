-- 1. BASIC AGGREGATION


-- 1.1 Total number of lots
SELECT COUNT(*) AS total_lots
FROM lots;


-- 1.2 Max bid per lot
SELECT lot_id, MAX(amount) AS max_bid
FROM bids
GROUP BY lot_id;


-- 1.3 Average final price per category
SELECT c.name AS category, AVG(t.final_price) AS avg_final_price
FROM transactions t
JOIN lots l ON t.lot_id = l.id
JOIN categories c ON l.category_id = c.id
GROUP BY c.name;


-- 1.4 Count bids made by each user
SELECT bidder_id, COUNT(*) AS total_bids
FROM bids
GROUP BY bidder_id;




-- 2. GROUP BY + HAVING

-- 2.1 Categories with more than 3 lots
SELECT category_id, COUNT(*) AS lot_count
FROM lots
GROUP BY category_id
HAVING COUNT(*) > 3;



-- 3. JOIN EXAMPLES

-- 3.1 INNER JOIN: lots with seller names
SELECT l.id, l.title, u.username AS seller
FROM lots l
INNER JOIN users u ON l.seller_id = u.id;


-- 3.2 LEFT JOIN: all lots + number of bids
-- (including lots with zero bids)
SELECT l.id, l.title, COUNT(b.id) AS bids_count
FROM lots l
LEFT JOIN bids b ON b.lot_id = l.id
GROUP BY l.id;


-- 3.3 FULL JOIN: list all categories and all lots
-- even if some have no match
SELECT c.name AS category, l.title AS lot
FROM categories c
FULL JOIN lots l ON l.category_id = c.id;


-- 4. SUBQUERY EXAMPLES


-- 4.1 WHERE subquery:
-- lots where max bid > starting price
SELECT l.id, l.title
FROM lots l
WHERE (SELECT MAX(b.amount) FROM bids b WHERE b.lot_id = l.id)
      > l.start_price;


-- 4.2 SELECT subquery:
-- number of bids for each lot
SELECT
    l.id,
    l.title,
    (SELECT COUNT(*) FROM bids b WHERE b.lot_id = l.id) AS total_bids
FROM lots l;


-- 4.3 HAVING subquery:
-- sellers who earned more than 1000 total
SELECT seller_id, SUM(final_price) AS total_earned
FROM transactions
GROUP BY seller_id
HAVING SUM(final_price) > 1000;



-- 5. MULTI-TABLE AGGREGATION

-- 5.1 Total money spent by each buyer
SELECT u.id, u.username, SUM(t.final_price) AS total_spent
FROM users u
JOIN transactions t ON t.buyer_id = u.id
GROUP BY u.id, u.username
ORDER BY total_spent DESC;
