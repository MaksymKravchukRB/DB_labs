DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('buyer', 'seller');
    END IF;
END$$;


CREATE TABLE IF NOT EXISTS "user" (
    user_id serial PRIMARY KEY,
    name varchar(64) NOT NULL,
    shipping_address varchar(255)
);

CREATE TABLE IF NOT EXISTS contact_data (
    contact_id serial PRIMARY KEY,
    user_id int not null references "user"(user_id),
    email varchar(32) UNIQUE NOT NULL,
    phone_number varchar(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS billing_info (
    billing_id serial PRIMARY KEY,
    user_id int not null references "user"(user_id),
    card_number varchar(50) NOT NULL,
    billing_address varchar(255)
);

CREATE TABLE IF NOT EXISTS product (
    product_id serial PRIMARY KEY,
    product_name varchar(32) NOT NULL,
    price numeric(10,2) NOT NULL CHECK(price >= 0),
    seller_id int not null references "user"(user_id),
    category varchar(100),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS "transaction" (
    transaction_id serial PRIMARY KEY,
    product_id int not null references product(product_id),
    price_at_sale numeric(10,2) NOT NULL CHECK(price_at_sale >= 0),
    transaction_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    payment_status varchar(50) NOT NULL,
    shipping_status varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS review (
    review_id serial PRIMARY KEY,
    stars_amount INT CHECK(stars_amount BETWEEN 1 AND 5),
    review_title varchar(50) NOT NULL,
    user_id int not null references "user"(user_id),
    product_id int not null references product(product_id),
    review_description TEXT
);

CREATE TABLE IF NOT EXISTS user_transaction (
    user_transaction_id serial PRIMARY KEY,
    user_id int not null references "user"(user_id),
    transaction_id int not null references "transaction"(transaction_id),
    role user_role NOT NULL
);