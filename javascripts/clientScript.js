/*
Copyright 2015 Joseph Burger <candyapplecorn@gmail.com>, Alexander McNulty and Nicholas Tarn, all rights reserved.
To use under MIT license, all copyrights must be perserved.
Contact me at 'candyapplecorn@gmail.com' if you would like to use this,
*/

/*
Client side scripts
*/
// Will use socket.io to communicate with server rather than ajax or post/get
var socket = io();

// Clean out all the inputs (Remove those XXX's)
function cleanInputs(){
    $('input').each(function(key, value){$(value).val('');});
}

/*
For debugging purposes, set username and password to Alex's
*/
if (false){
    $("#login-box div form li:nth-child(1) input").val('joe');
    $("#login-box div form li:nth-child(2) input").val('betterpassword');
    
    // email, username, password, confirm-password
    $("#signup-box  li:nth-child(1) input").val('zap@gmail.com');
    $("#signup-box  li:nth-child(2) input").val('zap');
    $("#signup-box  li:nth-child(3) input").val('zap');
    $("#signup-box  li:nth-child(4) input").val('zap');
}
/*
Attach an event listener to the login button. When clicked, it will
send the contents of the username and password fields to app.js. Then
the fields will be cleared
*/
(function(){
    var username = $("#login-box div form li:nth-child(1) input"),
    password = $("#login-box div form li:nth-child(2) input"),
    button = $('#login-box form button');

$(button).click(function(event){ 
    event.preventDefault();
    if ($('#login').prop('text').toString().search("In") != -1 && $(username).prop('value') != '') {
        socket.emit('login', [$(password).prop('value'), $(username).prop('value')]);
        cleanInputs();
        /*$(password).val('');
        $(username).val('');*/
    }
});
$('#login').click(function(event){
    if ($('#login').prop('text').toString().search("In") == -1)
        socket.emit('logout');
});
}());

/*
Attach an event listener to the register button.
*/
(function(){
    // email, username, password, confirm-password
    var email = $("#signup-box  li:nth-child(1) input"),
    username = $("#signup-box  li:nth-child(2) input"),
    password= $("#signup-box  li:nth-child(3) input"),
    confirm_password = $("#signup-box  li:nth-child(4) input"),
    button = $('#signup-box button');
    var arr = [email, username, password, confirm_password], invalid = false;

$(button).click(function(event){ 
    event.preventDefault();
    
    for (var key in arr)
        if ($(arr[key]).val() == '')
            invalid = true;
    if ($(password).val() != $(confirm_password).val())
        invalid = true;
    
    if (invalid) {
        alert("Invalid input");
    }
    else {
        socket.emit('register', {
            email: email.val(),
            username: username.val(),
            password: password.val()
        });
    }
    cleanInputs();
});
}());

// If a user registers, then automatically log them in
socket.on('auto-login', function(userinfo){
    socket.emit('login', [userinfo.password, userinfo.username]);
});

// Hide the loginbox if a successful login
socket.on('login-success', function(){
    $("#login-box").toggle('slow');
    $("#signup-box").hide('slow');
    $('#login').prop('text', "Log Out");
    socket.emit('myRows'); // Refresh "my rows"
    socket.emit('scan', 1);
});
socket.on('logout', function(){
    $("#login-box").toggle('slow');
    $("#signup-box").hide('slow');
    $('#login').prop("text", "Log In");
});

/*
Attach a listener to the buy attackers form
*/
(function(){
    var source = $('#buy-attacker-form div:nth-child(1) input'),
    target = $('#buy-attacker-form div:nth-child(2) input'),
    button = $("#buy-attacker-form button");

$(button).click(function(event){ 
    event.preventDefault();
    if ($.isNumeric($(target).val()) && $.isNumeric($(source).val()))
        socket.emit('buy-attacker', {
            source: source.val(), 
            attackers: target.val()
        });
    cleanInputs();
    window.setTimeout(function(){
        socket.emit('scan', $("#map td:nth-child(1)").html());
        socket.emit('myRows'); // Refresh "my rows"
    }, 1000);
});
}());
/*
Attach an event listener to the Scan button
*/
(function(){
    var input = $('#scan-form input'),
    button = $("#scan-form button");

$(button).click(function(event){ 
    event.preventDefault();
    if ($.isNumeric($(input).val())) {
        socket.emit('scan', Math.floor($(input).val() / 10) * 10);
    }
    cleanInputs();
});
}());

// Upon successful scan, receive the TH and TR's, and insert them into the DOM
socket.on('scan', function(trth) {
    var TH = $("div.row:nth-child(3) > div:nth-child(1) > table:nth-child(1) > thead:nth-child(1)"),
        TR = $('div.row:nth-child(3) > div:nth-child(1) > table:nth-child(1) > tbody:nth-child(2)');
    TH.html(trth[0]);
    TR.html(trth[1].join('')) 

    socket.emit('myRows'); // Refresh "my rows"
});

/*
Buy row listener
*/
(function(){
    var source = $('#buy-row-form div:nth-child(1) input'),
    target = $('#buy-row-form div:nth-child(2) input'),
    button = $("#buy-row-form button");

$(button).click(function(event){ 
    event.preventDefault();
        if ($.isNumeric($(target).val()) && $.isNumeric($(source).val()))
        socket.emit('found_new_row', {
            target: target.val(),
            source: source.val()
        });
        // Scan the range containing the target row, to show the results.
        window.setTimeout(function(){ 
            socket.emit('scan', Math.floor($(target).val() / 10) * 10 + 1);
            cleanInputs();
        }, 1000);
        //socket.emit('scan', $("#map td:nth-child(1)").html());
        socket.emit('myRows'); // Refresh "my rows"
    });
}());

/*
Transport Event Listener
*/
(function(){
var source = $('#transport-form .buttonField div:nth-child(1) input'),
    target = $('#transport-form .buttonField div:nth-child(2) input'),
    money = $('#transport-form .buttonField div:nth-child(3) input'),
    fuel = $('#transport-form .buttonField div:nth-child(4) input'),
    attackers = $('#transport-form .buttonField div:nth-child(5) input'),
    button = $('#transport-form button');
var arr = [source, target, money, fuel, attackers];

$(button).click(function(event){ 
    event.preventDefault();
    if (arr.filter(function(elem){ return $.isNumeric(elem.val()) || elem.val() == ''; }).length == 5 && $.isNumeric($(source).val()) && $.isNumeric($(target).val())) {
        socket.emit('transport', {
            source: source.val(),
            target: target.val(),
            money: money.val(),
            fuel: fuel.val(),
            attackers: attackers.val()
        });
        // Scan the range containing the target row, to show the results.
        window.setTimeout(function(){ 
            socket.emit('scan', Math.floor($(target).val() / 10) * 10 + 1);
            cleanInputs();
        }, 1000);
        socket.emit('myRows'); // Refresh "my rows"
    }
});
}());
/*
Attack event listener
*/
(function(){
var source = $('#attack-form .buttonField div:nth-child(1) input'),
    target = $('#attack-form .buttonField div:nth-child(2) input'),
    attackers = $('#attack-form .buttonField div:nth-child(3) input'),
    button = $('#attack-form button');

$(button).click(function(event){ 
    event.preventDefault();
    if ($.isNumeric($(source).val()) && $.isNumeric($(attackers).val()) && $.isNumeric($(target).val())) {
        socket.emit('attack', {
            source: $(source).val(), 
            target: $(target).val(), 
            attackers: $(attackers).val() 
        });
        // Scan the range containing the target row, to show the results.
        window.setTimeout(function(){ 
            socket.emit('scan', Math.floor($(target).val() / 10) * 10 + 1);
        }, 1000);
    }
});
}());
/*
Attach event listener to catch "My Rows"
*/
socket.on('myRows-success', function(trth) {
    if (!trth) {
        socket.emit('myRows');
        return;
    }
    var TH = $("table.outward > thead:nth-child(1)"),
        TR = $("table.outward > tbody:nth-child(2)"),
        PURCHASE_BUTTONS = '<tr><td></td><td class="add"></td><td class="add"></td><td class="add"></td><td class="add"></td><td class="add"></td><td class="add"></td><td class="add"><button class="button tiny">Buy</button></td><td class="add"><button class="button tiny">Buy</button></td><td class="add"><button class="button tiny">Buy</button></td><td class="add"><button class="button tiny">Buy</button></td><td class="add"><button class="button tiny">Buy</button></td></tr>'

    TH.html(trth[0]);
    TR.html(trth[1].join(PURCHASE_BUTTONS) + PURCHASE_BUTTONS);

    /* 
    Getting this to work took me over an hour
    Which I'm not really proud of admitting, but it was hard
    What I needed was for each button in the MyRows section to
    know both WHAT kind of item it's for, and which row it's 
    supposed to buy that item at. Since there are no id's in these
    dynamically generated rows, I had to do it via loops
    */
    var rows = $('table.outward tbody tr'),
        buttons = $('table.outward tbody tr button');

    for (var begin = 0, end = buttons.length; begin < end; begin += 1) {
        // Okay seriously this one line right here, this one line right here
        // See this line, take a good look at it
        // Make sure you're glaring and making a really mean face
        // I mean this one line right here, he deserves it
        // He's one bad line. real real bad. Taking all my time
        // On multiple days this line has been the cause of crashes and errors
        // this line right here
        // go ahead, glare at 'im
        // he's a jerk
        var rownum = 1 + Math.floor(begin / 5) * 2
        // really though it's my fault for being bad at math

        $(buttons[begin]).prop('item', begin % 5);
        $(buttons[begin]).prop('row', $('table.outward > tbody:nth-child(2) > tr:nth-child(' + rownum  + ') > td:nth-child(1)').html());
        $(buttons[begin]).click(function(event){
            // Now can call purchase item; have the item type and the row 
            socket.emit('purchase-item', {row: this.row, item: this.item});
        });
    }
});
