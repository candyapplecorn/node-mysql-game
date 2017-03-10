# node-mysql-game
*Copyright 2015 Joseph Burger all rights reserved.
To use under MIT license, all copyrights must be perserved.
Contact at 'candyapplecorn@gmail.com' if you would like to use this.*

__node-mysql-game is a basic CRUD application utilizing an HTML front end, Javascript back end and SQL database, intended to be deployed on a linux server.__

Demo Video: https://youtu.be/WfJ6ikPaAZs  

Users will be able to register, log in and out, and perform operations to play the game. 

The front end, or user interface, is an html page that sends and recieves data using ajax. It makes use of a stylish front end framework called "foundation".

The back-end consists of several parts:

a.) The server-side code - originally written as PHP (see php-ver/), rewritten as Javascript. It consists of a single file (although any professional operation would break that file into many files), called "Server.js", which listens on a specified socket for connections.

b.) The database - MySQL. More than just tables, there are over 400 lines of stored procedures. This made changing from PHP to Javascript substantially easier, as rather than putting logic for the game into PHP, it was written in MySQL procedural query language.

c.) The hardware - The app is planned to be deployed on a linux cloud server. The shell scripts (files ending in .sh) are run on the server's command line.

Please contact if you find any bugs, security issues or have a suggestion!
