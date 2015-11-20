/*
Client side scripts
*/
// Will use socket.io to communicate with server rather than ajax or post/get
var socket = io();

/*
For debugging purposes, set username and password to Alex's
*/
if (false){
    $("#login-box div form li:nth-child(1) input").val('alex');
    $("#login-box div form li:nth-child(2) input").val('password');
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
        $(password).val('');
        $(username).val('');
    }
});
$('#login').click(function(event){
    if ($('#login').prop('text').toString().search("In") == -1)
        socket.emit('logout');
});
}());

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
Attach an event listener to the Scan button
*/
(function(){
    var input = $("div.small-3:nth-child(4) > div:nth-child(4) > input:nth-child(1)"),
    button = $("div.small-3:nth-child(4) > button:nth-child(6)");

$(button).click(function(event){ 
    event.preventDefault();
    if ($.isNumeric($(input).val())) {
        socket.emit('scan', $(input).val());
    }
    $(input).val('');
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
        var rownum = (Math.floor(begin / 5) * 3) || 1;
        $(buttons[begin]).prop('item', begin % 5);
        $(buttons[begin]).prop('row', $('table.outward > tbody:nth-child(2) > tr:nth-child(' + rownum  + ') > td:nth-child(1)').html());
        $(buttons[begin]).click(function(event){
            // Now can call purchase item; have the item type and the row 
            socket.emit('purchase-item', {row: this.row, item: this.item});
        });
    }
});
