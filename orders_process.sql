
create database order_processing;
use order_processing;

create table if not exists Customers (
	cust_id int primary key,
	cname varchar(35) not null,
	city varchar(35) not null
);

create table if not exists Orders (
	order_id int primary key,
	odate date not null,
	cust_id int,
	order_amt int not null,
	foreign key (cust_id) references Customers(cust_id) on delete cascade ON UPDATE CASCADE
);

create table if not exists Items (
	item_id  int primary key,
	unitprice int not null
);

create table if not exists OrderItems (
	order_id int not null,
	item_id int not null,
	qty int not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (item_id) references Items(item_id) on delete cascade
);

create table if not exists Warehouses (
	warehouse_id int primary key,
	city varchar(35) not null
);

create table if not exists Shipments (
	order_id int not null,
	warehouse_id int not null,
	ship_date date not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (warehouse_id) references Warehouses(warehouse_id) on delete cascade
);

INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");
SHOW TABLES;

INSERT INTO OrderItems VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");


SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Items;
SELECT * FROM Shipments;
SELECT * FROM Warehouses;



-- List the Order# and Ship_date for all orders shipped from Warehouse# "0002".
SELECT order_id,ship_date
FROM Shipments
WHERE warehouse_id=0002;

-- List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#
SELECT w.warehouse_id,w.city,o.order_id FROM Warehouses AS w
JOIN Shipments as s
JOIN Customers as c
JOIN Orders as o
WHERE w.warehouse_id=s.warehouse_id and s.order_id=o.order_id and o.cust_id=c.cust_id and c.cname="Kumar";


-- or -- 
select w.warehouse_id,w.city,o.order_id
from Warehouses w,Orders o,Customers c,Shipments s
where o.cust_id=c.cust_id and o.order_id=s.order_id and w.warehouse_id=s.warehouse_id and c.cname="Kumar";


-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and the last column is the average order amount for that customer. (Use aggregate functions) 
select cname, COUNT(*) as no_of_orders, AVG(order_amt) as avg_order_amt
from Customers c, Orders o
where c.cust_id=o.cust_id 
group by cname;




-- or--
select c.cname,count(*) as total,avg(o.order_amt) as average_amount
from Customers c ,Orders o
where c.cust_id=o.cust_id
group by cname;


-- Find the item with the maximum unit price.
SELECT item_id,unitprice
FROM Items
WHERE unitprice=(SELECT MAX(unitprice)
FROM Items);




-- Create a view to display orderID and shipment date of all orders shipped from a warehouse 2.

CREATE VIEW shipped AS
SELECT order_id,ship_date FROM Shipments WHERE warehouse_id=5;


SELECT * FROM shipped;


-- Deleting all orders from kumar
DELETE FROM Orders
WHERE Orders.cust_id=(SELECT cust_id
                FROM Customers
                WHERE cname="Kumar");
SELECT * FROM Orders;

-- A tigger that updates order_amount based on quantity and unit price of order_item




create trigger my_amt
after insert on orderitems
for each row
update orders 
set order_amt=(select unitprice from items where item_id=NEW.item_id)*NEW.qty where order_id=NEW.order_id;

INSERT INTO Orders VALUES
(007, "2020-12-23", 0005, 1200);

INSERT INTO OrderItems VALUES 
(007, 0001, 5); -- This will automatically update the Orders Table also



INSERT INTO Orders 
(order_id,odate,cust_id,order_amt)
VALUES
(009, "2020-12-23", 0003,1200);

INSERT INTO OrderItems VALUES 
(009,0003,9); 

select * from Orders;


INSERT INTO Orders 
(order_id,odate,cust_id,order_amt)
VALUES
(100, "2020-12-23", 0003,1200);

INSERT INTO OrderItems VALUES 
(100,0003,18); 
