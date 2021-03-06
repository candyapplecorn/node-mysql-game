/*
Copyright 2015 Joseph Burger <candyapplecorn@gmail.com>, Alexander McNulty and Nicholas Tarn, all rights reserved.
To use under MIT license, all copyrights must be perserved.
Contact me at 'candyapplecorn@gmail.com' if you would like to use this,
*/
// load dependencies 
var Promise = require('bluebird');
var fs = Promise.promisifyAll(require('fs')),
    mime = require('mime'),
    express = require('express'),
    mysql = Promise.promisifyAll(require('mysql')),
    cookieParser = require('cookie-parser');

Promise.promisifyAll(require("mysql/lib/Connection").prototype);
Promise.promisifyAll(require("mysql/lib/Pool").prototype);

// load database credentials
var credentialsJSON = JSON.parse(fs.readFileSync('credentials.json', 'utf8'));
// configure express 
var app = express();
app.use(cookieParser());

// Create mysql database
var pool = mysql.createPool({
    connectionLimit: 10,
    host     : 'localhost',
    user     : credentialsJSON.username,
    password : credentialsJSON.password,
    database : credentialsJSON.database,
});

/*
This piece of middleware intercepts all requests and if they don't fall under
a described subset of requests, the response becomes status 401 unauthorized
*/
app.use('*', function(req, res, next) {
    if (req.originalUrl == '/cache.appcache') {
        // Send the appcache with proper content header etc
        fs.readFile('cache.appcache', function(err, content){
            res.writeHead(200, {
                'Content-Type': 'text/cache-manifest; charset = UTF-8',
                'Cache-Control': 'no-cache'
            });
            res.write(content);
            res.end();
        });
    }
    else if (req.originalUrl == '/' || ['/pub', '/stylesheets', '/javascript'].filter(function(url){
        return req.originalUrl.search(url) == 0;
    }).length)
        next(); // Call the next router
    else
        res.sendStatus(401); // unauthorized
});
/*
Another piece of middleware - More can be listed
*/
app.use(function(req, res, next){ 
    next(); 
});

/*
Authentication service
*/
app.use(function(req, res, next){
    // Check the user's cookie for the secret string
    // If not found, auth = false
    /*Authentication Function - Performs db transaction
      get user's cookie.sstring and uname
      lookup in db*/
    
    // If found && now() - last.login > 60 mins, user is logged in
    // auth = true
    next();
});
app.use(function(req, res, next){ 
    if ("is authenticated()"){
        req.auth = true;
        next();
    }
    else 
        res.send("You're not authenticated bro");
});
/*
*/

// This is the final piece of middleware and replaced "app.get('/')" in
// the application. No middleware can be called after express.static
app.use(express.static('./'));

/*
 * Socket.IO stuff
 */
var http = require('http').Server(app);
var io = Promise.promisifyAll(require('socket.io'))(http);

io.on('connection', function(socket){
    // Is these are null, socket isn't logged in.
    var username, access;

    /*
    Authenticate takes a username and password and checks for
    a match in the db. If one is found, set the variables username
    and access.
    */
    function authenticate(unpw){
        // Protect against injection by binding params
        var sql = "SELECT * FROM ?? WHERE ?? = ? AND ?? = md5(?)";
        var inserts = ['players', 'username', unpw[1], 'password', unpw[0]];
        sql = mysql.format(sql, inserts);

        // Perform the query
        pool.query(sql, function(err, rows, fields){
            if (err) throw err;
            if (rows && rows.length == 1) {
                access = Date.now(), username = rows[0].username;
                console.log(username, " has successfully logged in at ", new Date(access));
            }
            socket.emit('login-success');
        });
    }
    // Checks to see if the user is already logged in
    function authenticated () {
        if (username && username != '' && access - Date.now() < 60 * 60 * 1000) {
            access = Date.now();
            return true;
        } else return false;
    }
    function scan(row){
        row = Number(row); // Convert it to a numeric type
        sql = mysql.format("CALL scan(?, 0)", [row]);
        // Perform the query
        pool.query(sql, function(err, rows, fields){ if (err) throw err; });
    }
    socket.on('login', function(unpw){ authenticate(unpw); });
    socket.on('logout', function(){ 
        username = null, access = null;
        socket.emit('logout');
    });
    socket.on('scan', function(row) {
        if (!authenticated()) return;
        row = Number(row); // Convert it to a numeric type
        scan(row);
        var TableHeaders = '<TR>', TableRows = [], inserts = [row, row + 9];
        // Make a query that returns multiple rows; each row is stores as an array; result is a multi-d array
        var sql = "SELECT gamerows.ID, gamerows.ownerusername AS Owner, gamerows.defenders + gamerows.attackers AS Forces, gamerows.Money, gamerows.Fuel, ROUND(gamerows.morale) AS Morale FROM gamerows LEFT JOIN players ON players.id = gamerows.owner WHERE gamerows.ID >= ? AND gamerows.id <= ?";
        sql = mysql.format(sql, inserts);
        pool.query(sql, function(err, rows, fields){ 
            if (err) throw err; 
            // rows is an array with up to 10 elements. Each element is an object
            // with the keys ID, Owner, Forces, Money, Fuel and Morale
            for (index in rows){ // index should be 0 - 10
                TableRows[index] = "<TR>";
                for (key in rows[index]){
                    if (index == 0) TableHeaders += '<TH>' + key + '</TH>'; 
                    TableRows[index] += '<TD>' + rows[index][key] + '</TD>';
                }
                TableRows[index] += '</TR>';
            }
            TableHeaders += '</TR>';
            socket.emit('scan', [TableHeaders, TableRows ] );
        });
    });
    /*
     User Registration - A tedious process
     */
    socket.on('register', function(userinfo) {
        // Test information - all fields must be 30 characters or shorter
        // Using the ? to place variables into SQL queries automatically
        // escapes the data
        for (var key in userinfo) 
            if (userinfo[key].length > 30 || userinfo[key].length == 0)
                return;
        // This regular expression can check for a valid email format
        var email_pattern = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/i
        var valid_email = email_pattern.test(userinfo.email);
        // Test for a valid email
        if (!valid_email) return;

        // Username and PW are non-zero length strings and are under 31 characters long.
        // The email is valid, syntactically speaking.
        // The next step would be to check if the username is already in use
        pool.query(mysql.format("SELECT id FROM players WHERE username = ? LIMIT 1", [userinfo.username]),
            function(err, rows, fields){
                if (err) throw err;
                // If the username isn't taken, check if the email is.
                if (!rows || !rows.length)
            pool.query(mysql.format("SELECT id FROM players WHERE email = ? LIMIT 1", [userinfo.email]),
                function(err, rows, fields){
                    if (err) throw err;
                    if (rows.length) return;
                    // If the program has made it this far then the username
                    // and email are unique.
                    // Normally a verification email would be sent out, but since this
                    // is a hobbyist project for a club and I'm pinched for time, 
                    // the program will just liberally allow any unique username +
                    // email combination to register. If I were to implement this I
                    // might use a node module for mailing, or make a system call to
                    // a linux script that sends mail.
                    pool.query(
                        mysql.format("CALL add_user(?, ?, ?)", [
                            userinfo.username,
                            userinfo.password,
                            userinfo.email
                            ]
                            ), 
                        function(err, rows, fields){
                            if (err) throw err;
                            console.log("Successfully registered " + userinfo.username + " at " + new Date());
                            socket.emit('auto-login', {
                                username: userinfo.username, 
                                password: userinfo.password
                            });
                        });
                });
            });
    });

    socket.on('myRows', function() {
        var TableHeaders = '<TR>', TableRows = [];
        if (!authenticated()) return;
        // Update each row.
        // For each row the player 'username' owns, call scan(row)
        var sql = "SELECT id FROM gamerows WHERE ownerusername = ?",
            inserts = [username];
        sql = mysql.format(sql, inserts);
        pool.query(sql, function(err, rows, fields) {
            if (err) throw err; 
            for (index in rows) 
                scan(rows[index]["id"]);
        });

        // Make a query that returns multiple rows; each row is stores as an array; result is a multi-d array
        sql = "SELECT ID, ownerusername AS Owner, Attackers, Defenders, Money, Fuel, Hospital, MGS, FGS, hospital_level AS H_lvl, attack_level AS attack, defense_level AS defense FROM gamerows WHERE ownerusername = ?",
        inserts = [username];
        sql = mysql.format(sql, inserts);
        pool.query(sql, function(err, rows, fields){ 
            if (err) throw err; 
            // rows is an array with up to 10 elements. Each element is an object
            // with the keys ID, Owner, Forces, Money, Fuel and Morale
            for (index in rows){ // index should be 0 - 10
                TableRows[index] = "<TR>";
                for (key in rows[index]){
                    if (index == 0) TableHeaders += '<TH>' + key + '</TH>'; 
                    TableRows[index] += '<TD>' + rows[index][key] + '</TD>';
                }
                TableRows[index] += '</TR>';
            }
            TableHeaders += '</TR>';
            socket.emit('myRows-success', [TableHeaders, TableRows ] );
        });
    });
    /*
    Purchase Item - Takes a row and an item type. 
    0 - money, 1 - fuel, 2 - hosp. level, 3 - attack. level, 4 - def. level
    */
    socket.on('purchase-item', function(info) {
        if (!authenticated()) return;
        //info.row = Number(info.row), info.item = Number(info.item);
        //if (!info.row || !info.item) return;
        scan(Number(info.row));
        var sql = "SELECT id FROM gamerows WHERE ownerusername = ? AND id = ?", inserts = [username, info.row];
        sql = mysql.format(sql, inserts);
        pool.query(sql, function(err, rows, fields) {
            if (err) throw err; 
            if (!rows) {
                console.log("No rows");
                return;
            }
            sql = "CALL purchase_item(?, ?)", inserts = [Number(info.row), Number(info.item)];
            sql = mysql.format(sql, inserts);
            pool.query(sql, function(err, rows, fields) { 
                if (err) throw err; 
                socket.emit('myRows-success', false);
            });
        });
    });
    /*
    found_new_row
    */
    socket.on('found_new_row', function(info) {
        if (!authenticated()) return;
        if (info.target == '' || info.target <= 0 || info.source == '' || info.source <= 0) return;
        info.source = Number(info.source), info.target = Number(info.target);
        scan(Number(info.target));
        scan(Number(info.source));

        pool.query(mysql.format("SELECT id FROM gamerows WHERE ownerusername = ? AND id = ?", [username, info.source]), function(err, rows, fields){
            if (err) {
                console.log(err);
                throw err;
            }
            if (!rows || !rows.length) {
                console.log(username + " doesn't own row " + info.source);
                return;
            }
            pool.query(mysql.format("CALL found_new_row(?, ?)", [info.source, info.target]), function(err, rows, fields) {
                if (err) {
                    console.log(err);
                    //throw err;
                }
                socket.emit('myRows-success');
                console.log(username + ' tried to purchase a row!');
            });
        });
    });

    /*
    Buy attackers, rewritten buy row code
    */
    socket.on('buy-attacker', function(info) {
    if (!authenticated() || Object.keys(info).length != 2) return;
    info.source = Number(info.source), info.attackers = Number(info.attackers);
    scan(info.source);
    scan(info.attackers);
    // Find out if the logged in player owns the source row
    var sql = "SELECT id FROM gamerows WHERE ownerusername = ? AND id = ?", inserts = [username, info.source];
    pool.query(mysql.format(sql, inserts), function(err, rows, fields) {
        if (err) throw err; 
        if (!rows) {
            console.log("Player tried to buy with a row they don't own");
            return;
        }
        // Perform the purchase
        pool.query(mysql.format(
                "CALL purchase_attackers(?, ?)",
                [info.source, info.attackers]
                ), function(err, rows, fields) {
                    if (err) throw err;
                    socket.emit('myRows-success');
                });
    });
    });
    /*
       Transport
    */
    socket.on('transport', function(info) {
        if (!authenticated()) return;
        scan(Number(info.source));
        scan(Number(info.target));
        // Find out if the logged in player owns the source row
        var sql = "SELECT id FROM gamerows WHERE ownerusername = ? AND id = ?", inserts = [username, info.source];
        sql = mysql.format(sql, inserts);
        if (info.money != '' && info.money > 0 || info.fuel != '' && info.fuel > 0)
        pool.query(sql, function(err, rows, fields) {
            if (err) throw err; 
            if (!rows) {
                console.log("Player tried to attack with a row they don't own");
                return;
            }
            // Perform the attack
            sql = "call send_resources(?, ?, ?, ?)", inserts = [info.source, info.target, info.money == '' ? 0 : info.money, info.fuel == '' ? 0 : info.fuel];
            sql = mysql.format(sql, inserts);
            pool.query(sql, function(err, rows, fields) {
                if (err) throw err; 
                if (!rows) {
                    console.log("No rows");
                    return;
                }
                console.log(username + " is transferring resources: " + info);
            });
            socket.emit('myRows-success');
        });
        if (info.attackers > 0)
            pool.query(mysql.format("CALL attack(?, ?, ?)", [info.source, info.target, info.attackers]), function(err, rows, fields) {
                if (err) throw err;
                socket.emit('myRows-success');
            });
        // Add in a check and query for attackers being sent as well
        console.log('recieved transport request');
    });
    /*
    Attack - Takes a source row, a destination row, and number of troops
    */
    socket.on('attack', function(info) {
        if (!authenticated()) return;
        scan(Number(info.source));
        scan(Number(info.target));
        // Find out if the logged in player owns the source row
        var sql = "SELECT id FROM gamerows WHERE ownerusername = ? AND id = ?", inserts = [username, info.source];
        sql = mysql.format(sql, inserts);
        pool.query(sql, function(err, rows, fields) {
            if (err) throw err; 
            if (!rows) {
                console.log("Player tried to attack with a row they don't own");
                return;
            }
            // Perform the attack
            sql = "call attack(?, ?, ?)", inserts = [info.source, info.target, info.attackers];
            sql = mysql.format(sql, inserts);
            pool.query(sql, function(err, rows, fields) {
                if (err) throw err; 
                if (!rows) {
                    console.log("No rows");
                    return;
                }
            });
            socket.emit('myRows-success');
            console.log(username + 'attacked row ' + info.target + ' from row ' + info.source + ' at ' + new Date());
        });
    });
    console.log('a user connected');
});
/*
 * Run the app
 */
http.listen(3000);
console.log("listening on port 3000");
