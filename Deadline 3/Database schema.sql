-- QuickCart : An Online Retail Store --> Database schema with integrity constraints and data insertion

CREATE DATABASE IF NOT EXISTS QuickCart;
USE QuickCart;
-- DROP DATABASE QuickCart; 

-- Customer table 
CREATE TABLE IF NOT EXISTS customer (
	customerID INT AUTO_INCREMENT PRIMARY KEY, 
    first_name VARCHAR(50) NOT NULL, -- name is a composite attribute having first_name & last_name
    last_name VARCHAR(50),
    address_street VARCHAR(100) NOT NULL, -- address is a composite attribute having street, city, state & pincode
	address_city VARCHAR(50) NOT NULL,
	address_state VARCHAR(50) NOT NULL,
    pincode INT NOT NULL,
    phone_no BIGINT UNIQUE NOT NULL, -- int not sufficient for 10 digits
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    dob DATE,
    age INT, -- Age is derived from DateOfBirth
    gender VARCHAR(10)
);

-- Update the Age column based on DateOfBirth -- Age is a derived attribute in our DB
SET SQL_SAFE_UPDATES = 0; -- safe mode OFF
UPDATE Customer
SET age = DATEDIFF(CURDATE(), dob) / 365;

-- Admin table
CREATE TABLE IF NOT EXISTS admin (
	adminID INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(50) NOT NULL
);

-- Product Category table
CREATE TABLE IF NOT EXISTS productCategory (
	categoryID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    noOfProducts BIGINT NOT NULL DEFAULT 0
);

-- Product table
CREATE TABLE IF NOT EXISTS product (
	productID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    brand VARCHAR(50) NOT NULL,
    qty_bought INT NOT NULL DEFAULT 0,
    description VARCHAR(200) NOT NULL DEFAULT "A high-quality product.", -- TEXT doesn't have default value
    categoryID INT NOT NULL, -- not null --> every product must belong to some category
    FOREIGN KEY (categoryID) REFERENCES productCategory(categoryID) ON DELETE CASCADE 
    ON UPDATE CASCADE
    -- represents "falls under" relationship & product gets deleted, updated when category is changed
);

-- Delivery Agent table
CREATE TABLE IF NOT EXISTS deliveryAgent (
	agentID INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    availabilityStatus VARCHAR(20) NOT NULL DEFAULT "Offline", -- 'Available', 'Busy', 'Offline'
    phone_no BIGINT UNIQUE NOT NULL, -- int not sufficient for 10 digits
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);

-- Store table
CREATE TABLE IF NOT EXISTS store (
	storeID INT AUTO_INCREMENT PRIMARY KEY,
    address_street VARCHAR(100) NOT NULL, -- address is a composite attribute having street, city, state & pincode
    address_city VARCHAR(50) NOT NULL,
    address_state VARCHAR(50) NOT NULL,
    pincode INT NOT NULL
);

-- Order table
CREATE TABLE IF NOT EXISTS `order` (
	orderID INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(20) NOT NULL DEFAULT "Confirmed", -- 'Comfirmed', 'Packed', 'Shipped', 'Delivered'
    total_price DECIMAL(10, 2) NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(255) NOT NULL,
    customerID INT NOT NULL,
    agentID INT NOT NULL,
    FOREIGN KEY (customerID) REFERENCES customer(customerID), -- represents Customer “places” Order relationship
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) -- represents Order “fulfilled by” DeliveryAgent relationship
);

-- Weak Entities :-

-- Wallet table
CREATE TABLE IF NOT EXISTS wallet (
	customerID INT NOT NULL,
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (balance>=0),
    upiID VARCHAR(100) NOT NULL,
    rewardPoints INT NOT NULL DEFAULT 0,
    FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE 
    -- represents Wallet “Belongs to” Customer identifying relationship & wallet gets deleted when customer deleted
);
-- DROP TABLE wallet; 

-- Delivery Agent Wallet table
CREATE TABLE IF NOT EXISTS delivery_agent_wallet (
    agentID INT NOT NULL,
    earning_balance DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (earning_balance>=0),
    earning_paid DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (earning_paid>=0),
    earning_total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    Transaction_history VARCHAR(500),
    upiID VARCHAR(100) NOT NULL,
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE 
    -- represents Wallet “Belongs to” DeliveryAgent identifying relationship & wallet gets deleted when delivery agent deleted
);
-- DROP TABLE delivery_agent_wallet;

-- Product Review table
CREATE TABLE IF NOT EXISTS ProductReview (
    productReviewID INT NOT NULL, 
    orderID INT NOT NULL,
    customerID INT NOT NULL,
    comment TEXT,
    rating INT DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
    FOREIGN KEY (orderID) REFERENCES `order`(orderID) ON DELETE CASCADE,
    FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE
    -- represents Customer “purchases” Product Ternary relationship
);
-- DROP TABLE ProductReview;

-- Delivery Review table
CREATE TABLE IF NOT EXISTS DeliveryReview (
	deliveryReviewID INT NOT NULL, 
    orderID INT NOT NULL,
    agentID INT NOT NULL,
    comment TEXT,
    rating INT DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
    tip DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (orderID) REFERENCES `order`(orderID) ON DELETE CASCADE,
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE 
    -- represents Customer “rates” Delivery Ternary relationship
);
-- DROP TABLE DeliveryReview;

-- Relations table

CREATE TABLE IF NOT EXISTS addsToCart (
    customerID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity >= 1),
    PRIMARY KEY (customerID, productID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orderConsistsProduct (
    orderID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity >= 1),
    PRIMARY KEY (orderID, productID),
    FOREIGN KEY (orderID) REFERENCES `order`(orderID),
    FOREIGN KEY (productID) REFERENCES product(productID)
);

CREATE TABLE IF NOT EXISTS storeContainsProduct  (
    storeID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    PRIMARY KEY (productID, storeID),
    FOREIGN KEY (storeID) REFERENCES store(storeID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE
);

SHOW TABLES;


-- populating tables with data 

INSERT INTO customer (first_name, last_name, address_street, address_city, address_state, pincode, phone_no, email, password, dob, age, gender)
VALUES
("Jyoti", "Yadav", "I-56, Karol Bagh", "New Delhi", "Delhi", 110005, 9876543225, "jyoti@quickcart.com", "Jyoti@123$", "1995-05-15", 27, "Female"),
("Ananya", "Sharma", "X-78, Crossing Republik", "Ghaziabad", "Uttar Pradesh", 201009, 9876543263, "ananya@quickcart.com", "Ananya@123$", "1997-01-14", 25, "Female"),
("Sumit", "Sharma", "U-12, Vaishali", "Ghaziabad", "Uttar Pradesh", 201014, 9876543260, "sumit@quickcart.com", "Sumit@123$", "1995-06-30", 26, "Male"),
("Akshay", "Patil", "F-67, Noida Sector 62", "Noida", "Uttar Pradesh", 201309, 9876543245, "akshay@quickcart.com", "Akshay@123$", "1991-09-08", 30, "Male"),
("Ankita", NULL, "B-34, Vaishali", "Ghaziabad", "Uttar Pradesh", 201014, 9876543241, "ankita@quickcart.com", "Ankita@123$", "1992-03-24", 29, "Female"),
("Suman", "Sethi", "E-45, Rajendra Nagar", "Ghaziabad", "Uttar Pradesh", 201003, 9876543237, "suman@quickcart.com", "Suman@123$", "1993-02-01", 29, "Female"),
("Amit", "Kumar", "A-46, Vaishali Nagar", "Ghaziabad", "Uttar Pradesh", 201001, 9876543214, "amit@quickcart.com", "Amit@123$", "1990-12-25", 34, "Male"),
("Kritika", "Sharma", "D-89, Vasant Kunj", "New Delhi", "Delhi", 110070, 9876543227, "kritika@quickcart.com", "Kritika@123$", "1999-08-18", 22, "Female"),
("Swati", NULL, "A-56, Chanakyapuri", "New Delhi", "Delhi", 110021, 9876543233, "swati@quickcart.com", "Swati@123$", "1997-10-10", 25, "Female"),
("Seema", "Tiwari", "W-403, DLF Phase 3, Gurgaon", "Gurgaon", "Haryana", 122002, 9876543213, "seema@quickcart.com", "Seema@123$", "1992-02-14", 32, "Female"),
("Rahul", "Mehra", "H-15, Rajouri Garden", "New Delhi", "Delhi", 110027, 9876543224, "rahul@quickcart.com", "Rahul@123$", "1990-09-08", 31, "Male"),
("Ankit", "Srivastava", "M-23, Mayur Vihar Phase 1", "New Delhi", "Delhi", 110091, 9876543252, "ankit@quickcart.com", "Ankit@123$", "1993-02-20", 29, "Male"),
("Rohit", "Yadav", "E-45, Vasundhara", "Ghaziabad", "Uttar Pradesh", 201012, 9876543244, "rohit@quickcart.com", "Rohit@123$", "1994-05-18", 28, "Male"),
("Rajat", "Srivastava", "Indirapuram, Ghaziabad", "Ghaziabad", "Uttar Pradesh", 201014, 9876543218, "rajat@quickcart.com", "Rajat@123$", "1993-09-20", 31, "Male"),
("Vikas", "Sinha", "G-22, Mayur Vihar", "New Delhi", "Delhi", 110091, 9876543230, "vikas@quickcart.com", "Vikas@123$", "1992-01-30", 30, "Male"),
("Rishi", "Verma", "A-123, Janakpuri", "New Delhi", "Delhi", 110058, 9876543210, "rishi@quickcart.com", "Rishi@123$", "1998-08-15", 26, "Male"),
("Rajat", "Verma", "C-56, Sahibabad", "Ghaziabad", "Uttar Pradesh", 201005, 9876543242, "rajatverma@quickcart.com", "Rajat@123$", "1988-10-12", 33, "Male"),
("Anjali", "Sharma", "Sector 15, Faridabad", "Faridabad", "Haryana", 121007, 9876543219, "anjali@quickcart.com", "Anjali@123$", "1999-11-28", 25, "Female"),
("Alok", "Verma", "B-123, Pitampura", "New Delhi", "Delhi", 110088, 9876543228, "alok@quickcart.com", "Alok@123$", "1988-07-12", 33, "Male"),
("Vikram", NULL, "K-45, Laxmi Nagar", "New Delhi", "Delhi", 110092, 9876543250, "vikram@quickcart.com", "Vikram@123$", "1992-09-22", 29, "Male"),
("Sneha", "Sharma", "D-78, Crossing Republik", "Ghaziabad", "Uttar Pradesh", 201009, 9876543243, "sneha@quickcart.com", "Sneha@123$", "1997-01-14", 25, "Female"),
("Arun", "Yadav", "F-23, Kaushambi", "Ghaziabad", "Uttar Pradesh", 201010, 9876543238, "arun@quickcart.com", "Arun@123$", "1990-09-15", 31, "Male"),
("Rahul", "Sinha", "A-12, Nehru Nagar", "Ghaziabad", "Uttar Pradesh", 201001, 9876543240, "rahulsinha@quickcart.com", "Rahul@123$", "1995-06-30", 26, "Male"),
("Manisha", "Chauhan", "L-78, Patparganj", "New Delhi", "Delhi", 110092, 9876543251, "manisha@quickcart.com", "Manisha@123$", "1990-05-12", 31, "Female"),
("Nisha", "Yadav", "J-89, Indirapuram", "Ghaziabad", "Uttar Pradesh", 201014, 9876543249, "nisha@quickcart.com", "Nisha@123$", "1995-01-15", 27, "Female"),
("Avinash", "Mishra", "I-34, Yamuna Expressway", "Noida", "Uttar Pradesh", 201306, 9876543248, "avinash@quickcart.com", "Avinash@123$", "1998-04-30", 24, "Male"),
("Alok", "Yadav", "Y-45, Vasundhara", "Ghaziabad", "Uttar Pradesh", 201012, 9876543264, "alokyadav@quickcart.com", "Alok@123$", "1994-05-18", 28, "Male"),
("Rohan", NULL, "B-22, Sector 21, Noida", "Noida", "Uttar Pradesh", 201301, 9876543212, "rohan@quickcart.com", "Rohan@123$", "1995-05-01", 29, "Male"),
("Anvi", "Sharma", "R-78, Crossing Republik", "Ghaziabad", "Uttar Pradesh", 201009, 9876543283, "anvisharma@quickcart.com", "Anvi@123$", "1997-01-14", 25, "Female"),
("Karan", "Negi", "F-33, Nehru Place", "New Delhi", "Delhi", 110019, 9876543232, "karan@quickcart.com", "Karan@123$", "1998-04-22", 24, "Male"),
("Rajeev", NULL, "D-67, Ashok Vihar", "New Delhi", "Delhi", 110052, 9876543236, "rajeev@quickcart.com", "Rajeev@123$", "1987-07-22", 34, "Male"),
("Simran", NULL, "C-67, Preet Vihar", "New Delhi", "Delhi", 110092, 9876543229, "simran@quickcart.com", "Simran@123$", "1994-03-05", 28, "Female"),
("Sachin", "Choudhary", "B-32, Bhopura", "Ghaziabad", "Uttar Pradesh", 201005, 9876543216, "sachin@quickcart.com", "Sachin@123$", "1988-01-09", 34, "Male"),
("Priyanka", "Yadav", "C-12, Hauz Khas", "New Delhi", "Delhi", 110016, 9876543235, "priyanka@quickcart.com", "Priyanka@123$", "1996-12-12", 25, "Female"),
("Kavita", "Yadav", "Sushant Lok Phase 1, Gurgaon", "Gurgaon", "Haryana", 122002, 9876543217, "kavita@quickcart.com", "Kavita@123$", "1997-03-11", 27, "Female"),
("Raj", "Chauhan", "A-34, Rohini", "New Delhi", "Delhi", 110085, 9876543226, "raj@quickcart.com", "Raj@123$", "1993-11-25", 29, "Male"),
("Prateek", "Goyal", "F-78, Malviya Nagar", "New Delhi", "Delhi", 110022, 9876543222, "prateek@quickcart.com", "Prateek@123$", "1991-12-10", 30, "Male"),
("Pooja", "Rawat", "H-90, Greater Kailash", "New Delhi", "Delhi", 110048, 9876543231, "pooja@quickcart.com", "Pooja@123$", "1989-06-14", 33, "Female"),
("Poonam", NULL, "N-67, Nirman Vihar", "New Delhi", "Delhi", 110092, 9876543253, "poonam@quickcart.com", "Poonam@123$", "1996-12-10", 25, "Female"),
("Priya", "Tyagi", "H-45, Dwarka", "New Delhi", "Delhi", 110077, 9876543211, "priya@quickcart.com", "Priya@123$", "2000-10-22", 24, "Female"),
("Vivek", "Gupta", "Rajendra Nagar, Ghaziabad", "Ghaziabad", "Uttar Pradesh", 201001, 9876543220, "vivek@quickcart.com", "Vivek@123$", "1985-07-03", 36, "Male"),
("Saurabh", "Chauhan", "G-23, Noida Sector 18", "Noida", "Uttar Pradesh", 201301, 9876543246, "saurabh@quickcart.com", "Saurabh@123$", "1986-11-25", 35, "Male"),
("Ravi", "Sharma", "B-78, South Extension", "New Delhi", "Delhi", 110049, 9876543234, "ravi@quickcart.com", "Ravi@123$", "1991-08-28", 30, "Male"),
("Abhinav", NULL, "S-89, Shastri Nagar", "Ghaziabad", "Uttar Pradesh", 201002, 9876543258, "abhinav@quickcart.com", "Abhinav@123$", "1990-09-15", 31, "Male"),
("Akanksha", "Sinha", "R-45, Ramesh Nagar", "New Delhi", "Delhi", 110015, 9876543257, "akanksha@quickcart.com", "Akanksha@123$", "1993-02-01", 29, "Female"),
("Nidhi", "Shukla", "G-224, Lajpat Nagar", "New Delhi", "Delhi", 110024, 9876543223, "nidhi@quickcart.com", "Nidhi@123$", "1996-02-20", 26, "Female"),
("Deepika", "Saxena", "H-56, Greater Noida", "Noida", "Uttar Pradesh", 201310, 9876543247, "deepika@quickcart.com", "Deepika@123$", "1993-06-14", 28, "Female"),
("Pallavi", "Saxena", "T-23, Tronica City", "Ghaziabad", "Uttar Pradesh", 201102, 9876543259, "pallavi@quickcart.com", "Pallavi@123$", "1985-11-18", 36, "Female"),
("Sheetal", NULL, "Z-67, Noida Sector 62", "Noida", "Uttar Pradesh", 201309, 9876543265, "sheetal@quickcart.com", "Sheetal@123$", "1991-09-08", 30, "Female"),
("Neha", "Gokhale", "C-32, Sector 49, Faridabad", "Faridabad", "Haryana", 121004, 9876543215, "neha@quickcart.com", "Neha@123$", "2002-06-18", 22, "Female");

SELECT * FROM customer;

INSERT INTO admin (password) VALUES
("aarzoo@008"),
("shobhit@482"),
("sidhartha@499"),
("vanshika@560");

SELECT * FROM admin;

INSERT INTO productCategory (name, noOfProducts) VALUES
('Dairy Products',30),
('Fruits & Vegetables',40),
('Munchies', 100),
('Sweets and Chocolates', 30),
('Health and Wellness', 40),
('Drinks and Juices', 25),
('Spices and Condiments',20),
('Beauty and Personal Care', 90),
('Home and Kitchen', DEFAULT),
('Books', 120),
('Toys and Games', 60);
    
SELECT * FROM productCategory;

INSERT INTO product (name, price, stock, brand, qty_bought, description, categoryID) VALUES
('Amul Cow Milk', 27.00, 20, 'Amul', 7, "Pure and fresh cow's milk packed with great nutrition.", 1),
('Go Cheese', 200, 10, 'Go', 5, 'Yummy cheese that brings magin in every bite.', 1),
('Carrot 500g', 34, 40, 'QuickCart', 14, 'Crunchy, sweet & tasty.', 2),
('Aloo Bhujia', 79.00, 60, 'Haldirams', 45, 'Crispy, crunchy snack that leaves you asking for more.', 3),
('French Fries', 199.99, 40, 'McCain', 15, 'Crispy on the outside and fluffy in the centre, delicious in taste.', 3),
('Milk Chocolate', 4299.99, 30, 'Cadbury', 8, 'Smooth chocolaty delight perfect to satisfy your sweet urges.', 4),
('Antacid', 79.99, 40, 'Eno', DEFAULT, 'Gets to work in 6 seconds to neutralize acid in your stomach and provide fast relief.', 5),
('Mixed Fruit Juice 1L', 109.99, 25, 'Real', 18, 'Filled with the best qualities of 9 different fruits, no added preservatives.', 6),
('Cumin Seeds 100g', 46, 20, 'Whole Farm', 2, 'Cumin seeds/Jeera is used to give dishes a strong & spicy flavour.', 7),
('Body Lotion 400ml', 399.99, 60, 'Nivea', 42, 'Nourishes skin & provide long-lasting moisture.', 8),
('Coconut Oil 250ml', 199.99, 30, 'Parachute', 22, 'Nothing but 100% pure coconut oil.', 8),
('Three Men In A Boat', 129.99, 120, 'Jerome K. Jerome', 22, 'Treat yourself with humour and adventure.', 10),
('Uno Cards', 127.99, 60, 'Mattel', 22, "The world's most beloved card game.", 11);

SELECT * FROM product;

INSERT INTO deliveryAgent (first_name, last_name, availabilityStatus, phone_no, email, password) VALUES
("Rahul", "Kumar", "Available", 9876543300, "rahul.kumar@delivery.com", "Rk@123#"),
("Vikram", NULL, "Offline", 9876543302, "vikram.singh@delivery.com", "Vs@123!"),
("Rishi", "Gupta", "Available", 9876543304, "rishi.gupta@delivery.com", "Rg@123&"),
("Suresh", NULL, "Busy", 9876543310, "suresh.yadav@delivery.com", "Sy@123"),
("Vikas", "Kumar", "Available", 9876543312, "vikas.kumar@delivery.com", "Vk@123"),
("Rajeev", "Gupta", DEFAULT, 9876543314, "rajeev.gupta@delivery.com", "Rg@123"),
("Ashish", "Kumar", "Offline", 9876543325, "ashish.kumar@delivery.com", "Ak@123"),
("Neeraj", "Sharma", "Busy", 9876543327, "neeraj.sharma@delivery.com", "Ns@123"),
("Deepak", NULL, "Available", 9876543329, "deepak.yadav@delivery.com", "Dy@123"),
("Anil", "Kumar", "Available", 9876543331, "anil.kumar@delivery.com", "Ak@123");

SELECT * FROM deliveryAgent;

INSERT INTO store (address_street, address_city, address_state, pincode) VALUES 
('Central Street 123', 'Ghaziabad', 'Uttar Pradesh', 201001),
('Main Avenue 456', 'New Delhi', 'Delhi', 110001),
('Downtown Boulevard 789', 'Gurgaon', 'Haryana', 122001),
('City Center 321', 'Noida', 'Uttar Pradesh', 201301);

SELECT * FROM store;

INSERT INTO `order` (status, total_price, time, location, customerID, agentID) VALUES
('Confirmed', 90.00, '2024-01-22 09:00:00', "I-56, Karol Bagh, New Delhi", 1, 10),
('Packed', 110.75, '2024-01-23 10:30:00', "X-78, Crossing Republik, Ghaziabad", 2, 9),
('Shipped', 515.50, DEFAULT, "U-12, Vaishali, Ghaziabad", 3, 6),
('Delivered', 70.25, '2024-01-25 13:00:00', "F-67, Noida Sector 62", 4, 7),
('Confirmed', 400.00, '2024-01-26 14:15:00', "B-34, Vaishali, Ghaziabad", 5, 8),
('Packed', 95.50, '2024-01-27 15:30:00', "E-45, Rajendra Nagar, Ghaziabad", 6, 4),
('Shipped', 120.00, '2024-01-28 16:45:00', "A-46, Vaishali Nagar, Ghaziabad", 7, 3),
('Delivered', 850.75, '2024-01-29 17:00:00', "D-89, Vasant Kunj, New Delhi", 8, 5),
('Confirmed', 60.50, '2024-01-30 18:15:00', "A-56, Chanakyapuri, New Delhi", 9, 1),
('Packed', 110.00, '2024-01-31 19:30:00', "W-403, DLF Phase 3, Gurgaon", 10, 2);

SELECT * FROM `order`;

INSERT INTO wallet (customerID, balance, upiID, rewardPoints) VALUES
(1, 1000, 'customer1@upi', 0),
(2, 1500, 'customer2@upi', 0),
(3, DEFAULT, 'customer3@upi', 0),
(4, 430, 'customer4@upi', 0),
(5, 220, 'customer5@upi', 0),
(6, 1000, 'customer6@upi', 0),
(7, 470, 'customer7@upi', 0),
(8, 550, 'customer8@upi', 0),
(9, 600, 'customer9@upi', 0),
(10, 10000, 'customer10@upi', 0);

SELECT * FROM wallet;

INSERT INTO delivery_agent_wallet (agentID, earning_balance, earning_paid, earning_total, Transaction_history, upiID) VALUES
(1, 0.00, 0.00, 0.00, '', 'rahul.kumar@upi'),
(2, 0.00, 0.00, 0.00, '', 'vikram@upi'),
(3, 0.00, 0.00, 0.00, '', 'rishi.gupta@upi'),
(4, 0.00, 0.00, 0.00, '', 'suresh@upi'),
(5, 0.00, 0.00, 0.00, '', 'vikas.kumar@upi'),
(6, 0.00, 0.00, 0.00, '', 'rajeev.gupta@upi'),
(7, 0.00, 0.00, 0.00, '', 'ashish.kumar@upi'),
(8, 0.00, 0.00, 0.00, '', 'neeraj.sharma@upi'),
(9, 0.00, 0.00, 0.00, '', 'deepak@upi'),
(10, 0.00, 0.00, 0.00, '', 'anil.kumar@upi');
    
SELECT * FROM delivery_agent_wallet;

INSERT INTO ProductReview (productReviewID, orderID, customerID, comment, rating) VALUES
(1, 1, 1, 'Great product!', 5),
(2, 2, 2, 'Excellent service!', 4),
(3, 3, 3, 'Fast shipping, good quality.', 5),
(4, 4, 4, 'Satisfied with the purchase.', 3),
(5, 5, 5, 'Amazing product, highly recommended.', 5),
(6, 6, 6, 'Packaging could be better.', 3),
(7, 7, 7, 'Impressed with the customer service.', 4),
(8, 8, 8, 'Not happy with the delivery time.', 2),
(9, 9, 9, 'Product as described.', 4),
(10, 10, 10, 'Easy returns process.', 5);

SELECT * FROM ProductReview;

INSERT INTO DeliveryReview (deliveryReviewID, orderID, agentID, comment, rating, tip) VALUES
(1, 1, 10, 'Delivery was on time.', 5, 2.50),
(2, 2, 9, 'Polite delivery agent.', 4, 1.00),
(3, 3, 8, 'Quick and efficient delivery.', 5, 0.50),
(4, 4, 7, 'Delayed delivery, but agent was apologetic.', 3, 0.00),
(5, 5, 6, 'Excellent service, received with a smile.', 5, 3.00),
(6, 6, 5, 'Delivery agent could be more professional.', 3, 0.00),
(7, 7, 4, 'Agent went above and beyond to deliver.', 4, 2.00),
(8, 8, 3, 'Late delivery, no communication from agent.', 2, 0.00),
(9, 9, 2, 'Smooth delivery process.', 4, 1.50),
(10, 10, 1, 'Agent was helpful in setting up the product.', 5, 4.00);

SELECT * FROM DeliveryReview;

INSERT INTO addsToCart (customerID, productID, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 3, 3),
(2, 4, 1),
(3, 1, 1),
(3, 5, 2),
(4, 6, 1),
(5, 7, 4),
(6, 8, 2),
(7, 9, 1);

SELECT * FROM addsToCart;

INSERT INTO orderConsistsProduct (orderID, productID, quantity) VALUES
(1, 1, 2), 
(1, 2, 1), 
(2, 3, 3), 
(2, 4, 1), 
(3, 1, 1), 
(3, 5, 2), 
(4, 6, 1), 
(5, 7, 4), 
(6, 8, 2), 
(7, 9, 1); 

SELECT * FROM orderConsistsProduct;

INSERT INTO storecontainsproduct (storeID, productID, quantity) VALUES
(1, 1, 10),  
(2, 2, 20),  
(1, 3, 15),  
(4, 4, 12),
(2, 5, 10),
(3, 6, 22),
(2, 7, 32),
(4, 8, 21),
(4, 9, 15),
(4, 1, 17);  

SELECT * FROM  storecontainsproduct;    

