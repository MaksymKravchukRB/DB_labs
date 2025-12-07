Migration 1
(It didn't generate a migration folder, because it was the first time the migration command was run)

Added a new model: wishlist and modified user and product to support it


+  model wishlist {
+   wishlist_id Int      @id @default(autoincrement())
+   user_id     Int
+   product_id  Int
+   created_at  DateTime @default(now()) @db.Timestamptz(6)
+ 
+   user    user    @relation("UserWishlist", fields: [user_id], references: [user_id], onDelete: Cascade)
+   product product @relation("ProductWishlist", fields: [product_id], references: [product_id])
+ 
+   @@index([user_id])
+   @@index([product_id])
+ }

  model user {
   user_id          Int                @id @default(autoincrement())
   name             String             @db.VarChar(64)
   shipping_address String?            @db.VarChar(255)
   created_at       DateTime           @default(now()) @db.Timestamptz(6)
   billing_info     billing_info[]
   contact_data     contact_data[]
   product          product[]
   review           review[]
   user_transaction user_transaction[]
+  wishlist         wishlist[] @relation("UserWishlist")
 
   @@index([name], map: "idx_user_name")
  }


  model product {
   product_id   Int           @id @default(autoincrement())
   product_name String        @db.VarChar(128)
   price        Decimal       @db.Decimal(10, 2)
   seller_id    Int
   category_id  Int?
   description  String?
   is_active    Boolean?      @default(true)
   created_at   DateTime      @default(now()) @db.Timestamptz(6)
   category     category?     @relation(fields: [category_id], references: [category_id], onUpdate: NoAction)
   user         user          @relation(fields: [seller_id], references: [user_id], onDelete: Cascade, onUpdate: NoAction)
   review       review[]
   transaction  transaction[]
+  wishlist     wishlist[] @relation("ProductWishlist")
 
   @@index([category_id], map: "idx_product_category")
   @@index([price], map: "idx_product_price")
   @@index([seller_id], map: "idx_product_seller")
  }
 
 
Migration 2
modified review to rename "stars_amount" to "stars"


  model review {
   review_id          Int      @id @default(autoincrement())
-  stars_amount       Int?
+  stars              Int?
   review_title       String?  @db.VarChar(100)
   user_id            Int
   product_id         Int
   review_description String?
   created_at         DateTime @default(now()) @db.Time// renamed (previously stars_amount)stamptz(6)
   product            product  @relation(fields: [product_id], references: [product_id], onDelete: Cascade, onUpdate: NoAction)
   user               user     @relation(fields: [user_id], references: [user_id], onDelete: Cascade, onUpdate: NoAction)
 
   @@unique([user_id, product_id], map: "one_review_per_user_product")
   @@index([product_id], map: "idx_review_product")
   @@index([user_id], map: "idx_review_user")
  }

 
Migration 3
removed field "slug" from "category" model
 

 
  model category {
   category_id    Int        @id @default(autoincrement())
   name           String     @unique @db.VarChar(100)
-  slug           String?    @unique @db.VarChar(120)
   parent_id      Int?
   created_at     DateTime   @default(now()) @db.Timestamptz(6)
   category       category?  @relation("categoryTocategory", fields: [parent_id], references: [category_id], onUpdate: NoAction)
   other_category category[] @relation("categoryTocategory")
   product        product[]
 
   @@index([name], map: "idx_category_name")
  }

