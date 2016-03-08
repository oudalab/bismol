var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Data Visualization' });
});

router.get('/map', function(req, res) {
  res.render('map');
});

module.exports = router;
