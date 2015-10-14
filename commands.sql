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
morale DOUBLE DEFAULT 0,
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
losses INT DEFAULT 0,
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

/* Perhaps it would be smart to add this to the buy_item proc */
-- procedure to buy attackers
delimiter //
CREATE PROCEDURE purchase_attackers(row_id INT, num2buy INT)
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

/*
Scan takes a row id and updates the corresponding row and the next
9 corresponding rows.

The parameter "display" is a TINYINT, which is what BOOLEAN is
an alias for in MySQL, with 0 being false.

DEVNOTE - Change income so that rather than "fuel_rate * fgs", 
it's something more interesting like "POW(1.2, num_generators)"
*/
CREATE PROCEDURE scan(row_id INT, display TINYINT)
BEGIN

DECLARE fuel_rate, money_rate DOUBLE(2, 1) DEFAULT 1.2;

UPDATE gamerows
SET period = timestampdiff(second, lastaccessed, now()),
healed = IF(timestampdiff(second, lastaccessed, now()) * (1 + hospital_level) > hospital, hospital, timestampdiff(second, lastaccessed, now()) * (1 + hospital_level))
WHERE id >= row_id AND id <= row_id + 9 AND owner != 0;

UPDATE gamerows
SET fuel = fuel + (period * POW(fuel_rate, fgs)),
money = money + (period * POW(money_rate, mgs)),
hospital = hospital - healed,
defenders = defenders + healed,
morale = IF(morale >= 100, 100, morale + (period / 60)),
lastaccessed = now()
WHERE id >= row_id AND id <= row_id + 9 AND owner != 0;

SELECT gamerows.ID, gamerows.ownerusername AS Owner, gamerows.defenders + gamerows.attackers AS Forces, gamerows.Money, gamerows.Fuel, ROUND(gamerows.morale) AS Morale
FROM gamerows
LEFT JOIN players
ON players.id = gamerows.owner
WHERE gamerows.id >= row_id
AND gamerows.id <= row_id + 9
AND display != 0;

END
//

CREATE PROCEDURE debug_scan(row_id INT, display TINYINT)
BEGIN
CALL scan(row_id, 0);
SELECT ID, ownerusername AS Owner, Attackers, Defenders, Money, Fuel, MGS, FGS, Hospital, hospital_level AS H_lvl, attack_level AS attack, defense_level AS defense
FROM gamerows
WHERE row_id = id
AND display != 0;
END
//

/*
Buy a fuel or money generator
row_id : the row purchasing the item,
item: the type to buy
0 - money generator, 1 - fuel generator, 2 - hospital level, 3 - attack level, 4 - defense level
*/
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
SET cost = 3600 * POW(2, attack);
WHEN 4 THEN
SET cost = (3600 / 2) * POW(2, defense);
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

/* this proc will need to be updated later */
CREATE PROCEDURE show_costs(row_id INT)
BEGIN
SELECT POW(2, mgs) AS "Next Money", 
POW(2, fgs) AS "Next Fuel",
POW(2, hospital_level) AS "Next Hospital",
3600 * POW(2, attack_level) AS "Next Attack",
(3600 / 2) * POW(2, defense_level) AS "Next Defense"
FROM gamerows
WHERE id = row_id;
END
//

/*
We need a procedure to send resources from one row
to another; attack already takes care of sending attackers
*/
CREATE PROCEDURE send_resources(source_row INT, destination_row INT, money_sent INT, fuel_sent INT)
this_proc: BEGIN
    DECLARE flag, row_owner, row_owner2 INT DEFAULT 0;
    SELECT owner, IF(money >= money_sent AND fuel >= fuel_sent, 1, 0) FROM gamerows WHERE id = source_row INTO row_owner, flag;
    SELECT owner FROM gamerows WHERE id = destination_row INTO row_owner2;

    /* If the user tries to send resources to a row he/she doesn't own */
    IF row_owner != row_owner2 THEN
        LEAVE this_proc;
    END IF;

    UPDATE gamerows
    SET money = money - money_sent, fuel = fuel - fuel_sent
    WHERE id = source_row AND flag = 1;

    UPDATE gamerows
    SET money = money + money_sent, fuel = fuel + fuel_sent
    WHERE id = destination_row AND flag = 1;

END this_proc
//

/*
We need a procedure to allow a player to start a new row
*/
CREATE PROCEDURE found_new_row (source_row INT, new_row INT)
BEGIN
END
//

/*
If a row is destroyed it must be reset to default values.
If attacking_row = 0, then we're not going to grant
any loot to any attacking row, since there was none
(Example: If a player wanted to delete his/her own row,
attacking_row would be 0)
*/
CREATE PROCEDURE destroy_row (attacking_row INT, dying_row INT)
BEGIN
    DECLARE dm, df, dforces INT;
    CREATE TEMPORARY TABLE IF NOT EXISTS deadrow (
        SELECT * FROM gamerows WHERE id = dying_row
    );
    SELECT money, fuel, hospital + defenders + attackers
    FROM deadrow
    INTO dm, df, dforces;

	UPDATE gamerows
	SET owner=DEFAULT(owner), ownerusername=DEFAULT(ownerusername),
	morale=DEFAULT(morale), defenders=DEFAULT(defenders), attackers=DEFAULT(attackers),
	money=DEFAULT(money), fuel=DEFAULT(fuel), mgs=DEFAULT(mgs), fgs=DEFAULT(fgs),
	dgs=DEFAULT(dgs), investments=DEFAULT(investments), investors=DEFAULT(investors),
    hospital=DEFAULT(hospital), hospital_level=DEFAULT(hospital_level),
    attack_level=DEFAULT(attack_level), defense_level=DEFAULT(defense_level),
	lastaccessed=NOW()
	WHERE id=dying_row;

    /* give the victor some prizes! */
    UPDATE gamerows
    SET money = money + dm,
    fuel = fuel + df,
    attackers = attackers + dforces
    WHERE id = attacking_row AND id != 0;

    DROP TABLE IF EXISTS deadrow;
END
//

/* helper procedure used for attack() */
/* It first deducts from the defender's
defenders, and then from the attackers if 
need be. If the defender wins a defense battle
then the defender might not need to lose their
attackers, for example */
CREATE PROCEDURE assign_losses(row_id INT, deduction INT)
BEGIN
    DECLARE num_defenders, num_attackers INT;
    SELECT attackers, defenders
    FROM gamerows
    WHERE id = row_id
    INTO num_attackers, num_defenders;

    SET num_defenders = num_defenders - deduction;
    IF num_defenders < 0 THEN
        SET deduction = ABS(num_defenders);
        SET num_defenders = 0;
        SET num_attackers = num_attackers - deduction;
        SET num_attackers = IF(num_attackers < 0, 0, num_attackers);
    END IF;

    UPDATE gamerows
    SET defenders = num_defenders,
    attackers = num_attackers
    WHERE id = row_id;
END
//

/*
Attack a row
If owner of source_row is same as owner of destination_row, 
just transfer units instead

I realize the function is really ugly, I might rewrite it
eventually. For now it gets the job done. There might be 
bugs.
*/
CREATE PROCEDURE attack(source_row INT, destination_row INT, attackers_sent INT)
this_proc: BEGIN
    DECLARE dmoney, dfuel, money_loot, fuel_loot, attacking_player, defending_player, att_lvl, def_lvl, attacker_home_forces, defending_forces, attacker_fuel, fuel_cost, distance INT;
    DECLARE AF, DF, CF DOUBLE DEFAULT 0;
    SET attackers_sent = abs(attackers_sent), source_row = abs(source_row), destination_row = abs(destination_row);
    SELECT ABS(source_row - destination_row) INTO distance;
    SELECT gamerows.fuel, gamerows.attackers, gamerows.owner, gamerows.attack_level FROM gamerows WHERE id = source_row  INTO attacker_fuel, attacker_home_forces, attacking_player, att_lvl;
    SELECT owner, attackers + defenders, defense_level, money, fuel FROM gamerows WHERE id = destination_row INTO defending_player, defending_forces, def_lvl, dmoney, dfuel;
    SELECT distance * attackers_sent INTO fuel_cost;

IF fuel_cost > attacker_fuel OR attackers_sent > attacker_home_forces OR attacking_player < 1 THEN
    LEAVE this_proc;
END IF;

IF attacking_player = defending_player THEN
    UPDATE gamerows as g
    SET g.attackers = g.attackers - attackers_sent,
    g.fuel = g.fuel - fuel_cost
    WHERE id = source_row;
    UPDATE gamerows as g
    SET g.attackers = g.attackers + attackers_sent
    WHERE id = destination_row;
ELSEIF defending_player < 1 THEN
    select "There's nobody here!";
ELSEIF attacking_player != defending_player AND defending_player > 0 THEN
    SET AF = attackers_sent * POW(1.2, att_lvl);
    SET DF = defending_forces * POW(1.2, def_lvl);
    SET CF = AF - DF;

    IF CF >= 0 THEN
        SET AF = CF,
        money_loot = IF(AF * 50 > dmoney, dmoney, AF * 50), 
        fuel_loot = IF(AF * 50 > dfuel, dfuel, AF * 50);
        
        /* update the defender */
        CALL assign_losses(destination_row, DF / POW(1.2, def_lvl) );

        UPDATE gamerows
        SET money = money - money_loot,
        fuel = fuel - fuel_loot,
        hospital = hospital + (DF / POW(1.2, def_lvl) * 7 / 12),
        defenders = defenders + (DF / POW(1.2, def_lvl) * 1 / 12),
        losses = losses + (DF / POW(1.2, def_lvl) ),
        morale = morale - 10
        WHERE id = destination_row;

        /* update the attackers */
        UPDATE gamerows
        SET money = money + money_loot,
        fuel = fuel + fuel_loot,
        attackers = attackers - ( 2 / 3 * (DF / POW(1.2, def_lvl)) ),
        morale = morale + IF(morale < 90, RAND() * 5, 0)
        WHERE id = source_row;

        /* if the defender's row has its morale brought to 0, destroy it. */
        IF (SELECT morale FROM gamerows WHERE id = destination_row) <= 0 THEN
            CALL destroy_row(source_row, destination_row);
        END IF;

    ELSEIF CF < 0 THEN
        /* The attacker has been defeated so doesn't receive any loot */
        /* Nor does the attacking player recieve a cut of the losses */
        SET CF = ABS(CF);
        CALL assign_losses(destination_row, AF / POW(1.2, def_lvl) );

        UPDATE gamerows
        SET hospital = hospital + (AF / POW(1.2, def_lvl) * 7 / 12),
        defenders = defenders + (AF / POW(1.2, def_lvl) * 1 / 12),
        losses = losses + (AF / POW(1.2, def_lvl) )
        WHERE id = destination_row;

        UPDATE gamerows
        SET attackers = attackers - attackers_sent,
        morale = morale - RAND() * 5 
        WHERE id = source_row;
    END IF;
END IF;

END this_proc
//

delimiter ;

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
SET fuel = 1000,
attackers = 100
WHERE id = 2;

UPDATE gamerows
SET attackers = 50,
money = 3000,
fuel = 3000
WHERE id = 5;

UPDATE gamerows
SET attackers = 200,
money = 20000
WHERE id = 6;
