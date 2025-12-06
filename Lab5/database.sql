-----------------------------
-- Cleanup (non-destructive on fresh DB)
-----------------------------
-- drop in dependency order
DROP TABLE IF EXISTS user_transaction CASCADE;
DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS "transaction" CASCADE;
DROP TABLE IF EXISTS billing_info CASCADE;
DROP TABLE IF EXISTS contact_data CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

DROP TYPE IF EXISTS user_role;

-----------------------------
-- ENUMS / TYPES
-----------------------------
-- simple enum for user roles in user_transaction table
CREATE TYPE user_role AS ENUM ('buyer', 'seller');

-----------------------------
-- TABLE: user
-----------------------------
CREATE TABLE "user" (
    user_id         SERIAL PRIMARY KEY,
    name            VARCHAR(64) NOT NULL,
    shipping_address VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-----------------------------
-- TABLE: contact_data
-- supports multiple contact records per user (email/phone pairs)
-----------------------------
CREATE TABLE contact_data (
    contact_id      SERIAL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    email           VARCHAR(320) NOT NULL,   -- RFC max length partial
    phone_number    VARCHAR(32) NOT NULL,
    is_primary      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT contact_unique_user_email UNIQUE(user_id, email)
);

CREATE INDEX IF NOT EXISTS idx_contact_user ON contact_data(user_id);

-----------------------------
-- TABLE: billing_info
-- supports multiple billing records per user
-----------------------------
CREATE TABLE billing_info (
    billing_id      SERIAL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    card_last4      CHAR(4) NOT NULL,                -- store only last4 for safety
    card_brand      VARCHAR(32),
    card_token      VARCHAR(255),                    -- tokenized card id (optional)
    billing_address VARCHAR(255),
    is_default      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_billing_user ON billing_info(user_id);

-----------------------------
-- TABLE: category (normalized)
-----------------------------
CREATE TABLE category (
    category_id     SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    slug            VARCHAR(120) UNIQUE,
    parent_id       INT REFERENCES category(category_id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_category_name ON category(name);

-----------------------------
-- TABLE: product (normalized)
-----------------------------
CREATE TABLE product (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(128) NOT NULL,
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    seller_id       INT NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    category_id     INT REFERENCES category(category_id) ON DELETE SET NULL,
    description     TEXT,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-----------------------------
-- TABLE: transaction
-- each row represents a completed sale (finalized)
-----------------------------
CREATE TABLE "transaction" (
    transaction_id      SERIAL PRIMARY KEY,
    product_id          INT NOT NULL REFERENCES product(product_id) ON DELETE RESTRICT,
    price_at_sale       NUMERIC(10,2) NOT NULL CHECK (price_at_sale >= 0),
    transaction_date    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status      VARCHAR(50) NOT NULL,
    shipping_status     VARCHAR(50) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tx_product ON "transaction"(product_id);
CREATE INDEX IF NOT EXISTS idx_tx_date ON "transaction"(transaction_date);

-----------------------------
-- TABLE: review
-- buyers can leave reviews for products
-----------------------------
CREATE TABLE review (
    review_id       SERIAL PRIMARY KEY,
    stars_amount    INT CHECK (stars_amount BETWEEN 1 AND 5),
    review_title    VARCHAR(100),
    user_id         INT NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    product_id      INT NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    review_description TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT one_review_per_user_product UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_review_product ON review(product_id);
CREATE INDEX IF NOT EXISTS idx_review_user ON review(user_id);

-----------------------------
-- TABLE: user_transaction
-- link table describing user role in a transaction (buyer or seller)
-----------------------------
CREATE TABLE user_transaction (
    user_transaction_id SERIAL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    transaction_id   INT NOT NULL REFERENCES "transaction"(transaction_id) ON DELETE CASCADE,
    role            user_role NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT user_tx_unique_role UNIQUE (user_id, transaction_id, role)
);

CREATE INDEX IF NOT EXISTS idx_user_transaction_user ON user_transaction(user_id);
CREATE INDEX IF NOT EXISTS idx_user_transaction_tx ON user_transaction(transaction_id);
