CREATE DATABASE sailor10;

USE sailor10;

CREATE TABLE sailors(
sid INT PRIMARY KEY,
sname VARCHAR (30),
rating INT,
age INT);

CREATE TABLE boat(
bid INT PRIMARY KEY,
bname VARCHAR(30),
color VARCHAR(15));

CREATE TABLE reserves(
sid INT ,
bid INT,
date DATE,
FOREIGN KEY (sid) REFERENCES sailors(sid),
FOREIGN KEY (bid) REFERENCES boat(bid));

INSERT INTO sailors VALUES
(31,'Albert',7,45),
(32,'Victor',9,50),
(33,'Stormy',10,35),
(34,'Mandy',8,28),
(35,'Randy',6,25),
(36,'NeelAmstormg',9,47);
 
INSERT INTO boat VALUES
(101,'Boat-1','Green'),
(102,'Boat-2','Red'),
(103,'Boat-3','Blue'),
(104,'Boat-4','Grey'),
(105,'Boat-5','White');


INSERT INTO reserves VALUES
(31,101,'2023-11-25'),
(31,103,'2023-08-30'),
(31,105,'2023-12-22'),
(32,102,'2023-11-17'),
(32,104,'2023-08-17'),
(32,105,'2023-10-17'),
(33,102,'2023-12-10'),
(33,101,'2023-12-22'),
(34,102,'2023-12-22');

SELECT * FROM sailors;

SELECT * FROM boat;

SELECT * FROM reserves;

-- Find the colours of boats reserved by Albert
    
  select color from boat
join reserves r using(bid)
join sailors s using(sid)
where s.sname="Albert";
    
-- Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103
SELECT sid
FROM sailors 
WHERE rating>=8 OR (
	 SELECT sid 
     FROM reserves
     WHERE bid=103);
     
-- Find the names of sailors who have not reserved a boat, whose name contains the string “storm”. Order the names in ascending order.
SELECT sname 
FROM sailors 
WHERE sid NOT IN (
	SELECT sid 
    FROM reserves 
    WHERE bid IN(
		SELECT bid 
        FROM boat where bname LIKE '%storm%'));
    
-- Find the names of sailors who have reserved all boats.   **********
select sname from sailors s where not exists
	(select * from boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid));
        

INSERT INTO reserves VALUES
(31,102,'2023-10-01'),
(31,104,'2023-11-01');

-- Find the name and age of the oldest sailor. 
SELECT sname,age
FROM sailors 
WHERE age=(SELECT MAX(age)
FROM sailors);


-- OR  --
select sname,age 
from sailors
order by age desc limit 1;


-- For each boat which was reserved by at least 5 sailors with age >= 40, find the boat id and the average age of such sailors.
select b.bid, avg(s.age) as average_age  
from sailors s, boat b, reserves r
where r.sid=s.sid and r.bid=b.bid and s.age>=40
group by bid
having 2<=count(distinct r.sid);

-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
create view specific_rating as
SELECT DISTINCT bname, color
FROM reserves
JOIN boat b USING (bid)
JOIN sailors s USING (sid)
WHERE s.rating=10;

select * from specific_rating;

-- Trigger that prevents boats from being deleted if they have active reservation

DELIMITER //
create trigger CheckAndDelete
before delete on boat
for each row
BEGIN
	IF EXISTS (select * from reserves where bid=old.bid) THEN
		SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
	END IF;
END;//

DELIMITER ;

DELETE FROM boat
WHERE bid =103;
