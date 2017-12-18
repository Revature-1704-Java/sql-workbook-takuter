----SQL Queries

savepoint a;

--Select
SELECT * from  EMPLOYEE;
SELECT * from EMPLOYEE where (lastname = 'King');
SELECT * from EMPLOYEE where (firstname = 'Andrew' and REPORTSTO is NULL);

--ORDER BY
SELECT * from ALBUM ORDER BY title DESC;
SELECT firstname from CUSTOMER ORDER BY city ASC;

savepoint a;
--INSERT INTO
INSERT INTO GENRE VALUES (26, 'Chillhop');
INSERT INTO GENRE VALUES (27,'Jazzhop');

INSERT INTO employee (employeeid, lastname, firstname) VALUES (10,'last','first');
INSERT INTO employee (employeeid, lastname, firstname) VALUES (13,'last','first');

INSERT INTO customer (customerid,lastname,firstname,email) VALUES(93,'last','first','email');
INSERT INTO customer (customerid,lastname,firstname,email) VALUES(95,'last','first','email');

--UPDATE
UPDATE customer 
set firstname='Robert',lastname='Walter'
where firstname='Aaron' and lastname='Mitchell';

UPDATE artist
set name='CCR'
where name='Creedence Clearwater Revival';


--LIKE
SELECT * from invoice
where billingaddress like 'T%';

--BETWEEN
select * from invoice
where total
between 15 and 50;

select * from employee
where hiredate
between '01-JUN-03' and '01-MAR-04';


--DELETE
DELETE FROM invoiceline
where invoiceid
    in (Select invoiceid FROM invoice where customerid in(SELECT customerid from Customer where firstname='Robert' and lastname = 'Walter'));
    
DELETE FROM invoice
where customerid 
    in (Select customerid from Customer where firstname='Robert' and lastname = 'Walter');

DELETE FROM customer
where firstname='Robert' and lastname = 'Walter';
Select firstname,lastname from Customer;

rollback to a;


SELECT CURRENT_TIMESTAMP from dual;
SELECT LENGTH(name) AS mediatypeLength FROM mediatype;

----SQL Functions

SELECT LENGTH(name),CURRENT_TIMESTAMP AS mediatypeLength FROM mediatype;

SELECT AVG(total) from invoice;
SELECT max(unitprice) from Track;


CREATE OR REPLACE function invoicePriceAvg
return NUMBER
AS 
    avgTotal number(10,2);
        tcount NUMBER :=0;
        tsum NUMBER :=0;
BEGIN 
    for t in (select unitprice from invoiceline)
    LOOP
        tsum:=tsum+t.unitprice;
        tcount:=tcount+1;
    END LOOP;
    avgTotal := tsum/tcount;
    return avgTotal;
END invoicePriceAvg;
/


CREATE OR REPLACE function employeeAge
RETURN SYS_REFCURSOR
AS
    EMP SYS_REFCURSOR;
BEGIN 
    Open EMP for
    SELECT FIRSTNAME,LASTNAME, BIRTHDATE from EMPLOYEE where BIRTHDATE > TO_DATE('1968-12-31','yyyy-mm-dd');
    return emp;
END employeeAge;
/


select invoicePriceAvg() from dual;

DECLARE
    S SYS_REFCURSOR;
    SOME_DATE EMPLOYEE.BIRTHDATE%TYPE;
    SOME_FIRST EMPLOYEE.FIRSTNAME%TYPE;
    SOME_LAST EMPLOYEE.LASTNAME%TYPE;
BEGIN
    S := employeeAge;
    LOOP
        FETCH S INTO SOME_FIRST,SOME_LAST,SOME_DATE;
        EXIT WHEN S%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(SOME_FIRST || ' ' || SOME_LAST ||' WAS BORN IN, '|| SOME_DATE);
    END LOOP;
    CLOSE S;
END;
/

--4.0 PROCEDURES
CREATE OR REPLACE PROCEDURE names
(P OUT SYS_REFCURSOR)
AS    
BEGIN 
    Open P for
    SELECT FIRSTNAME,LASTNAME from customer;
END names;
/

DECLARE
    S SYS_REFCURSOR;
    SOME_FIRST CUSTOMER.FIRSTNAME%TYPE;
    SOME_LAST CUSTOMER.LASTNAME%TYPE;
BEGIN
    names(S);
    LOOP
        FETCH S INTO SOME_FIRST,SOME_LAST;
        EXIT WHEN S%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(SOME_FIRST || ' ' || SOME_LAST ||' is an employee.');
    END LOOP;
    CLOSE S;
END;
/

CREATE OR REPLACE PROCEDURE updateCustomer
(oFirst IN VARCHAR2, oLast IN VARCHAR2,  nFirst IN VARCHAR2,  nLast IN VARCHAR)
AS   
BEGIN
    UPDATE Customer
    Set firstname = nfirst, LASTNAME=nLast
    WHERE firstname = ofirst AND LASTNAME = oLAST;
END updateCustomer;
/

CREATE OR REPLACE PROCEDURE getManager
(MiD in number, Mname out varchar2)
AS 
BEGIN
     Select firstname || ' ' || lastname into Mname from EMPLOYEE where EMPLOYEEID=MiD;
     
END getManager;

/

CREATE OR REPLACE PROCEDURE getCustomer
(CiD in number, Cinfo out varchar2)
AS 
BEGIN
     Select firstname || ' ' || lastname || ' ' || company into Cinfo from CUSTOMER where CUSTOMERID=CiD;
END getCustomer;
/



DECLARE
    SOME_CUST varchar2(140 BYTE);
    SOME_MANG varchar2(40 BYTE);
BEGIN
        updateCustomer('Frank','Ralston', 'Bob', 'Joe');
        getManager(4, some_mang);
        getCustomer(2,SOME_CUST);
        DBMS_OUTPUT.PUT_LINE(some_mang ||' is an employee.');
        DBMS_OUTPUT.PUT_LINE(SOME_CUST || ' is an CUSTOMER.');
END;
/

--5.0 Transactions
CREATE or REPLACE PROCEDURE removeInvoice
(iID in number) IS
BEGIN
    DELETE FROM INVOICELINE where INVOICEID = iID;
    DELETE FROM INVOICE where INVOICEID=iID;
END;
/

CREATE or REPLACE PROCEDURE createCustomer
( cI in number,cFN in varchar2, cLN in varchar2, cE in varchar2) IS
BEGIN
    insert into CUSTOMER(CUSTOMERID, FIRSTNAME, LASTNAME, EMAIL) values (cI, cFN, cLN, cE);
END;
/

EXECUTE createCustomer('Jim','Bob', 'a@a.a', 425);

EXECUTE removeInvoice(112);

SELECT * from CUSTOMER;

SELECT * FROM INVOICE;


--6.0 TRIGGERS
CREATE or REPLACE TRIGGER TR_EMP_INSERT
AFTER INSERT ON EMPLOYEE
BEGIN
    DBMS_OUTPUT.PUT_LINE('inserted employee');
END;
/

CREATE or REPLACE TRIGGER TR_ALB_UPDATE
AFTER UPDATE ON ALBUM
BEGIN
    DBMS_OUTPUT.PUT_LINE('updated album');
END;
/

CREATE or REPLACE TRIGGER TR_CUST_DELETE
AFTER INSERT ON EMPLOYEE
BEGIN
    DBMS_OUTPUT.PUT_LINE('deleted customer');
END;
/


--7.0 JOINS
select FIRSTNAME ||' ' || LASTNAME, INVOICEID AS CUSTNAME FROM CUSTOMER 
INNER JOIN INVOICE ON INVOICE.CUSTOMERID=CUSTOMER.CUSTOMERID;

select CUSTOMER.CUSTOMERID, firstname ,lastname, invoiceid, total FROM customer 
LEFT JOIN invoice on customer.CUSTOMERID=INVOICE.CUSTOMERID;

select name, title from album 
right join artist on album.artistid=artist.artistid;

SELECT * from album cross join artist ORDER BY ARTIST.NAME ASC;

SELECT * from EMPLOYEE s join EMPLOYEE m on s.reportsto=m.employeeid;

SELECT  * from CUSTOMER c 
inner join EMPLOYEE e on c.supportrepid=e.employeeid
inner join INVOICE i on i.customerid = c.customerid
inner join INVOICELINE il on il.invoiceid = i.invoiceid
inner join TRACK t on t.trackid=il.trackid
inner join ALBUM ab on ab.albumid=t.albumid 
inner join ARTIST ar on ar.artistid=ab.artistid
inner join GENRE g on g.genreid=t.genreid
inner join mediatype m on m.mediatypeid=t.mediatypeid
inner join playlisttrack pt on t.trackid=pt.trackid
inner join playlist p on pt.playlistid=p.playlistid;


