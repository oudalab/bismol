var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  //res.render('index', { title: 'Data Visualization' });
  res.sendFile(__dirname + '/../public/index.html');
});

module.exports = router;
