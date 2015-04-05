Gamma
=============

A web based chat client that allows channel based communications to fork into
separate, short-lived threads of conversation.

### Description

(WIP)

### Installation Instructions

Clone the repo and run `npm install` in the default directory.

After setting up MySQL on your machine (with the proper credentials in `configs/config.json`),
you need to compile all the Coffeescript to run the script that builds the MySQL tables.

First run `grunt` and then run `node ./bin/oneoff/init_db.js` until it says the initialization has finished.

`grunt nodemon` then starts the server and `grunt watch` is helpful for developing.

