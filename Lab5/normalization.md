# Lab 5 — Normalization (table: product)

## 1. Original table (as in DB)
Table: product
Columns:
- product_id (PK)
- product_name
- price
- seller_id (FK -> "user"(user_id))
- category         -- free-text category name
- description
- is_active

DDL snippet (original):
CREATE TABLE IF NOT EXISTS product (
    product_id serial PRIMARY KEY,
    product_name varchar(32) NOT NULL,
    price numeric(10,2) NOT NULL CHECK (price >= 0),
    seller_id int NOT NULL REFERENCES "user"(user_id),
    category varchar(100),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

## 2. Functional dependencies (minimal set)
We assume product_id uniquely identifies a product row.

FDs:
1. product_id -> product_name, price, seller_id, category, description, is_active
   (product_id is the primary key)

Other possible FDs to consider (based on business rules; *not* assumed unless stated):
- (seller_id, product_name) -> product_id  (only if seller can't list same product_name twice) — NOT assumed.
- category -> (nothing else in product) — category is just a label in original design.

Thus minimal and safe FD set for current design:
- product_id -> product_name
- product_id -> price
- product_id -> seller_id
- product_id -> category
- product_id -> description
- product_id -> is_active

## 3. Check normal forms for original product table

### 1NF (atomicity)
- All attributes atomic (varchar, numeric, boolean, text) — **passes 1NF**.
- No repeating groups present in product table — OK.

### 2NF (partial dependency)
- Primary key is single attribute (product_id). With a single-attribute PK, partial dependencies are impossible.
- Therefore **passes 2NF**.

### 3NF (no transitive dependencies)
- We must ensure no non-key attribute depends on another non-key attribute.
- Problem: `category` is a free-text attribute repeated across many products. If later we attach more attributes to a category (e.g., category_description, parent_category), then `product.category` would produce transitive redundancy if we duplicated those attributes in product. Even as plain text, repeating the category string violates normalization *by redundancy* (not strictly a transitive FD within product alone) and makes updates error-prone (category renames).
- For practical normalization to 3NF we should move category to its own relation.

Conclusion:
- Original table is formally in 3NF if category has no dependent attributes. But because `category` is repeated text (and likely to evolve into an entity with attributes), we will **refactor** it into a `category` table to remove redundancy and prepare for future attributes.
- This change both reduces redundancy and ensures correct 3NF when categories have attributes.

## 4. Normalization steps & rationale

### Step 0 — Starting point (original)
product(product_id PK, product_name, price, seller_id, category, description, is_active)

Problem:
- `category` is textual and repeated; renaming a category requires updating many product rows → update anomaly.
- No canonical place to store category metadata (id, slug, parent etc.).

### Step 1 — 1NF
- Ensure atomicity: nothing to change (all attributes atomic). product remains the same.

### Step 2 — Move category into its own table (resolve redundancy)
We create:
- category(category_id PK, name UNIQUE, slug OPTIONAL, parent_id NULLABLE FK -> category(category_id))
- product.category_id -> FK category(category_id)

Rationale:
- Move repeated `category` strings into a single place.
- Allows adding category attributes later without repetition (e.g., `display_order`, `description`, `parent_id`).

Effect on FDs:
- New FDs:
  - category_id -> name, slug, parent_id
  - product_id -> product_name, price, seller_id, category_id, description, is_active

After decomposition product becomes:
product(product_id PK, product_name, price, seller_id, category_id FK, description, is_active)

This decomposition preserves information and eliminates category duplication.

### Step 3 — 3NF check after decomposition
- product: PK = product_id (single attribute). No non-key attribute determines another non-key attribute (seller_id is an FK but we don't store seller data in product). Good — **product is in 3NF**.
- category: PK = category_id. Non-key attributes (name, slug, parent_id) should not transitively depend on category_id — they don't. **category is in 3NF**.

## 5. Final table designs (3NF)

### category
- category_id  serial PRIMARY KEY
- name         varchar(100) NOT NULL UNIQUE
- slug         varchar(120) UNIQUE NULL
- parent_id    int NULL REFERENCES category(category_id) ON DELETE SET NULL

### product (normalized)
- product_id   serial PRIMARY KEY
- product_name varchar(32) NOT NULL
- price        numeric(10,2) NOT NULL CHECK (price >= 0)
- seller_id    int NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE
- category_id  int NULL REFERENCES category(category_id) ON DELETE SET NULL
- description  TEXT
- is_active    BOOLEAN DEFAULT TRUE

## 6. Migration plan (data-preserving SQL strategy)
1. Create category table.
2. Insert distinct categories from product.category into category table.
3. Add product.category_id nullable column.
4. Update product.category_id using mapping from category.name.
5. Add FK constraint.
6. Drop product.category column (optional after verification).
7. Add indexes and constraints.

## 7. ALTER/CREATE SQL and migration script
See `normalized_product.sql` (attached separately / below).

## 8. Verification queries (examples)
- Check categories created:
  SELECT * FROM category;
- Check product rows map to category:
  SELECT p.product_id, p.product_name, c.name
  FROM product p
  LEFT JOIN category c ON p.category_id = c.category_id;
- Confirm no category column left:
  \d product

## 9. Summary
- Minimal change focused only on `product`.
- Eliminated category text duplication by introducing `category` table.
- Resulting schema places `product` and `category` into 3NF.
- Migration script is data-preserving and reversible (until final drop of `product.category`).

