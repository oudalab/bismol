(function() {
	'use strict';

	angular
		.module('messagesApp')
		.controller('appController', AppController);

	AppController.$inject = [
		'$scope'
	];

	function AppController($scope) {
		var counter = 0;
		var hasColor = false;
		var drag;
		var zoom;
		var tooltip;
		var isCreated = false;
		var xScale;
		var yScale;
		var xAxis;
		var yAxis;
		var dataset = [];
		var width = window.innerWidth * (5/6);
		var height = window.innerHeight * (5/6);
		var padding = 30;
		var drawChart = drawChart;
		var updateChart = updateChart;
		var zoomed = zoomed;
		var dragstarted = dragstarted;
		var dragged = dragged;
		var dragended = dragended;
		var mouseover = mouseover;
		var mousemove = mousemove;
		var mouseout = mouseout;
		var toColor = toColor;
		var svg;
		var main;
		var updatecounter = 0;

		var socket = io.connect();

		//zoom variable
		zoom = d3.behavior.zoom()
		  .scaleExtent([1, 10])
		  .on("zoom", zoomed);

		//drag/drop variable
		drag = d3.behavior.drag()
		  .on("dragstart", dragstarted)
		  .on("drag", dragged)
		  .on("dragend", dragended);

		//tooltip variable
		tooltip = d3.select("body")
		  .append("div")
		  .attr("class", "tooltip");

		socket.on('connected', function(data) {
			//for each element in data (i.e., for each row in the database table)
			//push the element onto the local dataset array
			data.forEach(function(message) {
				dataset.push(message);
			});

			//if the dataset is not empty (i.e., if the table had values to start)
			//then note that the table was created and draw the initial chart
			if (dataset.length > 0) {
				if(dataset[0].hasOwnProperty('color')) {
					hasColor = true;
				}
				isCreated = true;
				drawChart();
			}
		});

		socket.on('dbchanged', function(data) {
			//counter keeps track of how many rows that node has alerted us have changed
			counter++;
			//get the index in the local dataset array corresponding to the row that was updated in the database table
			var elementPos = dataset.map(function(x) {return x.id; }).indexOf(data.new_val.id);

			//if that index is valid and we haven't marked the table as created yet,
			//mark the table as created and draw it
			if(elementPos !== -1 && !isCreated) {
				if(dataset[0].hasOwnProperty('color')) {
					hasColor = true;
				}
				isCreated = true;
				drawChart();
			}

			//if the table is created, then we can simply update our local array with the new value
			if(isCreated) {
			    dataset[elementPos] = data.new_val;
			}
			//otherwise the table is not done yet, so push the data onto our local array
			else {
				dataset.push(data.new_val);
			}

			//if the counter is a multiple of the dataset length, and we're finished creating the table
			//then we can reset ou rcounter and update the chart 
			//this ensures that we update the chart only once once 'cycle' of database updates has been processed
			//(i.e., once each row has finished updating, then update the chart)
		    if(counter % dataset.length == 0 && isCreated) {
		    	counter = 0;
		    	updateChart(dataset);
		    }
		});

		//draw chart
		function drawChart() {
			//var date = new Date();
			//console.log(date.getTime());

			//create scale functions
			xScale = d3.scale.linear()
			    .domain([d3.min(dataset, function(d) { return d.x; }), d3.max(dataset, function(d) { return d.x; })])
			    .range([ padding, width - padding ]);

			yScale = d3.scale.linear()
			    .domain([d3.min(dataset, function(d) { return d.y; }), d3.max(dataset, function(d) { return d.y; })])
			    .range([ height - padding, padding ]);

			//define x and y axes
			xAxis = d3.svg.axis()
			    .scale(xScale)
				.orient('bottom')
				.ticks(0);

			yAxis = d3.svg.axis()
				.scale(yScale)
				.orient('left')
				.ticks(0);

			//create svg element
			svg = d3.select("div")
				.append("svg")
				.attr("width", width)
				.attr("height", height)
				.call(zoom);

			//create layer on top of svg to allow zoom/pan
			main = svg.append("g")
				.attr('width', width)
				.attr('height', height)
				.attr('class', 'main');

			if(hasColor) {
			    //create circles with color (pre-labeled data)
				main.selectAll("circle")
					.data(dataset)
					.enter()
					.append("circle")
					.attr("cx", function (d) { return xScale(d.x); })
					.attr("cy", function (d) { return yScale(d.y); })
				    .attr("r", 3)
				    .style("fill", function(d) { return toColor(d.color); })
				    .call(drag)
				    .on("mouseover", mouseover)
				    .on("mousemove", mousemove)
				    .on("mouseout", mouseout);
			}
			else {
				//create circles (un-labeled data)
				main.selectAll("circle")
					.data(dataset)
					.enter()
					.append("circle")
					.attr("cx", function (d) { return xScale(d.x); })
					.attr("cy", function (d) { return yScale(d.y); })
				    .attr("r", 3)
				    .call(drag)
				    .on("mouseover", mouseover)
				    .on("mousemove", mousemove)
				    .on("mouseout", mouseout);
			}

			//add x axis
			main.append("g")
				.attr("class", "x axis")
				.attr("transform", "translate(0," + (height - padding) + ")")
				.call(xAxis);

		    //add y axis
			main.append("g")
				.attr("class", "y axis")
				.attr("transform", "translate(" + padding + ",0)")
				.call(yAxis);
		}

		//update chart using animations
		function updateChart(updates) {
			//var date = new Date();
			//console.log(date.getTime());
			//update the x and y scales
			xScale = d3.scale.linear()
			    .domain([d3.min(updates, function(d) { return d.x; }), d3.max(updates, function(d) { return d.x; })])
			    .range([ padding, width - padding ]);

			yScale = d3.scale.linear()
			    .domain([d3.min(updates, function(d) { return d.y; }), d3.max(updates, function(d) { return d.y; })])
			    .range([ height - padding, padding ]);

			//update the circle positions, animating them as they go
			main.selectAll("circle")
			    .data(updates)
			    .transition()
			    .duration(.24 * updates.length)
			    .ease("linear")
			    .attr("cx", function (d) { return xScale(d.x); })
			    .attr("cy", function (d) { return yScale(d.y); });

			//update the x and y axis values
			xAxis = d3.svg.axis()
			    .scale(xScale)
				.orient('bottom')
				.ticks(0);

			yAxis = d3.svg.axis()
				.scale(yScale)
				.orient('left')
				.ticks(0);

			//and then animate the x and y axis changes
			main.select(".x.axis")
				.transition()
				.duration(.24 * updates.length)
				.ease("linear")
				.call(xAxis);

			main.select(".y.axis")
				.transition()
				.duration(.24 * updates.length)
				.ease("linear")
				.call(yAxis);
		}

		//handles zoom functionality
		function zoomed() {
		  	main.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
		}

		//drag/drop functions
		function dragstarted(d) {
		  	d3.event.sourceEvent.stopPropagation();

		  	var self = this;
		  	main.selectAll("circle")
		  		.filter(function (x) { return self != this; })
			    .style("opacity", ".05");

		  	d3.select(this).classed("dragging", true);
		}

		function dragged(d) {
		  	d3.select(this)
		    	.attr("cx", d.x = d3.event.x)
		    	.attr("cy", d.y = d3.event.y);
		  	d.x = xScale.invert(d3.event.x);
		  	d.y = yScale.invert(d3.event.y);
		}

		function dragended(d) {
			socket.emit('point changed', d);
			
			main.selectAll("circle")
				.style("opacity", "1.0");
		  	
		  	d3.select(this).classed("dragging", false);
		}

		//mouseover functions for tooltip
		function mouseover(d) {
		  	tooltip.style("visibility", "visible");
		}

		function mousemove(d) {
		  	tooltip.text(d.text);
		  	tooltip.style("top", (event.pageY-10)+"px").style("left",(event.pageX+10)+"px");
		}

		function mouseout(d) {
		  	tooltip.style("visibility", "hidden");
		}

		function toColor(d) {
			// Kelly's 22 colors of maximum contrast in order, with white omitted
			// (due to white background)
			// Paper at http://www.iscc.org/pdf/PC54_1724_001.pdf
			var kelly_colors_hex = [
				"#000000", // Black
			    "#FFB300", // Vivid Yellow
			    "#803E75", // Strong Purple
			    "#FF6800", // Vivid Orange
			    "#A6BDD7", // Very Light Blue
			    "#C10020", // Vivid Red
			    "#CEA262", // Grayish Yellow
			    "#817066", // Medium Gray

			    // The following don't work well for people with defective color vision
			    "#007D34", // Vivid Green
			    "#F6768E", // Strong Purplish Pink
			    "#00538A", // Strong Blue
			    "#FF7A5C", // Strong Yellowish Pink
			    "#53377A", // Strong Violet
			    "#FF8E00", // Vivid Orange Yellow
			    "#B32851", // Strong Purplish Red
			    "#F4C800", // Vivid Greenish Yellow
			    "#7F180D", // Strong Reddish Brown
			    "#93AA00", // Vivid Yellowish Green
			    "#593315", // Deep Yellowish Brown
			    "#F13A13", // Vivid Reddish Orange
			    "#232C16", // Dark Olive Green
			    ];

			if (parseInt(d) < kelly_colors_hex.length)
				return kelly_colors_hex[parseInt(d)];
			return 0; // Black
		}
	}
})();