-- normalized_product.sql
-- Migration + final DDL for product normalization (category extraction)
-- Run in transaction; test on a copy first.

BEGIN;

-- 1) Create category table (new)
CREATE TABLE IF NOT EXISTS category (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    slug          VARCHAR(120) UNIQUE,
    parent_id     INT REFERENCES category(category_id) ON DELETE SET NULL
);

-- 2) Populate category table from existing product.category values
-- Only insert distinct non-null category names.
INSERT INTO category (name)
SELECT DISTINCT TRIM(category) AS name
FROM product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
ON CONFLICT (name) DO NOTHING;

-- 3) Add nullable category_id column to product
ALTER TABLE product
ADD COLUMN IF NOT EXISTS category_id INT NULL;

-- 4) Update product.category_id by joining on category.name
UPDATE product p
SET category_id = c.category_id
FROM category c
WHERE TRIM(COALESCE(p.category, '')) <> ''
  AND TRIM(p.category) = c.name;

-- 5) Add foreign key constraint (if not exists)
ALTER TABLE product
  ADD CONSTRAINT product_category_fk
  FOREIGN KEY (category_id) REFERENCES category(category_id)
  ON DELETE SET NULL;

-- 6) Optional: add index on product.category_id for queries
CREATE INDEX IF NOT EXISTS idx_product_category_id ON product(category_id);

-- 7) Keep original textual column for now (product.category)
--    After you verify correctness, drop the column:
-- ALTER TABLE product DROP COLUMN category;

-- 8) Ensure seller_id FK exists and cascades on delete for integrity (optional)
ALTER TABLE product
  DROP CONSTRAINT IF EXISTS product_seller_id_fkey;

ALTER TABLE product
  ADD CONSTRAINT product_seller_id_fkey
  FOREIGN KEY (seller_id) REFERENCES "user"(user_id)
  ON DELETE CASCADE;

COMMIT;
