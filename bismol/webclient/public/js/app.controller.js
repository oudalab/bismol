(function() {
	'use strict';

	angular
		.module('messagesApp')
		.controller('appController', AppController);

	AppController.$inject = [
		'$scope'
	];

	function AppController($scope) {
		var g, chart, main, drag, zoom, tooltip;
		var counter = 0;
		$scope.xScale;
		$scope.yScale;
		$scope.xAxis;
		$scope.yAxis;
		$scope.data = [];
		$scope.margin = {top: 20, right: 15, bottom: 60, left: 60};
		$scope.width = window.innerWidth * (5/6);
		$scope.height = window.innerHeight * (5/6);
		$scope.padding = 10;
		$scope.createChartParameters = createChartParameters;
		$scope.drawChart = drawChart;
		$scope.zoomed = zoomed;
		$scope.dragstarted = dragstarted;
		$scope.dragged = dragged;
		$scope.dragended = dragended;
		$scope.mouseover = mouseover;
		$scope.mousemove = mousemove;
		$scope.mouseout = mouseout;

		var socket = io.connect();

		//zoom variable
		zoom = d3.behavior.zoom()
		  .scaleExtent([1, 10])
		  .on("zoom", $scope.zoomed);

		//drag/drop variable
		drag = d3.behavior.drag()
		  .on("dragstart", $scope.dragstarted)
		  .on("drag", $scope.dragged)
		  .on("dragend", $scope.dragended);

		//tooltip variable
		tooltip = d3.select("body")
		  .append("div")
		  .attr("class", "tooltip");

		socket.on('connected', function(data) {
			//cache the data on scope
			data.forEach(function(message) {
				$scope.data.push(message);
			});

			$scope.drawChart();
		});

		socket.on('dbchanged', function(data) {
			counter++;
			console.log("change");
		    var elementPos = $scope.data.map(function(x) {return x.id; }).indexOf(data.new_val.id);
		    $scope.data[elementPos] = data.new_val;
		    if(counter % $scope.data.length == 0) {
		    	counter = 0;
		    	d3.select("svg").remove();
		    	$scope.drawChart();
		    }
		});

		//set up axes and scales
		function createChartParameters() {
			//create the x and y scales    
			$scope.xScale = d3.scale.linear()
			    .domain([d3.min($scope.data, function(d) { return d.x; }), d3.max($scope.data, function(d) { return d.x; })])
			    .range([ $scope.padding, $scope.width - $scope.padding ]);

			$scope.yScale = d3.scale.linear()
			    .domain([d3.min($scope.data, function(d) { return d.y; }), d3.max($scope.data, function(d) { return d.y; })])
			    .range([ $scope.height - $scope.padding, $scope.padding ]);

			// draw the x axis
			$scope.xAxis = d3.svg.axis()
			    .scale($scope.xScale)
				.orient('bottom');

			// draw the y axis
			$scope.yAxis = d3.svg.axis()
				.scale($scope.yScale)
				.orient('left');
		}

		//draw chart
		function drawChart() {
			console.log("draw called");
			$scope.createChartParameters();

			//create the chart 
			chart = d3.select('div')
				.append('svg:svg')
				.attr('width', $scope.width + $scope.margin.right + $scope.margin.left)
				.attr('height', $scope.height + $scope.margin.top + $scope.margin.bottom)
				.attr('class', 'chart')
			    .call(zoom);

			main = chart.append('g')
				.attr('transform', 'translate(' + $scope.margin.left + ',' + $scope.margin.top + ')')
				.attr('width', $scope.width)
				.attr('height', $scope.height)
				.attr('class', 'main');

			main.append('g')
				.attr('transform', 'translate(0,' + ($scope.height - $scope.padding) + ')')
				.attr('class', 'main axis')
				.call($scope.xAxis);

			main.append('g')
				.attr('transform', 'translate(' + $scope.padding + ',0)')
				.attr('class', 'main axis')
				.call($scope.yAxis);

			g = main.append("svg:g"); 
			g.selectAll("scatter-dots")
			  .data($scope.data)
			  .enter()
			  .append("circle")
			  .attr("cx", function (d) { return $scope.xScale(d.x); })
			  .attr("cy", function (d) { return $scope.yScale(d.y); })
			  .attr("r", 3)
			  .call(drag)
			  .on("mouseover", $scope.mouseover)
			  .on("mousemove", $scope.mousemove)
			  .on("mouseout", $scope.mouseout);
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
		  d3.select(this)
		    .attr("cx", d.x = d3.event.x)
		    .attr("cy", d.y = d3.event.y);
		  d.x = $scope.xScale.invert(d3.event.x);
		  d.y = $scope.yScale.invert(d3.event.y);
		}

		function dragended(d) {
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
	}
})();