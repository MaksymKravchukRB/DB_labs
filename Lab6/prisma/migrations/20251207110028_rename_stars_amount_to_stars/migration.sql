-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('buyer', 'seller');

-- CreateTable
CREATE TABLE "wishlist" (
    "wishlist_id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "wishlist_pkey" PRIMARY KEY ("wishlist_id")
);

-- CreateTable
CREATE TABLE "billing_info" (
    "billing_id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "card_last4" CHAR(4) NOT NULL,
    "card_brand" VARCHAR(32),
    "card_token" VARCHAR(255),
    "billing_address" VARCHAR(255),
    "is_default" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "billing_info_pkey" PRIMARY KEY ("billing_id")
);

-- CreateTable
CREATE TABLE "category" (
    "category_id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(120),
    "parent_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "category_pkey" PRIMARY KEY ("category_id")
);

-- CreateTable
CREATE TABLE "contact_data" (
    "contact_id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "phone_number" VARCHAR(32) NOT NULL,
    "is_primary" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contact_data_pkey" PRIMARY KEY ("contact_id")
);

-- CreateTable
CREATE TABLE "product" (
    "product_id" SERIAL NOT NULL,
    "product_name" VARCHAR(128) NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "seller_id" INTEGER NOT NULL,
    "category_id" INTEGER,
    "description" TEXT,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "product_pkey" PRIMARY KEY ("product_id")
);

-- CreateTable
CREATE TABLE "review" (
    "review_id" SERIAL NOT NULL,
    "stars" INTEGER,
    "review_title" VARCHAR(100),
    "user_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "review_description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_pkey" PRIMARY KEY ("review_id")
);

-- CreateTable
CREATE TABLE "transaction" (
    "transaction_id" SERIAL NOT NULL,
    "product_id" INTEGER NOT NULL,
    "price_at_sale" DECIMAL(10,2) NOT NULL,
    "transaction_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "payment_status" VARCHAR(50) NOT NULL,
    "shipping_status" VARCHAR(50) NOT NULL,

    CONSTRAINT "transaction_pkey" PRIMARY KEY ("transaction_id")
);

-- CreateTable
CREATE TABLE "user" (
    "user_id" SERIAL NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "shipping_address" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "user_transaction" (
    "user_transaction_id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "transaction_id" INTEGER NOT NULL,
    "role" "user_role" NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_transaction_pkey" PRIMARY KEY ("user_transaction_id")
);

-- CreateIndex
CREATE INDEX "wishlist_user_id_idx" ON "wishlist"("user_id");

-- CreateIndex
CREATE INDEX "wishlist_product_id_idx" ON "wishlist"("product_id");

-- CreateIndex
CREATE INDEX "idx_billing_user" ON "billing_info"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "category_name_key" ON "category"("name");

-- CreateIndex
CREATE UNIQUE INDEX "category_slug_key" ON "category"("slug");

-- CreateIndex
CREATE INDEX "idx_category_name" ON "category"("name");

-- CreateIndex
CREATE INDEX "idx_contact_user" ON "contact_data"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "contact_unique_user_email" ON "contact_data"("user_id", "email");

-- CreateIndex
CREATE INDEX "idx_product_category" ON "product"("category_id");

-- CreateIndex
CREATE INDEX "idx_product_price" ON "product"("price");

-- CreateIndex
CREATE INDEX "idx_product_seller" ON "product"("seller_id");

-- CreateIndex
CREATE INDEX "idx_review_product" ON "review"("product_id");

-- CreateIndex
CREATE INDEX "idx_review_user" ON "review"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "one_review_per_user_product" ON "review"("user_id", "product_id");

-- CreateIndex
CREATE INDEX "idx_tx_date" ON "transaction"("transaction_date");

-- CreateIndex
CREATE INDEX "idx_tx_product" ON "transaction"("product_id");

-- CreateIndex
CREATE INDEX "idx_user_name" ON "user"("name");

-- CreateIndex
CREATE UNIQUE INDEX "user_tx_unique_role" ON "user_transaction"("user_id", "transaction_id", "role");

-- AddForeignKey
ALTER TABLE "wishlist" ADD CONSTRAINT "wishlist_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wishlist" ADD CONSTRAINT "wishlist_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "billing_info" ADD CONSTRAINT "billing_info_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "category" ADD CONSTRAINT "category_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "category"("category_id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "contact_data" ADD CONSTRAINT "contact_data_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("category_id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_seller_id_fkey" FOREIGN KEY ("seller_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "transaction" ADD CONSTRAINT "transaction_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "user_transaction" ADD CONSTRAINT "user_transaction_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "transaction"("transaction_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "user_transaction" ADD CONSTRAINT "user_transaction_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;
