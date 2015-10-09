create database if not exists html5game; 

USE html5game; 

/*
the default value for password is the md5 of "password"
to get it, just do: mysql> select md5("password");

rowsowned probably isn't needed since sql performs queries fast.
*/
CREATE TABLE IF NOT EXISTS players ( 
id INT AUTO_INCREMENT NOT NULL PRIMARY KEY, 
username VARCHAR(255) NOT NULL UNIQUE, 	-- DEFAULT 'defaultusername', 
password VARCHAR(255) NOT NULL, 	-- DEFAULT '5f4dcc3b5aa765d61d8327deb882cf99', 
money INT DEFAULT 0 CHECK (MONEY >= 0),
fuel INT DEFAULT 0 CHECK (FUEL >= 0),
alliance VARCHAR(255) DEFAULT '',       -- For optional alliances (teams)
rank INT DEFAULT 0,                     -- If we decide to add a level-up / rank system
alerts INT DEFAULT 0, 
/* rowsowned VARCHAR(255) DEFAULT '',*/ -- Not needed in all likelihood.
lastlogin DATETIME 
);

/*
The whole game recolves around rows, so it should be a pretty detailed table!

notice - investors is a json object; for example:
'{"alex": 1000, "nick": 1000000, "joe": 100}'
Pretty freaking neat eh???
Most languages can convert json strings into actual json objects.
In javascript: (str contains a json stringified object)
var json = JSON.stringify(eval("(" + str + ")"));
SQL has json extract functions as well.
*/
CREATE TABLE IF NOT EXISTS gamerows ( 
id INT AUTO_INCREMENT NOT NULL PRIMARY KEY, 
owner INT DEFAULT 0 REFERENCES players(id),
ownerusername VARCHAR(255) DEFAULT '', -- select username from players join gamerows as g where id = g.id;
morale INT DEFAULT 0,
defenders INT DEFAULT 0 CHECK (defenders >= 0),
attackers INT DEFAULT 0 CHECK (attackers >= 0),
money INT DEFAULT 0 CHECK (MONEY >= 0),
fuel INT DEFAULT 0 CHECK (FUEL >= 0),
mgs INT DEFAULT 0 CHECK (MGS >= 0),
fgs INT DEFAULT 0 CHECK (FGS >= 0),
dgs INT DEFAULT 0 CHECK (DGS >= 0),
investments INT DEFAULT 0 CHECK (investments >= 0),
investors VARCHAR(255) DEFAULT '', -- This will be a string containing a JSON object.
lastattacked DATETIME,
lastaccessed DATETIME
);

/*
Now that we've entered our two main tables,
let's populate them with some values.
*/
-- This is my first time making an actual function in pure sql! WOO HOO!
delimiter //
CREATE PROCEDURE fillgamerows(numrows INT)
BEGIN
	SET @x = 0;
	REPEAT
	INSERT INTO gamerows (lastattacked, lastaccessed) VALUES (NOW(), NOW());
	SET @x = @x + 1;
	UNTIL @x >= numrows END REPEAT;
END
//
delimiter ;


delimiter //
CREATE PROCEDURE grantrow(row_id INT, user_id INT)
BEGIN
	UPDATE gamerows
	SET owner=user_id, 
	ownerusername=(SELECT username FROM players WHERE id=user_id),
	morale=DEFAULT(morale), defenders=DEFAULT(defenders), attackers=DEFAULT(attackers),
	money=DEFAULT(money), fuel=DEFAULT(fuel), mgs=DEFAULT(mgs), fgs=DEFAULT(fgs),
	dgs=DEFAULT(dgs), investments=DEFAULT(investments), investors='',
	lastaccessed=NOW()
	WHERE id=row_id;
END
//
delimiter ;

-- Let's make 100 rows in gamerows. 
CALL fillgamerows(100);

-- Now, we'll insert three players.
INSERT INTO players (username, password, lastlogin)
VALUES ("Alex", (select md5("password")), NOW());
INSERT INTO players (username, password, lastlogin)
VALUES ("Joe", (select md5("betterpassword")), NOW());
INSERT INTO players (username, password, lastlogin)
VALUES ("Nick", (select md5("bestpassword")), NOW());

-- Now, let's give them some rows!
-- Give three rows to Alex
CALL grantrow(5, 1);
CALL grantrow(6, 1);
CALL grantrow(7, 1);

-- Give four rows to Nick
CALL grantrow(9, 3);
CALL grantrow(10, 3);
CALL grantrow(11, 3);
CALL grantrow(12, 4);

-- Joe's a jerk and captures two of Nick's rows. HAHA NICK
CALL grantrow(12, 2);
CALL grantrow(11, 2);
CALL grantrow(2, 2);

-- The following is a command and its output after these commands have run:
/*
mysql> select * from gamerows order by id asc limit 15;                                                                                                                                                                                      
+----+-------+---------------+--------+-----------+-----------+-------+------+------+------+------+-------------+-----------+---------------------+---------------------+
| id | owner | ownerusername | morale | defenders | attackers | money | fuel | mgs  | fgs  | dgs  | investments | investors | lastattacked        | lastaccessed        |
+----+-------+---------------+--------+-----------+-----------+-------+------+------+------+------+-------------+-----------+---------------------+---------------------+
|  1 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
|  2 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
|  3 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
|  4 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
|  5 |     1 | Alex          |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:48 |
|  6 |     1 | Alex          |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:48 |
|  7 |     1 | Alex          |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:49 |
|  8 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
|  9 |     3 | Nick          |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:49 |
| 10 |     3 | Nick          |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:49 |
| 11 |     2 | Joe           |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:49 |
| 12 |     2 | Joe           |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:49 |
| 13 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
| 14 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
| 15 |     0 |               |      0 |         0 |         0 |     0 |    0 |    0 |    0 |    0 |           0 |           | 2015-10-03 22:52:45 | 2015-10-03 22:52:45 |
+----+-------+---------------+--------+-----------+-----------+-------+------+------+------+------+-------------+-----------+---------------------+---------------------+
15 rows in set (0.00 sec)

mysql> 
*/
