# node-mysql-game
*Copyright 2015 Joseph Burger all rights reserved.
To use under MIT license, all copyrights must be perserved.
Contact at 'candyapplecorn@gmail.com' if you would like to use this.*

__node-mysql-game is a basic CRUD application utilizing an HTML front end, Javascript back end and SQL database, intended to be deployed on a linux server.__

Demo Video: https://youtu.be/WfJ6ikPaAZs  

Users will be able to register, log in and out, and perform operations to play the game. 

The front end, or user interface, is an html page that sends and recieves data using ajax. It makes use of a stylish front end framework called "foundation".

The back-end consists of several parts:

__a.)__ The server-side code - originally written as PHP (see php-ver/), rewritten as Javascript. It consists of a single file (although any professional operation would break that file into many files), called "Server.js", which listens on a specified socket for connections.

__b.)__ The database - MySQL. More than just tables, there are over 400 lines of stored procedures. This made changing from PHP to Javascript substantially easier, as rather than putting logic for the game into PHP, it was written in MySQL procedural query language.

__c.)__ The hardware - The app is planned to be deployed on a linux cloud server. The shell scripts (files ending in .sh) are run on the server's command line.

## Stored Procedures

Much of the logic programming for this game is written in pure SQL. Here's a snippet from [the schema](MySQL/commands.sql) which takes care of registering a new user:

```sql
CREATE PROCEDURE add_user(usern VARCHAR(255), passw VARCHAR(255), em VARCHAR(255))
BEGIN
    DECLARE newuserid, newuserfirstrow INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR 1062 SELECT "username taken!";
INSERT INTO players (username, password, email)
VALUES (usern, (select md5(passw)), em);

WHILE newuserfirstrow = 0 OR newuserfirstrow > (SELECT COUNT(id) FROM gamerows) DO
    SELECT find_new_user_first_row() INTO newuserfirstrow;
    IF newuserfirstrow = 0 OR newuserfirstrow > (SELECT COUNT(id) FROM gamerows) THEN
        SELECT "Calling fillgamerows";
        CALL fillgamerows(10);
    END IF;
END WHILE;
SELECT id FROM players WHERE username = usern INTO newuserid;

CALL grantrow(newuserfirstrow, newuserid);
END
//
```

Please contact if you find any bugs, security issues or have a suggestion!
