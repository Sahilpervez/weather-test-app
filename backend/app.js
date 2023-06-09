var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const cors = require('cors');
const PORT = process.env.PORT || 3000;


var weatherAPIRouter = require('./routes/weather');

var app = express();

app.use(cors({ origin: true, credentials: true }));
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'public-flutter')));

app.use('/api/weather', weatherAPIRouter);

module.exports = app;

app.listen(PORT,(req,res)=>{
    console.log('Server started at '+PORT);
})