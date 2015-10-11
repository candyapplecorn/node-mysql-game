-- ============================================================
--      SCHEMA CREATION 
-- ============================================================
create database if not exists html5game; 

USE html5game; 

CREATE TABLE IF NOT EXISTS players ( 
id INT AUTO_INCREMENT NOT NULL PRIMARY KEY, 
username VARCHAR(255) NOT NULL UNIQUE, 	-- DEFAULT 'defaultusername', 
password VARCHAR(255) NOT NULL, 	-- DEFAULT '5f4dcc3b5aa765d61d8327deb882cf99', 
money INT DEFAULT 0 CHECK (MONEY >= 0),
fuel INT DEFAULT 0 CHECK (FUEL >= 0),
alliance VARCHAR(255) DEFAULT '',       -- For optional alliances (teams)
rank INT DEFAULT 0,                     -- If we decide to add a level-up / rank system
alerts INT DEFAULT 0, 
hospital_level INT DEFAULT 0,
attack_level INT DEFAULT 0,
defense_level INT DEFAULT 0,
/* rowsowned VARCHAR(255) DEFAULT '',*/ -- Not needed in all likelihood.
lastlogin DATETIME 
);

/*
The whole game recolves around rows, so it should be a pretty detailed table!
*/
CREATE TABLE IF NOT EXISTS gamerows ( 
id INT AUTO_INCREMENT NOT NULL PRIMARY KEY, 
owner INT DEFAULT 0 REFERENCES players(id),
ownerusername VARCHAR(255) DEFAULT '', 
morale INT DEFAULT 0,
defenders INT DEFAULT 0 CHECK (defenders >= 0),
attackers INT DEFAULT 0 CHECK (attackers >= 0),
money INT DEFAULT 0 CHECK (MONEY >= 0),
fuel INT DEFAULT 0 CHECK (FUEL >= 0),
mgs INT DEFAULT 0 CHECK (MGS >= 0),
fgs INT DEFAULT 0 CHECK (FGS >= 0),
dgs INT DEFAULT 0 CHECK (DGS >= 0),
hospital INT DEFAULT 0 CHECK (hospital >= 0),
investments INT DEFAULT 0 CHECK (investments >= 0),
investors VARCHAR(255) DEFAULT '', -- This will be a string containing a JSON object.
lastattacked DATETIME,
lastaccessed DATETIME
);

-- ============================================================
--     PROCEDURES 
-- ============================================================
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
	morale=100, defenders=DEFAULT(defenders), attackers=DEFAULT(attackers),
	money=DEFAULT(money), fuel=DEFAULT(fuel), mgs=DEFAULT(mgs), fgs=DEFAULT(fgs),
	dgs=DEFAULT(dgs), investments=DEFAULT(investments), investors='',
	lastaccessed=NOW()
	WHERE id=row_id;
END
//
delimiter ;

-- updates a given row's money column
-- drop procedure upd_r_money;
delimiter //
CREATE procedure upd_r_money(row_id int)
BEGIN
DECLARE money_rate INT DEFAULT 1;
DECLARE period INT DEFAULT 0;
SET period = (select timestampdiff(second, (select lastaccessed from gamerows where id = row_id), now()));
update gamerows
set money = money + period * money_rate
where id = row_id;
END;
//
delimiter ;

-- updates a given row's fuel column
-- drop procedure upd_r_fuel;
delimiter //
CREATE procedure upd_r_fuel(row_id int)
fuel: BEGIN
DECLARE fuel_rate INT DEFAULT 1;
DECLARE period INT DEFAULT 0;
SET period = (select timestampdiff(second, (select lastaccessed from gamerows where id = row_id), now()));
update gamerows
set fuel = fuel + period * fuel_rate
where id = row_id;
END fuel;
//
delimiter ;

-- updates a given row's lastaccessed column
-- drop procedure upd_r_access;
delimiter //
CREATE procedure upd_r_access(row_id int)
upd_r_access: BEGIN
UPDATE gamerows
SET lastaccessed = now()
WHERE id = row_id;
END upd_r_access;
//
delimiter ;

-- updates a given row's hospital column
-- drop procedure upd_r_hospital;
delimiter //
CREATE procedure upd_r_hospital(row_id int)
this_proc: BEGIN
DECLARE period, chng, hsptl INT DEFAULT 0;
SET hsptl = (select hospital from gamerows where id = row_id);
IF hsptl <= 0 THEN
LEAVE this_proc;
END IF;
SET period = (select timestampdiff(second, (select lastaccessed from gamerows where id = row_id), now()));
SET chng = (select period * (1 + (select hospital_level from players where players.id = row_id)));
SET chng = (select IF(chng > hsptl, hsptl, chng));
UPDATE gamerows
SET defenders = defenders + chng,
hospital = hospital - chng
WHERE id = row_id;
END this_proc;
//
delimiter ;

-- procedure to update a row
-- drop procedure upd_all;
delimiter //
CREATE PROCEDURE upd_all(row_id int)
BEGIN
call upd_r_fuel(row_id);
call upd_r_money(row_id);
call upd_r_hospital(row_id);
call upd_r_access(row_id);
END;
//
delimiter ;

-- procedure to test that things are working fine
-- drop procedure test_row_2;
delimiter //
CREATE PROCEDURE test_row_2()
BEGIN
call upd_all(2);
select id, money, fuel, attackers, defenders, hospital from gamerows where id = 2;
END;
//
delimiter ;

-- ============================================================
--      DATABASE INITIALIZATION 
-- ============================================================

/*
Now that we've entered our two main tables,
let's populate them with some values.
*/

-- Let's make 50 rows in gamerows. 
CALL fillgamerows(50);

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

UPDATE gamerows
SET hospital = 1000
WHERE id = 2;
