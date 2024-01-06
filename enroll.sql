
create database enrollment;
use enrollment;

create table Student(
	regno varchar(13) primary key,
	name varchar(25) not null,
	major varchar(25) not null,
	bdate date not null
);

create table Course(
	course int primary key,
	cname varchar(30) not null,
	dept varchar(100) not null
);

create table Enroll
(
	regno varchar(13),
	course int,
	sem int not null,
	marks int not null,
	foreign key(regno) references Student(regno) on delete cascade ON UPDATE CASCADE,
	foreign key(course) references Course(course) on delete cascade ON UPDATE CASCADE
);

create table TextBook(
	bookIsbn int not null,
	book_title varchar(40) not null,
	publisher varchar(25) not null,
	author varchar(25) not null,
	primary key(bookIsbn)
);

create table BookAdoption(
	course int not null,
	sem int not null,
	bookIsbn int not null,
	foreign key(bookIsbn) references TextBook(bookIsbn) on delete cascade ON UPDATE CASCADE,
	foreign key(course) references Course(course) on delete cascade ON UPDATE CASCADE
);

INSERT INTO Student VALUES
("01HF235", "Student_1", "CSE", "2001-05-15"),
("01HF354", "Student_2", "Literature", "2002-06-10"),
("01HF254", "Student_3", "Philosophy", "2000-04-04"),
("01HF653", "Student_4", "History", "2003-10-12"),
("01HF234", "Student_5", "Computer Economics", "2001-10-10");

INSERT INTO Course VALUES
(001, "DBMS", "CS"),
(002, "Literature", "English"),
(003, "Philosophy", "Philosphy"),
(004, "History", "Social Science"),
(005, "Computer Economics", "CS");

INSERT INTO Enroll VALUES
("01HF235", 001, 5, 85),
("01HF354", 002, 6, 87),
("01HF254", 003, 3, 95),
("01HF653", 004, 3, 80),
("01HF234", 005, 5, 75);

INSERT INTO TextBook VALUES
(241563, "Operating Systems", "Pearson", "Silberschatz"),
(532678, "Complete Works of Shakesphere", "Oxford", "Shakesphere"),
(453723, "Immanuel Kant", "Delphi Classics", "Immanuel Kant"),
(278345, "History of the world", "The Times", "Richard Overy"),
(426784, "Behavioural Economics", "Pearson", "David Orrel");

INSERT INTO BookAdoption VALUES
(001, 5, 241563),
(002, 6, 532678),
(003, 3, 453723),
(004, 3, 278345),
(001, 6, 426784);

select * from Student;
select * from Course;
select * from Enroll;
select * from BookAdoption;
select * from TextBook;


-- Demonstrate how you add a new text book to the database and make this book be adopted by some department.
insert into TextBook values
(123456, "Chandan The Autobiography", "Pearson", "Chandan");

insert into BookAdoption values
(001, 5, 123456);


-- Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books.
SELECT c.course,t.bookIsbn,t.book_title
     FROM Course c,BookAdoption ba,TextBook t
     WHERE c.course=ba.course
     AND ba.bookIsbn=t.bookIsbn
     AND c.dept='CS'
     AND 2<(
     SELECT COUNT(bookIsbn)
     FROM BookAdoption b
     WHERE c.course=b.course)
     ORDER BY t.book_title;


-- List any department that has all its adopted books published by a specific publisher.
SELECT DISTINCT c.dept
FROM TextBook t,BookAdoption b,Course c
WHERE t.bookIsbn=b.bookIsbn and b.course=c.course and t.publisher="Pearson";

-- List the students who have scored maximum marks in ‘DBMS’ course.

select name from Student s, Enroll e, Course c
where s.regno=e.regno and e.course=c.course and c.cname="DBMS" and e.marks in (select max(marks) from Enroll e1, Course c1 where c1.cname="DBMS" and c1.course=e1.course);


-- OR -- 
select s.name 
from Student s,Enroll e,Course c
where s.regno=e.regno and c.course=e.course and e.marks=(select max(marks)
                                                            from Enroll
                                                            join Course using (course)
                                                            where Course.cname="DBMS");


-- Create a view to display all the courses opted by a student along with marks obtained.
create view CoursesOptedByStudent as
select c.cname, e.marks from Course c, Enroll e
where e.course=c.course and e.regno="01HF235";

select * from CoursesOptedByStudent;







-- Create a trigger that prevents a student from enrolling in a course if the marks pre_requisit is less than the given threshold 
DELIMITER //
create  trigger PreventEnrollment
before insert on Enroll
for each row
BEGIN
	IF (new.marks<40) THEN
		signal sqlstate '45000' set message_text='Marks below 40 cannot be enrolled';
	END IF;
END;//

DELIMITER ;

INSERT INTO Enroll VALUES
("01HF235", 002, 5, 39); -- Gives error since marks is less than 40
