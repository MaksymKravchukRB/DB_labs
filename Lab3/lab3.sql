BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('buyer', 'seller');
    END IF;
END$$;

-- CREATE TABLES


-- Users
CREATE TABLE IF NOT EXISTS "user" (
    user_id serial PRIMARY KEY,
    name varchar(64) NOT NULL,
    shipping_address varchar(255)
);

-- Contact data
CREATE TABLE IF NOT EXISTS contact_data (
    contact_id serial PRIMARY KEY,
    user_id int NOT NULL REFERENCES "user"(user_id),
    email varchar(32) UNIQUE NOT NULL,
    phone_number varchar(32) NOT NULL
);

-- Billing info
CREATE TABLE IF NOT EXISTS billing_info (
    billing_id serial PRIMARY KEY,
    user_id int NOT NULL REFERENCES "user"(user_id),
    card_number varchar(50) NOT NULL,
    billing_address varchar(255)
);

-- Product
CREATE TABLE IF NOT EXISTS product (
    product_id serial PRIMARY KEY,
    product_name varchar(32) NOT NULL,
    price numeric(10,2) NOT NULL CHECK (price >= 0),
    seller_id int NOT NULL REFERENCES "user"(user_id),
    category varchar(100),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Transactions
CREATE TABLE IF NOT EXISTS "transaction" (
    transaction_id serial PRIMARY KEY,
    product_id int NOT NULL REFERENCES product(product_id),
    price_at_sale numeric(10,2) NOT NULL CHECK (price_at_sale >= 0),
    transaction_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    payment_status varchar(50) NOT NULL,
    shipping_status varchar(50) NOT NULL
);

-- Reviews
CREATE TABLE IF NOT EXISTS review (
    review_id serial PRIMARY KEY,
    stars_amount INT CHECK (stars_amount BETWEEN 1 AND 5),
    review_title varchar(50) NOT NULL,
    user_id int NOT NULL REFERENCES "user"(user_id),
    product_id int NOT NULL REFERENCES product(product_id),
    review_description TEXT
);

-- User-transaction roles
CREATE TABLE IF NOT EXISTS user_transaction (
    user_transaction_id serial PRIMARY KEY,
    user_id int NOT NULL REFERENCES "user"(user_id),
    transaction_id int NOT NULL REFERENCES "transaction"(transaction_id),
    role user_role NOT NULL
);



-- INSERT DATA

INSERT INTO "user" (name, shipping_address) VALUES
('User1', 'Kyiv'),
('User2', 'Lviv'),
('User3', 'Odesa');


INSERT INTO contact_data (user_id, email, phone_number) VALUES
(1, 'u1@mail.com', '111-111'),
(2, 'u2@mail.com', '222-222'),
(3, 'u3@mail.com', '333-333');


INSERT INTO billing_info (user_id, card_number, billing_address) VALUES
(1, '1111-2222-3333-4444', 'Kyiv'),
(2, '5555-6666-7777-8888', 'Lviv'),
(3, '9999-0000-1111-2222', 'Odesa');


INSERT INTO product (product_name, price, seller_id, category, description) VALUES
('ItemA', 10.50, 1, 'Category1', 'Description A'),
('ItemB', 20.00, 2, 'Category1', 'Description B'),
('ItemC', 35.99, 3, 'Category2', 'Description C');


INSERT INTO "transaction" (product_id, price_at_sale, payment_status, shipping_status) VALUES
(1, 10.50, 'paid', 'shipped'),
(2, 20.00, 'pending', 'not shipped'),
(3, 35.99, 'paid', 'processing');


INSERT INTO review (stars_amount, review_title, user_id, product_id, review_description) VALUES
(5, 'Good', 1, 1, 'Nice product'),
(4, 'Okay', 2, 2, 'Works fine'),
(2, 'Bad', 3, 3, 'Not great');


INSERT INTO user_transaction (user_id, transaction_id, role) VALUES
(1, 1, 'buyer'),
(2, 2, 'buyer'),
(3, 3, 'buyer'),
(1, 1, 'seller'); -- product 1 is sold by user 1



-- SELECTION


-- Select all users
SELECT user_id, name, shipping_address FROM "user";

-- Select products with price > 15
SELECT product_name, price FROM product
WHERE price > 15;

-- JOIN: list products with seller name
SELECT p.product_name, p.price, u.name AS seller_name
FROM product p
JOIN "user" u ON p.seller_id = u.user_id;

-- Transactions with JOIN
SELECT t.transaction_id, p.product_name, t.payment_status
FROM "transaction" t
JOIN product p ON t.product_id = p.product_id
WHERE t.payment_status = 'paid';

-- Reviews with stars >= 4
SELECT review_title, stars_amount FROM review
WHERE stars_amount >= 4;


-- UPDATE


-- Update a product price
UPDATE product
SET price = 15.00
WHERE product_id = 1;

-- Update user shipping address
UPDATE "user"
SET shipping_address = 'Kharkiv'
WHERE user_id = 3;



-- DELETE


-- Delete a review
DELETE FROM review
WHERE review_id = 3;

-- Delete a billing entry
DELETE FROM billing_info
WHERE billing_id = 2;

