-- MICROSERVICE NOTE: instead of one `ClickNcart` database, each service
-- now gets its own database on this MySQL server. Nothing stops a service
-- from peeking into another service's database at the SQL level - the
-- separation is a *convention* each service's own code respects (each
-- service's application.properties only points at its own DB). That's
-- the honest, basic-level version of "database per service": logically
-- separate schemas, on a single shared MySQL pod for now. When you want to
-- go further, give each service its own MySQL Deployment + PVC instead.

CREATE DATABASE IF NOT EXISTS userdb;
CREATE DATABASE IF NOT EXISTS catalogdb;
CREATE DATABASE IF NOT EXISTS orderdb;

-- Each Spring Boot service creates its own tables automatically on first
-- boot (spring.jpa.hibernate.ddl-auto=update), so we don't need to define
-- table schemas here by hand - just seed catalogdb with starter products
-- so the app isn't empty on first run.

USE catalogdb;
CREATE TABLE IF NOT EXISTS product (
  id int NOT NULL AUTO_INCREMENT,
  category varchar(255) DEFAULT NULL,
  description varchar(255) DEFAULT NULL,
  image_url varchar(255) DEFAULT NULL,
  name varchar(255) DEFAULT NULL,
  price int NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO product (id, category, description, image_url, name, price) VALUES
(7,'Fruits','healthy fruit','https://cdn.dummyjson.com/product-images/groceries/kiwi/1.webp','Kiwi',250),
(8,'cosmetics','The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.','https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp','Essence Mascara',450),
(9,'cosmetics','The Red Lipstick is a classic and bold choice for adding a pop of color to your lips. With a creamy and pigmented formula, it provides a vibrant and long-lasting finish.','https://cdn.dummyjson.com/product-images/beauty/red-lipstick/1.webp','Red Lipstick',750),
(10,'Grocerry','Refreshing fruit juice, packed with vitamins and great for staying hydrated','https://cdn.dummyjson.com/product-images/groceries/juice/1.webp','Juice',150),
(11,'cosmetics','A versatile eyeshadow palette with a built-in mirror, great for on-the-go looks.','https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/1.webp','Eyeshadow Palette',380),
(12,'cosmetics','A finely milled setting powder for a smooth, matte finish that controls shine all day.','https://cdn.dummyjson.com/product-images/beauty/powder-canister/1.webp','Setting Powder',280),
(13,'cosmetics','A quick-drying red nail polish with a rich, glossy, salon-quality finish.','https://cdn.dummyjson.com/product-images/beauty/red-nail-polish/1.webp','Red Nail Polish',180),
(14,'Fragrance','CK One, a classic unisex fragrance known for its fresh, clean scent.','https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/1.webp','Calvin Klein CK One',950),
(15,'Fragrance','An elegant fragrance with notes of grapefruit, rose, and sandalwood - perfect for evenings.','https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/1.webp','Chanel Coco Noir',2400),
(16,'Fragrance','A luxurious floral fragrance blending ylang-ylang, rose, and jasmine.','https://cdn.dummyjson.com/product-images/fragrances/dior-j%27adore/1.webp','Dior J''adore',1700),
(17,'Furniture','A luxurious, elegant bed frame crafted with high-quality materials for the bedroom.','https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/1.webp','Annibale Colombo Bed',35000),
(18,'Furniture','A sophisticated, comfortable sofa with premium upholstery for the living room.','https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-sofa/1.webp','Annibale Colombo Sofa',45000),
(19,'Furniture','A stylish bedside table in African cherry finish, with convenient storage space.','https://cdn.dummyjson.com/product-images/furniture/bedside-table-african-cherry/1.webp','Bedside Table',5500),
(20,'Furniture','A modern, ergonomic executive conference chair with a timeless design.','https://cdn.dummyjson.com/product-images/furniture/knoll-saarinen-executive-conference-chair/1.webp','Executive Chair',9200),
(21,'Grocerry','Fresh and crisp apples, perfect for snacking or recipes.','https://cdn.dummyjson.com/product-images/groceries/apple/1.webp','Apple',80),
(22,'Grocerry','High-quality beef steak, great for grilling or your preferred cooking style.','https://cdn.dummyjson.com/product-images/groceries/beef-steak/1.webp','Beef Steak',650),
(23,'Grocerry','Fresh, tender chicken meat suitable for various culinary preparations.','https://cdn.dummyjson.com/product-images/groceries/chicken-meat/1.webp','Chicken Meat',420),
(24,'Grocerry','Versatile cooking oil suitable for frying, sauteing, and daily cooking.','https://cdn.dummyjson.com/product-images/groceries/cooking-oil/1.webp','Cooking Oil',220),
(25,'Grocerry','Pure, natural honey in a jar - great for sweetening drinks or drizzling on food.','https://cdn.dummyjson.com/product-images/groceries/honey-jar/1.webp','Honey Jar',320),
(26,'Fruits','Nutrient-rich kiwi with a tropical twist, perfect for snacking.','https://cdn.dummyjson.com/product-images/groceries/kiwi/1.webp','Kiwi (Pack of 4)',180)
ON DUPLICATE KEY UPDATE name=VALUES(name);
