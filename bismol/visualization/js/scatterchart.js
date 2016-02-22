var dictData = JSON.parse(embeddedData);

//convert the data into a 2D array
function convert(original) {
  var matrix = [];
  for(var key in original) { 
    matrix.push([ parseFloat(key), original[key] ]); 
  }
  return matrix;
}

var data = convert(dictData);

//set up the element's border elements   
var margin = {top: 20, right: 15, bottom: 60, left: 60}, 
  width = window.innerWidth * (5/6),
  height = window.innerHeight * (5/6),
  padding = 10;

//create the x and y scales    
var xScale = d3.scale.linear()
  .domain([d3.min(data, function(d) { return d[0]; }), d3.max(data, function(d) { return d[0]; })])
  .range([ padding, width - padding ]);

var yScale = d3.scale.linear()
  .domain([d3.min(data, function(d) { return d[1]; }), d3.max(data, function(d) { return d[1]; })])
  .range([ height - padding, padding ]);

//create the chart 
var chart = d3.select('div')
	.append('svg:svg')
	.attr('width', width + margin.right + margin.left)
	.attr('height', height + margin.top + margin.bottom)
	.attr('class', 'chart')

var main = chart.append('g')
	.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
	.attr('width', width)
	.attr('height', height)
	.attr('class', 'main')   
        
// draw the x axis
var xAxis = d3.svg.axis()
  .scale(xScale)
	.orient('bottom');

main.append('g')
	.attr('transform', 'translate(0,' + (height - padding) + ')')
	.attr('class', 'main axis')
	.call(xAxis);

// draw the y axis
var yAxis = d3.svg.axis()
	.scale(yScale)
	.orient('left');

main.append('g')
	.attr('transform', 'translate(' + padding + ',0)')
	.attr('class', 'main axis')
	.call(yAxis);

var g = main.append("svg:g"); 
g.selectAll("scatter-dots")
  .data(data)
  .enter()
  .append("circle")
  .attr("cx", function (d) { return xScale(d[0]); })
  .attr("cy", function (d) { return yScale(d[1]); })
  .attr("r", 3)
  .append("svg:title")
  .text(function(d) { return d[0] });
