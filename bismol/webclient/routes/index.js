var express = require('express');
var router = express.Router();


/* GET home page. */
router.get('/', function(req, res, next) {
  //res.render('index', { title: 'Data Visualization' });
  res.sendFile(__dirname + '/../public/index.html');
});

router.get('/map', function(req, res) {
  console.log("HERRE");
  res.render('map');
});

module.exports = router;
