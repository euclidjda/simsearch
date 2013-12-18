
function draw_detail_chart( cid, sid, pricedate) {
        Array.max = function( array ){
            return Math.max.apply( Math, array );
        };
        Array.min = function( array ){
            return Math.min.apply( Math, array );
        };

        /* implementation heavily influenced by http://bl.ocks.org/1166403 */
        /* some arguments AGAINST the use of dual-scaled axes line graphs can be found at http://www.perceptualedge.com/articles/visual_business_intelligence/dual-scaled_axes.pdf */
        
        // define dimensions of graph
        var m = [80, 80, 80, 80]; // margins
        var w = 900 - m[1] - m[3];  // width
        var h = 400 - m[0] - m[2]; // height
        
        // create a simple data array that we'll plot with a line (this array represents only the Y values, X will just be the index location)

        // Market range, calculated from the max and min return of the comparable result set.
        var setMax = 22;
        var setMin = 4;         // this value is selected to be within the range of data1 below, so our range calculation finds the all-inclusive range properly.

        // data1 is monthly returns for the comparable relative to its current position. Total 18 records. 6th month record will be our 0% record.
        var data1 = [-10, 10, 20,  4,-10, 7, 0,  17, 8, 3, 3, 9, 11, -11, -5, 11, 9, 5];

        // since we don't have the market min/max, calculate the min max gains as boundary conditions that are defined by this array ... this will change.
        maxGain = Math.max.apply(Math, data1);
        minGain = Math.min.apply(Math, data1);

        // Find the all-inclusive range.
        var rangeMax = Math.max(maxGain, setMax);   // pick the maximum of the comparable data set and the specific comparable
        var rangeMin = Math.min(minGain, setMin);   // same as max, for the min this time.

        // data2 and data3 are the linear lines that are derived based      

        var data2 = [];
        var data3 = [];
        var setRange = setMax -setMin;

        for (i=0; i < 12; i++) {
            data2[i] = i * (setMax / 12);
            data3[i] = i * (-1) * (setMin / 12);
        }

        xOffset = w/3 + 15;

        // X scale will fit all values from data[] within pixels 0-w
        var x = d3.scale.linear().domain([0, data1.length - 1]).range([0, w]);
        var xx = d3.scale.linear().domain([0, data2.length - 1]).range([xOffset , w]);

        // Y scale will fit values from 0-10 within pixels h-0 (Note the inverted domain for the y-scale: bigger is up!)
        var yScale = d3.scale.linear().domain([rangeMin, rangeMax]).range([h, 0]); // in real world the domain would be dynamically calculated from the data
            // automatically determining max range can work something like this
            // var y = d3.scale.linear().domain([0, d3.max(data)]).range([h, 0]);   


        // create a single object for the background fill.
        var fillData = data2.map(function(d, i) { 
            return { x: i, y0: yScale(data3[i]) , y1: yScale(d)}; });       


        // create a line function that can convert data[] into x and y points
        var line1 = d3.svg.line()
            // assign the X function to plot our line as we wish
            .x(function(d,i) { 
                // verbose logging to show what's actually being done
                // console.log('Plotting X1 value for data point: ' + d + ' using index: ' + i + ' to be at: ' + x(i) + ' using our xScale.');
                // return the X coordinate where we want to plot this datapoint
                return x(i); 
            })
            .y(function(d) { 
                // verbose logging to show what's actually being done
                // console.log('Plotting Y value for data point: ' + d + ' to be at: ' + yScale(d) + " using our yScale.");
                // return the Y coordinate where we want to plot this datapoint
                return yScale(d); 
            })
            
        // create a line function that can convert data[] into x and y points
        var line2 = d3.svg.line()
            // assign the X function to plot our line as we wish
            .x(function(d,i) { 
                // verbose logging to show what's actually being done
                // console.log('Plotting X2 value for data point: ' + d + ' using index: ' + i + ' to be at: ' + x(i) + ' using our xScale.');
                // return the X coordinate where we want to plot this datapoint
                return xx(i);
            })
            .y(function(d) { 
                // verbose logging to show what's actually being done
                // console.log('Plotting Y value for data point: ' + d + ' to be at: ' + yScale(d) + " using our yScale.");
                // return the Y coordinate where we want to plot this datapoint
                return yScale(d); 
            })

        var indexes = d3.range(fillData.length);

        var fillArea = d3.svg.area()
          .x(function(d) { return x(d.x) + xOffset; })
          .y0(function(d) { return d.y0; })
          .y1(function(d) { return d.y1; });            

        var svgWidth = w + m[1] + m[3];
        var svgHeight = h + m[0] + m[2];

        // Add an SVG element with the desired dimensions and margin.
        var graph = d3.select("#detail-graph")
            .append("svg:svg")
              .attr("width", svgWidth)
              .attr("height", svgHeight)
              .attr("viewBox", "0 0 " + svgWidth + " " + svgHeight)
              .attr("preserveAspectRatio", "xMidYMid")
            .append("svg:g")
              .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

        var aspect = svgWidth/svgHeight,
            theGraph = d3.select("svg");

        window.onresize =  function() {
                var targetWidth = $("#detail-graph").width();
                theGraph.attr("width", targetWidth);
                theGraph.attr("height", targetWidth / aspect);
            };            

        months = ["Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar"];
        var formatMonth = function(d) {
            return months[d];
        }

        // create yAxis
        var xAxis = d3.svg.axis().scale(x).tickSize(-h).tickSubdivide(true).tickFormat(formatMonth);

        // Add the x-axis.
        graph.append("svg:g")
              .attr("class", "x axis")
              .attr("transform", "translate(0," + h + ")")
              .call(xAxis);

        // create left yAxis
        var yAxisLeft = d3.svg.axis().scale(yScale).ticks(10).orient("left");

        // Add the y-axis to the left
        graph.append("svg:g")
              .attr("class", "y axis axisLeft")
              .attr("transform", "translate(-15,0)")
              .call(yAxisLeft);
        
        // add lines
        // do this AFTER the axes above so that the line is above the tick-lines

        graph.append("svg:path").attr("d", line1(data1)).attr("class", "data1");
        graph.append("svg:path").attr("d", line2(data2)).attr("class", "data2");
        graph.append("svg:path").attr("d", line2(data3)).attr("class", "data3");

        // paint between two line2 lines for highlight
        graph.append("path")
              .datum(fillData)
              .attr("class", "area")
              .attr("d", fillArea);         

        // add X axis legend
        graph.append("text")      // text label for the x axis
            .attr("x", w/2 )
            .attr("y", h + 36 )
            .style("text-anchor", "middle")
            .text("Date");
        // add Y axis legend
        graph.append("text")
            .attr("x", -h + 10)
            .attr("y", -48 )
            .style("text/anchor", "middle")
            .text("Performance Relative to S&P 500")
            .attr("transform", function(d) { return "rotate(-90)" });

        // add best/worst comparable legend markers
        graph.append("text")
            .attr("x", w - 30)
            .attr("y", yScale(data2[11]) - 8)
            .style("text/anchor", "right")
            .text("Best Comparable")

        graph.append("text")
            .attr("x", w - 40)
            .attr("y", yScale(data3[11]) + 18)
            .style("text/anchor", "right")
            .text("Worst Comparable")

        // add the actual ticker legend
        graph.append("text")
            .attr("x", w - 10)
            .attr("y", yScale(data1[17]) - 10)
            .style("text/anchor", "right")
            .text("IBM")
}

function draw_price_chart( cid, sid, pricedate, price_chart_id ) {

    var post_data = {'cid':cid,'sid':sid,'pricedate':pricedate};
    var json_data = null;

    $.ajax({
        url:      'get_price_time_series',
        dataType: 'json',
        async:    false,
        data:     post_data,
        success:  function(data) {
            json_data = data;
        }
    });

    var series_data = [
        {label:'Price   ',color:'#56617F'},
        {label:'S&P 500 ',color:'orange'},
    ];

    var stk_series = new Array();
    var mrk_series = new Array();

    var stk_factor = 1;
    var mrk_factor = 1;

    // find price date and set values
    for (var i=0; i < json_data.length; i++) {

        if (json_data[i].mrk_price == null || json_data[i].mrk_price == 0) {
            if (i>0)
                json_data[i].mrk_price = json_data[i-1].mrk_price;
        }

        if (json_data[i].datadate == pricedate) {

            stk_factor = json_data[i].ajex;
            mrk_factor = json_data[i].price/json_data[i].mrk_price;
        }
    }

    for(var i=0; i < json_data.length; i++) {

        stk_series[i] = new Array(2);
        mrk_series[i] = new Array(2);

        stk_series[i][0] = json_data[i].datadate;
        stk_series[i][1] = (json_data[i].price / json_data[i].ajex) * stk_factor;
        mrk_series[i][0] = json_data[i].datadate;
        mrk_series[i][1] = json_data[i].mrk_price * mrk_factor;

    }

    date = new Date(pricedate);
    date.setYear(1900+date.getYear()+1);
    var max_date = date.toISOString().substring(0,10);

    // $.jqplot(price_chart_id,[stk_series,mrk_series],
    //          {
    //              fontFamily: 'Helvetica',
    //              title: {
    //                  //text: 'Price / Performance',
    //                  fontFamily: 'Helvetica',
    //                  textAlign: 'left',
    //              },
    //              seriesDefaults:{
    //                  shadow: false,
    //                  lineWidth: 1.0,
    //                  showMarker: false
    //              },
    //              series: series_data,
    //              grid: {
    //                  background: '#F2F2F2',
    //                  shadow: false,
    //              },
    //              legend: {
    //                  show: true,
    //                  location: 'sw',
    //                  xoffset: 0,
    //                  yoffset: 0
    //              },
    //              axes:{
    //                  xaxis:{
    //                      renderer:$.jqplot.DateAxisRenderer,
    //                      tickOptions:{formatString:'%b %y'},
    //                      max: max_date,
    //                  },
    //                  yaxis: {
    //                      pad: 1.05,
    //                      tickOptions: {formatString: '$%d'},
    //                      min: 0,
    //                  }
    //              }
    //          });
}

function draw_growth_chart( cid, sid, pricedate, growth_chart_id ) {

    var post_data = {'cid':cid,'sid':sid,'pricedate':pricedate};
    var json_data = null;

    $.ajax({
        url:      'get_growth_time_series',
        dataType: 'json',
        async:    false,
        data:     post_data,
        success:  function(data) {
            json_data = data;
        }
    });

   // This we will get by snycronous ajax request with cid,sid,datadate
    var revenue = Array(); //[80,120,115,130];
    var gain    = Array(); //[0,11,12,14];
    var loss    = Array(); //[14,0,0,0];

    var x_axis_labels = Array(); //['2002','2003','2004','2005'];


    for (var i=0; i < json_data.length; i++) {

        var idx = json_data.length-i-1;

        revenue[idx] = json_data[i].sale;

        var profit = json_data[i].opi;

        gain[idx] = (profit >= 0) ? profit : 0;
        loss[idx] = (profit <  0) ? -profit : 0;

        x_axis_labels[idx] = json_data[i].datadate.substring(0,4);

    }

    var series_data = [
        {label:'Revenue',color:'#56617F'},
        {label:'Operating-Income',color:'#7C8FB7'},
        {label:'Operating-Loss',color:'red'}
    ];

    // $.jqplot(growth_chart_id,[revenue,gain,loss],
    //          {
    //              fontFamily: 'Helvetica',

    //              title: {
    //                  text: 'Historical Growth',
    //                  fontFamily: 'Helvetica',
    //                  textAlign: 'left',
    //              },
    //              stackSeries: true,
    //              seriesDefaults:{
    //                  renderer:$.jqplot.BarRenderer,
    //                  shadow: false,
    //                  rendererOptions: {
    //                      barMargin: 30,
    //                  }
    //              },
    //              series: series_data,
    //              grid: {
    //                  background: '#F2F2F2',
    //                  shadow: false,
    //              },
    //              legend: {
    //                  show: true,
    //                  location: 'nw',
    //                  xoffset: 0,
    //                  yoffset: 0
    //              },
    //              axes: {
    //                  xaxis: {
    //                      renderer: $.jqplot.CategoryAxisRenderer,
    //                      ticks: x_axis_labels
    //                  },
    //                  yaxis: {
    //                      pad: 1.05,
    //                      tickOptions: {formatString: '$%dM'},
    //                      min: 0,
    //                  }
    //              }
    //          });
}

