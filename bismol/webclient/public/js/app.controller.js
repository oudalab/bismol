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
		var svgMousedown = svgMousedown;
		var svgMousemove = svgMousemove;
		var svgMouseup = svgMouseup;
		var svgMouseout = svgMouseout;
		var toColor = toColor;
		var svg;
		var radius = 3;
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
			svg = d3.select("#graph")
				.append("svg")
				.attr("width", width)
				.attr("height", height);
				//.call(zoom);

			svg.on("mousedown", svgMousedown)
			   .on("mousemove", svgMousemove)
			   .on("mouseup", svgMouseup)
			   .on("mouseout", svgMouseout);

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
					.attr("class", "state")
					.attr("id", function (d) { return d.id; })
					.attr("cx", function (d) { return xScale(d.x); })
					.attr("cy", function (d) { return yScale(d.y); })
				    .attr("r", radius)
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
					.attr("class", "state")
					.attr("id", function(d) { d.id; })
					.attr("cx", function(d) { return d.x; })
					.attr("cy", function(d) { return d.y; })
				    .attr("r", radius)
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

		  	d3.select(this).classed("dragging", true);
		}

		function dragged(d) {
			var selection = d3.selectAll('.selected');
            svg.selectAll("rect.selection").remove();
            if(selection[0].indexOf(this) == -1) {
                selection = d3.select(this);
                selection.classed("selected", true)
                	.style("opacity", "1.0");
                var self = this;
                main.selectAll("circle")
                	.filter(function (x) { return self != this; })
                	.style("opacity", ".05");
            }  
            selection.each(function (d) {
            	d.x = xScale.invert(xScale(d.x) + d3.event.dx);
            	d.y = yScale.invert(yScale(d.y) + d3.event.dy);
            });
            selection
            	.attr("cx", function (d) { return xScale(d.x); })
			    .attr("cy", function (d) { return yScale(d.y); });
		}

		function dragended(d) {
			var selection = d3.selectAll('.selected');
			selection.each(function (d) { 
				socket.emit('point changed', d);
			});
			
			main.selectAll("circle")
				.style("opacity", "1.0");
			d3.selectAll(".selected").classed("selected", false);
		  	
		  	d3.select(this).classed("dragging", false);
		}

		//mouse functions for tooltip
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

		//mouse functions for multiselect
		function svgMousedown() {
			if(!d3.event.shiftKey) {
                d3.selectAll(".selected")
                	.classed("selected", false)
                d3.selectAll("circle")
                	.style("opacity", "1.0");
            }

            var p = d3.mouse(this);
            svg.append("rect")
               .attr({
                    class   : "selection",
                    x       : p[0],
                    y       : p[1],
                    width   : 0,
                    height  : 0
                });
		}

		function svgMousemove() {
			var s = svg.select("rect.selection");
            if(!s.empty()) {
                var p = d3.mouse(this),
                    d = {
                        x       : parseFloat(s.attr("x")),
                        y       : parseFloat(s.attr("y")),
                        width   : parseFloat(s.attr("width")),
                        height  : parseFloat(s.attr("height"))
                    },
                    move = {
                        x : p[0] - d.x,
                        y : p[1] - d.y
                    };
                if(move.x < 1 || (move.x * 2 < d.width)) {
                    d.x = p[0];
                    d.width -= move.x;
                } else {
                    d.width = move.x;       
                }

                if(move.y < 1 || (move.y * 2 < d.height)) {
                    d.y = p[1];
                    d.height -= move.y;
                } else {
                    d.height = move.y;       
                }
                s.attr(d);
                d3.selectAll(".state").each(function(state_data, i) {
                    if(!d3.select(this).classed("selected") && 
                        //inner circle inside selection frame
                        xScale(state_data.x) - radius >= d.x && xScale(state_data.x) + radius <= d.x + d.width && 
                        yScale(state_data.y) - radius >= d.y && yScale(state_data.y) + radius <= d.y + d.height)
	                    {
	                        d3.select(this)
		                        .classed("selection", true)
		                        .classed("selected", true);
		                    d3.selectAll(".state").each(function(data) {
		                    	if(!d3.select(this).classed("selected")) {
		                    		d3.select(this)
		                    			.style("opacity", ".05");
		                    	}
		                    	else {
		                    		d3.select(this)
		                    			.style("opacity", "1.0");
		                    	}
		                    });
	                    }
                });
            }
		}

		function svgMouseup() {
			//remove selection frame
            svg.selectAll("rect.selection").remove();

            //remove temporary selection marker class
            d3.selectAll('.state.selection').classed("selection", false);
		}

		function svgMouseout() {
			if(d3.event.relatedTarget != null && d3.event.relatedTarget.tagName != null 
				&& d3.event.relatedTarget.tagName == 'HTML') {
                //remove selection frame
                svg.selectAll("rect.selection").remove();

                //remove temporary selection marker class
                d3.selectAll('.state.selection').classed("selection", false);
            }
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