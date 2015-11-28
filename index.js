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
    if (req.originalUrl == '/' || ['/pub', '/stylesheets', '/javascript'].filter(function(url){
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
    Transport
    */
    socket.on('transport', function(info) {
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
        });
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
