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
hospital_level INT DEFAULT 0 CHECK (hospital_level >= 0),
healed INT DEFAULT 0,
period INT DEFAULT 0,
attack_level INT DEFAULT 0,
defense_level INT DEFAULT 0,
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
	money=DEFAULT(money), fuel=DEFAULT(fuel), mgs=1, fgs=1,
	dgs=DEFAULT(dgs), investments=DEFAULT(investments), investors='',
	lastaccessed=NOW()
	WHERE id=row_id;
END
//
delimiter ;

/* Just add this to the purchase proc! */
-- procedure to buy attackers
delimiter //
CREATE PROCEDURE buy_attackers(row_id INT, num2buy INT)
BEGIN
DECLARE attacker_cost, cost_per_attacker INT DEFAULT 2;
SET attacker_cost =  (SELECT ABS(num2buy * cost_per_attacker));
UPDATE gamerows
SET money = money - attacker_cost,
attackers = attackers + num2buy
WHERE id = row_id
AND attacker_cost <= money;
END;
//
delimiter ;

/*
Scan takes a row id and updates the corresponding row and the next
9 corresponding rows.

The parameter "display" is a TINYINT, which is what BOOLEAN is
an alias for in MySQL, with 0 being false.
*/
delimiter //
CREATE PROCEDURE scan(row_id INT, display TINYINT)
BEGIN

DECLARE fuel_rate, money_rate INT DEFAULT 1;

UPDATE gamerows
SET period = timestampdiff(second, lastaccessed, now()),
healed = IF(timestampdiff(second, lastaccessed, now()) * (1 + hospital_level) > hospital, hospital, timestampdiff(second, lastaccessed, now()) * (1 + hospital_level))
WHERE id >= row_id AND id <= row_id + 9;

UPDATE gamerows
SET fuel = fuel + (period * fuel_rate * fgs),
money = money + (period * money_rate * mgs),
hospital = hospital - healed,
defenders = defenders + healed,
lastaccessed = now()
WHERE id >= row_id AND id <= row_id + 9;

SELECT gamerows.ID, gamerows.ownerusername AS Owner, gamerows.defenders + gamerows.attackers AS Forces, gamerows.Money, gamerows.Fuel, gamerows.morale
FROM gamerows
LEFT JOIN players
ON players.id = gamerows.owner
WHERE gamerows.id >= row_id
AND gamerows.id <= row_id + 9
AND display != 0;

END
//
delimiter ;

delimiter //
CREATE PROCEDURE debug_scan(row_id INT, display TINYINT)
BEGIN
call scan(row_id, 0);
SELECT ID, ownerusername AS Owner, Attackers, Defenders, Money, Fuel, MGS, FGS, Hospital, hospital_level AS H_lvl, attack_level AS attack, defense_level AS defense
FROM gamerows
WHERE row_id = id
AND display != 0;
END
//
delimiter ;
/*
Buy a fuel or money generator
row_id : the row purchasing the item,
item : {0:money generator, 1:fuel generator, 2:hospital_level}
(Ternaries were used liberally)
*/
delimiter //
CREATE PROCEDURE purchase_generator(row_id INT, item INT)
BEGIN
DECLARE hsptl_lvl, money_generators, fuel_generators, cash INT;
CALL scan(row_id, 0);
SELECT mgs, fgs, money, hospital_level FROM gamerows WHERE id = row_id INTO money_generators, fuel_generators, cash, hsptl_lvl;
UPDATE gamerows
SET mgs = IF(item = 0, IF(pow(2, money_generators) > cash, money_generators, money_generators + 1), money_generators),
fgs = IF(item = 1, IF(pow(2, fuel_generators) > cash, fuel_generators, fuel_generators + 1), fuel_generators),
hospital_level = IF(item = 2, IF(pow(2, hsptl_lvl) > cash, hsptl_lvl, hsptl_lvl + 1), hsptl_lvl),
money = IF(item = 0, IF(pow(2, money_generators) > cash, cash, cash - pow(2, money_generators)), IF(item = 1, IF(pow(2, fuel_generators) > cash, cash, cash - pow(2, fuel_generators)), IF( item = 2, IF(pow(2, hsptl_lvl) > cash , cash, cash - pow(2, hsptl_lvl)), cash)))
WHERE id = row_id;
END
//
delimiter ;

delimiter //
CREATE PROCEDURE purchase_item(row_id INT, item INT)
this_proc: BEGIN
DECLARE cost, hsptl_lvl, money_generators, fuel_generators, cash, defense, attack INT DEFAULT 0;
DECLARE flag TINYINT DEFAULT 0;
CALL scan(row_id, 0);
SELECT mgs, fgs, money, hospital_level, attack_level, defense_level FROM gamerows WHERE id = row_id INTO money_generators, fuel_generators, cash, hsptl_lvl, defense, attack;

CASE item
WHEN 0 THEN
SET cost = POW(2, money_generators);
WHEN 1 THEN
SET cost = POW(2, fuel_generators);
WHEN 2 THEN
SET cost = POW(2, hsptl_lvl);
WHEN 3 THEN
SET cost = POW(2, attack);
WHEN 4 THEN
SET cost = POW(2, defense);
END CASE;

UPDATE gamerows
SET money = money - cost,
mgs = mgs + IF(item = 0, 1, 0),
fgs = fgs + IF(item = 1, 1, 0),
hospital_level = hospital_level + IF(item = 2, 1, 0),
attack_level = attack + IF(item = 3, 1, 0),
defense_level = defense + IF(item = 4, 1, 0)
WHERE id = row_id
AND cost <= cash;

END this_proc
//
delimiter ;
/*ELSIF item = 1 THEN
    SET flag = IF(POW(2, fuel_generators) <= cash, 1, 0);
ELSIF item = 2 THEN
    SET flag = IF(POW(2, hsptl_lvl) <= cash, 1, 0);
ELSIF item = 3 THEN
    SET flag = IF(POW(2, attack) <= cash, 1, 0);
ELSIF item = 4 THEN
    SET flag = IF(POW(2, defense) <= cash, 1, 0);*/

delimiter //
CREATE PROCEDURE show_costs(row_id INT)
BEGIN
SELECT POW(2, mgs) AS "Next Money", 
POW(2, fgs) AS "Next Fuel",
POW(2, hospital_level) AS "Next Hospital"
FROM gamerows
WHERE id = row_id;
END
//
delimiter ;
/*
Attack a row
*/

-- ============================================================
--      DATABASE INITIALIZATION 
-- ============================================================

/*
Now that we've entered our two main tables,
let's populate them with some values.
*/

-- Let's make some rows in gamerows. 
CALL fillgamerows(30);

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
